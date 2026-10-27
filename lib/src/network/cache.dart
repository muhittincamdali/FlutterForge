import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'api_exception.dart';
import 'cache_policy.dart';
import 'forge_request.dart';
import 'forge_response.dart';
import 'interceptor.dart';

/// A response kept by a [ResponseCache].
final class CachedResponse {
  /// Creates an entry.
  CachedResponse({
    required this.statusCode,
    required this.headers,
    required this.bodyBytes,
    required this.storedAt,
    required this.freshFor,
  });

  /// The status code of the stored response.
  final int statusCode;

  /// The headers of the stored response, with lower-case names.
  final Map<String, String> headers;

  /// The body of the stored response.
  final Uint8List bodyBytes;

  /// When the response was stored or last revalidated.
  final DateTime storedAt;

  /// How long after [storedAt] the entry may be used without asking the
  /// server.
  final Duration freshFor;

  /// The `ETag` validator, if the server sent one.
  String? get etag => headers['etag'];

  /// The `Last-Modified` validator, if the server sent one.
  String? get lastModified => headers['last-modified'];

  /// Whether the entry is still fresh at [now].
  bool isFreshAt(DateTime now) => now.isBefore(storedAt.add(freshFor));

  /// The number of bytes the entry counts against a cache limit.
  int get size => bodyBytes.length + headers.entries.fold(0, (sum, e) => sum + e.key.length + e.value.length);

  /// Returns a copy that was revalidated at [now].
  CachedResponse refreshed(DateTime now, Duration freshFor) =>
      CachedResponse(statusCode: statusCode, headers: headers, bodyBytes: bodyBytes, storedAt: now, freshFor: freshFor);
}

/// Storage for cached responses.
///
/// Implement it to keep responses on disk or in a database; the package ships
/// [MemoryResponseCache].
abstract interface class ResponseCache {
  /// The entry for [key], or `null`.
  CachedResponse? read(String key);

  /// Stores [entry] under [key], replacing an older one.
  void write(String key, CachedResponse entry);

  /// Removes the entry for [key].
  void remove(String key);

  /// Removes every entry, for example when the user signs out.
  void clear();
}

/// An in-memory [ResponseCache] that evicts the least recently used entries.
///
/// Both the number of entries and their total size are bounded. An entry
/// larger than [maxBytes] on its own is not stored.
final class MemoryResponseCache implements ResponseCache {
  /// Creates a cache. Both limits must be positive.
  MemoryResponseCache({this.maxEntries = 128, this.maxBytes = 8 * 1024 * 1024}) {
    if (maxEntries < 1) throw ArgumentError.value(maxEntries, 'maxEntries', 'must be at least 1');
    if (maxBytes < 1) throw ArgumentError.value(maxBytes, 'maxBytes', 'must be at least 1');
  }

  /// The highest number of entries.
  final int maxEntries;

  /// The highest total size of all entries, in bytes.
  final int maxBytes;

  final LinkedHashMap<String, CachedResponse> _entries = LinkedHashMap();
  int _bytes = 0;

  /// The number of entries.
  int get length => _entries.length;

  /// The total size of all entries, in bytes.
  int get bytes => _bytes;

  @override
  CachedResponse? read(String key) {
    final entry = _entries.remove(key);
    if (entry != null) _entries[key] = entry;
    return entry;
  }

  @override
  void write(String key, CachedResponse entry) {
    remove(key);
    if (entry.size > maxBytes) return;
    _entries[key] = entry;
    _bytes += entry.size;
    while (_entries.length > maxEntries || _bytes > maxBytes) {
      remove(_entries.keys.first);
    }
  }

  @override
  void remove(String key) {
    final entry = _entries.remove(key);
    if (entry != null) _bytes -= entry.size;
  }

  @override
  void clear() {
    _entries.clear();
    _bytes = 0;
  }
}

/// Reads `max-age` from a `Cache-Control` header. Returns `null` when it is
/// missing or malformed; a value of more than ten digits is malformed.
Duration? parseMaxAge(String? cacheControl) {
  if (cacheControl == null) return null;
  final match = RegExp(
    r'(?:^|[,\s])max-age\s*=\s*"?(\d{1,10})"?(?:$|[,\s])',
    caseSensitive: false,
  ).firstMatch(cacheControl);
  return match == null ? null : Duration(seconds: int.parse(match.group(1)!));
}

bool _hasDirective(String? cacheControl, String directive) =>
    cacheControl != null &&
    cacheControl.toLowerCase().split(',').any((part) => part.trim().split('=').first.trim() == directive);

/// Answers `GET` requests from a [ResponseCache] as their [CachePolicy]
/// allows.
///
/// Only `200` responses are stored. A `Cache-Control: no-store` response is
/// never stored and `no-cache` stores it as already stale, so it is
/// revalidated before each use. The fresh lifetime is the response's
/// `max-age` when present, otherwise [defaultMaxAge], and never more than
/// [maxAgeLimit].
///
/// Responses are keyed by URL only. When responses differ per user, call
/// [ResponseCache.clear] when the user changes.
final class CacheInterceptor implements Interceptor {
  /// Creates the interceptor.
  CacheInterceptor(
    this.cache, {
    this.defaultMaxAge = const Duration(minutes: 5),
    this.maxAgeLimit = const Duration(days: 7),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Where responses are kept.
  final ResponseCache cache;

  /// The fresh lifetime of a response without `max-age`.
  final Duration defaultMaxAge;

  /// The longest fresh lifetime, whatever the server says.
  final Duration maxAgeLimit;

  final DateTime Function() _clock;

  /// The key under which [request] is stored.
  static String keyFor(ForgeRequest request) => '${request.method} ${request.uri}';

  @override
  Future<ForgeResponse> intercept(ForgeRequest request, RequestHandler next) async {
    if (request.method != 'GET' || request.cachePolicy == CachePolicy.noCache) {
      return next(request);
    }
    final key = keyFor(request);
    final stored = cache.read(key);
    return switch (request.cachePolicy) {
      CachePolicy.cacheFirst => _cacheFirst(request, next, key, stored),
      CachePolicy.networkFirst => _networkFirst(request, next, key, stored),
      CachePolicy.noCache => next(request),
    };
  }

  Future<ForgeResponse> _cacheFirst(
    ForgeRequest request,
    RequestHandler next,
    String key,
    CachedResponse? stored,
  ) async {
    if (stored == null) return _fetchAndStore(request, next, key);
    if (stored.isFreshAt(_clock())) return _toResponse(stored, request);
    final validators = {'if-none-match': ?stored.etag, 'if-modified-since': ?stored.lastModified};
    if (validators.isEmpty) return _fetchAndStore(request, next, key);
    final response = await next(request.withHeaders(add: validators));
    if (response.statusCode == 304) {
      final refreshed = stored.refreshed(_clock(), _lifetime(response.header('cache-control')));
      cache.write(key, refreshed);
      return _toResponse(refreshed, request);
    }
    _store(key, response);
    return response;
  }

  Future<ForgeResponse> _networkFirst(
    ForgeRequest request,
    RequestHandler next,
    String key,
    CachedResponse? stored,
  ) async {
    try {
      return await _fetchAndStore(request, next, key);
    } on ApiException catch (error) {
      final offline = error is ConnectionException || error is RequestTimeoutException;
      if (!offline || stored == null) rethrow;
      return _toResponse(stored, request);
    }
  }

  Future<ForgeResponse> _fetchAndStore(ForgeRequest request, RequestHandler next, String key) async {
    final response = await next(request);
    _store(key, response);
    return response;
  }

  void _store(String key, ForgeResponse response) {
    if (response.statusCode != 200 || response.fromCache) return;
    final cacheControl = response.header('cache-control');
    if (_hasDirective(cacheControl, 'no-store')) {
      cache.remove(key);
      return;
    }
    cache.write(
      key,
      CachedResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        bodyBytes: response.bodyBytes,
        storedAt: _clock(),
        freshFor: _lifetime(cacheControl),
      ),
    );
  }

  Duration _lifetime(String? cacheControl) {
    if (_hasDirective(cacheControl, 'no-cache')) return Duration.zero;
    final lifetime = parseMaxAge(cacheControl) ?? defaultMaxAge;
    if (lifetime.isNegative) return Duration.zero;
    return Duration(microseconds: math.min(lifetime.inMicroseconds, maxAgeLimit.inMicroseconds));
  }

  ForgeResponse _toResponse(CachedResponse entry, ForgeRequest request) => ForgeResponse(
    statusCode: entry.statusCode,
    request: request,
    headers: entry.headers,
    bodyBytes: entry.bodyBytes,
    fromCache: true,
  );
}
