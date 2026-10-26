import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'auth.dart';
import 'cache.dart';
import 'cache_policy.dart';
import 'cancel_token.dart';
import 'forge_request.dart';
import 'forge_response.dart';
import 'interceptor.dart';
import 'retry.dart';

/// Decodes the JSON value of a response body into a [T].
typedef JsonDecoder<T> = T Function(Object? json);

const Set<int> _redirectStatuses = {301, 302, 303, 307, 308};
const List<String> _credentialHeaders = ['authorization', 'cookie', 'proxy-authorization'];

/// The highest `maxRedirects` value a client accepts.
const int redirectLimit = 20;

/// A JSON-over-HTTP client with retries, caching, bearer tokens, time limits
/// and a response size limit.
///
/// ```dart
/// final client = ForgeClient(baseUrl: 'https://api.example.com/v1');
/// final todos = await client.getJson('/todos', decode: Todo.listFromJson);
/// ```
///
/// Every call goes through, from the outside in: your [Interceptor]s, the
/// cache (when a [ResponseCache] is given), the retry policy, the bearer
/// token (when [BearerAuth] is given), and the transport. The transport
/// follows redirects itself so it can refuse unsafe ones and drop credentials
/// when a redirect leaves the original origin.
///
/// Methods ending in `Json` throw an [ApiException] for a status outside
/// 2xx and for a body the decoder cannot read; [send] returns every response
/// and only throws for transport failures.
final class ForgeClient {
  /// Creates a client.
  ///
  /// [baseUrl] must be an absolute `http` or `https` URL without user
  /// information, query or fragment. Relative paths given to the methods are
  /// appended to its path, so `/todos` on `https://api.example.com/v1` is
  /// `https://api.example.com/v1/todos`.
  ///
  /// [headers] are sent with every request, also to an absolute URL on
  /// another origin; only the token of [auth] is limited to the origin of
  /// [baseUrl]. Do not put a key here that other origins must not see.
  ///
  /// [timeout] limits each attempt, from sending the request to reading the
  /// last byte of the body. [maxResponseBytes] limits the body; a longer body
  /// throws [ResponseTooLargeException] without being read further.
  ///
  /// Pass [httpClient] to use a specific `http` implementation, such as
  /// `cupertino_http` or `cronet_http`, or a `MockClient` in tests. A client
  /// passed in is not closed by [close].
  ForgeClient({
    required String baseUrl,
    http.Client? httpClient,
    Map<String, String> headers = const {'accept': 'application/json'},
    this.timeout = const Duration(seconds: 30),
    this.maxResponseBytes = 16 * 1024 * 1024,
    this.maxRedirects = 5,
    RetryPolicy retry = const RetryPolicy(),
    ResponseCache? cache,
    BearerAuth? auth,
    List<Interceptor> interceptors = const [],
  }) : baseUrl = _checkedBaseUrl(baseUrl),
       _http = httpClient ?? http.Client(),
       _ownsHttp = httpClient == null,
       _headers = Map.unmodifiable(headers) {
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'must be positive');
    }
    if (maxResponseBytes < 1) {
      throw ArgumentError.value(maxResponseBytes, 'maxResponseBytes', 'must be at least 1');
    }
    if (maxRedirects < 0 || maxRedirects > redirectLimit) {
      throw ArgumentError.value(maxRedirects, 'maxRedirects', 'must be between 0 and $redirectLimit');
    }
    // Validates the default headers once, here, instead of on the first call.
    ForgeRequest(method: 'GET', uri: this.baseUrl, headers: _headers);
    _handler = buildChain([
      ...interceptors,
      if (cache != null) CacheInterceptor(cache),
      if (retry.attempts > 1) RetryInterceptor(retry),
      if (auth != null)
        BearerAuthInterceptor(
          readToken: auth.readToken,
          refreshToken: auth.refreshToken,
          trustedOrigins: [this.baseUrl],
        ),
    ], _transport);
  }

  /// The URL that relative paths are appended to.
  final Uri baseUrl;

  /// The time limit of each attempt.
  final Duration timeout;

  /// The largest response body the client reads, in bytes.
  final int maxResponseBytes;

  /// The number of redirects followed before failing with a
  /// [RedirectException]. `0` returns redirect responses as they are.
  final int maxRedirects;

  final http.Client _http;
  final bool _ownsHttp;
  final Map<String, String> _headers;
  late final RequestHandler _handler;

  /// Builds the absolute URL for [path] and [query].
  ///
  /// An absolute `http` or `https` [path] is used as it is, unless it
  /// contains user information (`user:password@`), which throws an
  /// [ArgumentError]. A relative path
  /// may not contain `.` or `..` segments, so a value such as
  /// `'/files/$name'` with `name = '../admin'` cannot leave the base path;
  /// such a path throws an [ArgumentError]. Segments are read the way a
  /// server may read them: `%25` is decoded first (`%252e` counts as `.`),
  /// segments are split at `/`, `\`, `%2f` and `%5c`, at their `%u` and
  /// overlong UTF-8 forms (`%u002f`, `%c0%af`, `%e0%80%af`) and at the
  /// full-width `／` and `＼` and the division slash `∕`, a `;` parameter is
  /// ignored (`..;x` counts as `..`), `%2e` and the full-width and small dots
  /// count as `.`, as do `%u002e` and the overlong `%c0%ae`, the two-dot
  /// leader `‥` and the ellipsis `…` count as dots, and control
  /// characters and spaces, also the no-break space, are dropped, so
  /// `..%00`, `..%0a`, `.. `, `..%c2%a0` and `．．` count as `..`. A segment
  /// made only of dots, such as `...`, is refused too. The check runs on the path as given and again on
  /// the path that is sent, after `Uri.parse` has decoded escapes such as
  /// `%32` and encoded a stray `%`, so `%25%32%65` and `%2%65`, which are sent
  /// as `%252e`, count as `.` as well. A fragment is dropped.
  ///
  /// Query values are converted with `toString`; `null` values are skipped
  /// and an [Iterable] adds the parameter once per element.
  Uri resolve(String path, [Map<String, Object?>? query]) {
    Uri target;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      target = Uri.parse(path);
      // The message does not repeat the URL: the user information is a secret.
      if (target.userInfo.isNotEmpty) {
        throw ArgumentError('The URL must not contain user information.', 'path');
      }
    } else {
      if (_hasDotSegment(path.split(RegExp('[?#]')).first)) {
        throw ArgumentError('The path must not contain "." or ".." segments.', 'path');
      }
      final basePath = baseUrl.path.endsWith('/') ? baseUrl.path.substring(0, baseUrl.path.length - 1) : baseUrl.path;
      final relative = path.startsWith('/') ? path.substring(1) : path;
      target = Uri.parse('${baseUrl.scheme}://${baseUrl.authority}$basePath/$relative');
      // A second line of defence in case Uri.parse rewrites a path in a way
      // the check above does not know about.
      if (target.authority != baseUrl.authority || !target.path.startsWith('$basePath/')) {
        throw ArgumentError('The path must stay below the base URL.', 'path');
      }
      // Uri.parse decodes escapes of unreserved characters and encodes a `%`
      // that starts no valid escape, so `%25%32%65` and `%2%65` are sent as
      // `%252e`. The path that is sent is checked again for that reason.
      if (_hasDotSegment(target.path.substring(basePath.length + 1))) {
        throw ArgumentError('The path must not contain "." or ".." segments.', 'path');
      }
    }
    target = target.removeFragment();
    if (query == null || query.isEmpty) return target;
    final parameters = <String, List<String>>{
      ...target.queryParametersAll.map((k, v) => MapEntry(k, [...v])),
    };
    for (final MapEntry(:key, :value) in query.entries) {
      if (value == null) continue;
      final values = value is Iterable<Object?> ? value.whereType<Object>().map((v) => '$v') : ['$value'];
      parameters.putIfAbsent(key, () => []).addAll(values);
    }
    return target.replace(queryParameters: parameters);
  }

  /// Sends [request] through the interceptors and returns the response,
  /// whatever its status code.
  ///
  /// Throws [ConnectionException], [RequestTimeoutException],
  /// [RequestCancelledException], [ResponseTooLargeException] or
  /// [RedirectException].
  Future<ForgeResponse> send(ForgeRequest request) => _handler(request);

  /// Sends a request with [method] to [path] and throws an
  /// [HttpStatusException] unless the answer is in the 2xx range.
  ///
  /// [json] is encoded as the JSON body; [body] sends raw bytes instead.
  Future<ForgeResponse> request(
    String method,
    String path, {
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    Object? json,
    Uint8List? body,
    CachePolicy cachePolicy = CachePolicy.noCache,
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    if (json != null && body != null) {
      throw ArgumentError('Pass either json or body, not both.');
    }
    final encoded = json != null ? Uint8List.fromList(utf8.encode(jsonEncode(json))) : body;
    final response = await send(
      ForgeRequest(
        method: method,
        uri: resolve(path, query),
        headers: {..._headers, if (json != null) 'content-type': 'application/json; charset=utf-8', ...headers},
        body: encoded,
        cachePolicy: cachePolicy,
        cancelToken: cancelToken,
        timeout: timeout,
      ),
    );
    if (!response.isSuccess) throw HttpStatusException(response);
    return response;
  }

  /// Sends `GET` and decodes the JSON answer with [decode].
  Future<T> getJson<T>(
    String path, {
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CachePolicy cachePolicy = CachePolicy.noCache,
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final response = await request(
      'GET',
      path,
      query: query,
      headers: headers,
      cachePolicy: cachePolicy,
      cancelToken: cancelToken,
      timeout: timeout,
    );
    return decodeResponse(response, decode);
  }

  /// Sends `POST` with [json] as the body and decodes the answer with
  /// [decode].
  Future<T> postJson<T>(
    String path, {
    required Object? json,
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final response = await request(
      'POST',
      path,
      query: query,
      headers: headers,
      json: json,
      cancelToken: cancelToken,
      timeout: timeout,
    );
    return decodeResponse(response, decode);
  }

  /// Sends `PUT` with [json] as the body and decodes the answer with
  /// [decode].
  Future<T> putJson<T>(
    String path, {
    required Object? json,
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final response = await request(
      'PUT',
      path,
      query: query,
      headers: headers,
      json: json,
      cancelToken: cancelToken,
      timeout: timeout,
    );
    return decodeResponse(response, decode);
  }

  /// Sends `PATCH` with [json] as the body and decodes the answer with
  /// [decode].
  Future<T> patchJson<T>(
    String path, {
    required Object? json,
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final response = await request(
      'PATCH',
      path,
      query: query,
      headers: headers,
      json: json,
      cancelToken: cancelToken,
      timeout: timeout,
    );
    return decodeResponse(response, decode);
  }

  /// Sends `POST` with [fields] as an `application/x-www-form-urlencoded`
  /// body, as an HTML form or an OAuth token endpoint expects, and decodes
  /// the answer with [decode].
  Future<T> postForm<T>(
    String path, {
    required Map<String, String> fields,
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final form = http.Request('POST', baseUrl)..bodyFields = fields;
    final response = await request(
      'POST',
      path,
      query: query,
      headers: {'content-type': form.headers['content-type']!, ...headers},
      body: form.bodyBytes,
      cancelToken: cancelToken,
      timeout: timeout,
    );
    return decodeResponse(response, decode);
  }

  /// Sends `POST` with a `multipart/form-data` body made of [fields] and
  /// [files], and decodes the answer with [decode].
  ///
  /// The body is built in memory before it is sent, so it can be sent again
  /// by the retry policy; for files of many megabytes, send them with your
  /// own `http.StreamedRequest` instead.
  ///
  /// ```dart
  /// final avatar = await client.postMultipart(
  ///   '/me/avatar',
  ///   files: [MultipartFile.fromBytes('file', pngBytes, filename: 'avatar.png')],
  ///   decode: Avatar.fromJson,
  /// );
  /// ```
  Future<T> postMultipart<T>(
    String path, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final multipart = http.MultipartRequest('POST', baseUrl)
      ..fields.addAll(fields)
      ..files.addAll(files);
    final body = await multipart.finalize().toBytes();
    final response = await request(
      'POST',
      path,
      query: query,
      headers: {'content-type': multipart.headers['content-type']!, ...headers},
      body: body,
      cancelToken: cancelToken,
      timeout: timeout,
    );
    return decodeResponse(response, decode);
  }

  /// Sends `DELETE` and returns the response.
  Future<ForgeResponse> delete(
    String path, {
    Map<String, Object?>? query,
    Map<String, String> headers = const {},
    CancelToken? cancelToken,
    Duration? timeout,
  }) => request('DELETE', path, query: query, headers: headers, cancelToken: cancelToken, timeout: timeout);

  /// Closes the underlying `http` client if this client created it.
  void close() {
    if (_ownsHttp) _http.close();
  }

  /// Parses the body of [response] as JSON and passes it to [decode].
  ///
  /// Any error thrown by [decode], such as a failed cast, becomes a
  /// [DecodingException].
  static T decodeResponse<T>(ForgeResponse response, JsonDecoder<T> decode) {
    final json = response.json();
    try {
      return decode(json);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw DecodingException(response.request, error, response: response);
    }
  }

  Future<ForgeResponse> _transport(ForgeRequest request) async {
    var current = request;
    for (var redirects = 0; ; redirects++) {
      final response = await _sendOnce(current);
      if (!_redirectStatuses.contains(response.statusCode) || maxRedirects == 0) return response;
      final location = response.header('location');
      if (location == null) return response;
      if (redirects >= maxRedirects) {
        throw RedirectException(current, 'more than $maxRedirects redirects');
      }
      current = _redirected(current, response.statusCode, location);
    }
  }

  ForgeRequest _redirected(ForgeRequest request, int status, String location) {
    final Uri target;
    try {
      target = request.uri.resolve(location.trim());
    } on FormatException {
      throw RedirectException(request, 'the Location header is not a valid URL');
    }
    if (!(target.isScheme('http') || target.isScheme('https')) || target.host.isEmpty) {
      throw RedirectException(request, 'the redirect target is not an http or https URL');
    }
    if (request.uri.isScheme('https') && target.isScheme('http')) {
      throw RedirectException(request, 'the redirect goes from https to http');
    }
    if (target.userInfo.isNotEmpty) {
      throw RedirectException(request, 'the redirect target contains user information');
    }
    final sameOrigin =
        target.scheme == request.uri.scheme && target.host == request.uri.host && target.port == request.uri.port;
    final keepsMethod = status == 307 || status == 308 || request.method == 'GET' || request.method == 'HEAD';
    if (keepsMethod && request.body.isNotEmpty && !sameOrigin) {
      throw RedirectException(request, 'refusing to send the request body to another origin');
    }
    final headers = Map.of(request.headers);
    if (!sameOrigin) {
      for (final name in _credentialHeaders) {
        headers.remove(name);
      }
    }
    if (!keepsMethod) {
      headers
        ..remove('content-type')
        ..remove('content-length');
    }
    return ForgeRequest(
      method: keepsMethod ? request.method : 'GET',
      uri: target.removeFragment(),
      headers: headers,
      body: keepsMethod ? request.body : null,
      cachePolicy: request.cachePolicy,
      cancelToken: request.cancelToken,
      timeout: request.timeout,
    );
  }

  Future<ForgeResponse> _sendOnce(ForgeRequest request) async {
    final cancelToken = request.cancelToken;
    if (cancelToken != null && cancelToken.isCancelled) throw RequestCancelledException(request);

    final limit = request.timeout ?? timeout;
    final abort = Completer<void>();
    final failure = Completer<ForgeResponse>();
    var finished = false;
    void stop(ApiException error) {
      if (finished) return;
      if (!failure.isCompleted) failure.completeError(error);
      if (!abort.isCompleted) abort.complete();
    }

    final timer = Timer(limit, () => stop(RequestTimeoutException(request, limit)));
    // Removed in `finally`: a long-lived token must not keep finished
    // requests, and their bodies, reachable.
    final stopListening = cancelToken?.onCancel(() => stop(RequestCancelledException(request)));

    final outgoing = http.AbortableRequest(request.method, request.uri, abortTrigger: abort.future)
      ..followRedirects = false
      ..headers.addAll(request.headers);
    if (request.body.isNotEmpty) outgoing.bodyBytes = request.body;

    final work = _receive(outgoing, request, abort);
    // The losing future may still fail after the race is decided.
    work.ignore();
    try {
      return await Future.any([work, failure.future]);
    } finally {
      finished = true;
      timer.cancel();
      stopListening?.call();
      if (!abort.isCompleted) abort.complete();
    }
  }

  Future<ForgeResponse> _receive(http.BaseRequest outgoing, ForgeRequest request, Completer<void> abort) async {
    final http.StreamedResponse streamed;
    try {
      streamed = await _http.send(outgoing);
    } on http.RequestAbortedException {
      throw RequestCancelledException(request);
    } on Exception catch (error) {
      throw ConnectionException(request, error);
    }
    final declared = streamed.contentLength;
    if (declared != null && declared > maxResponseBytes) {
      if (!abort.isCompleted) abort.complete();
      throw ResponseTooLargeException(request, maxResponseBytes);
    }
    final bytes = BytesBuilder(copy: false);
    try {
      await for (final chunk in streamed.stream) {
        if (bytes.length + chunk.length > maxResponseBytes) {
          if (!abort.isCompleted) abort.complete();
          throw ResponseTooLargeException(request, maxResponseBytes);
        }
        bytes.add(chunk);
      }
    } on ApiException {
      rethrow;
    } on http.RequestAbortedException {
      throw RequestCancelledException(request);
    } on Exception catch (error) {
      throw ConnectionException(request, error);
    }
    return ForgeResponse(
      statusCode: streamed.statusCode,
      request: request,
      headers: streamed.headers,
      bodyBytes: bytes.takeBytes(),
      reasonPhrase: streamed.reasonPhrase,
    );
  }
}

// What a server may read as a path separator: `/`, `\` (Uri.parse turns it
// into `/`), both of them percent-encoded, the IIS forms `%u002f` and
// `%u005c`, the overlong UTF-8 forms that lenient decoders accept (`%c0%af`,
// `%e0%80%af`, `%c1%9c`, `%e0%81%9c`), the full-width solidus and reverse
// solidus, which Unicode normalisation turns into `/` and `\`, and the
// division slash and set minus, which Windows best-fit mapping turns into
// them. The last four raw, as `%u` forms or percent-encoded as UTF-8.
final RegExp _segmentSeparator = RegExp(
  r'[/\\\u2215\u2216\uFF0F\uFF3C]|%2f|%5c|%u(?:002f|005c|2215|2216|ff0f|ff3c)|%c0%af|%e0%80%af|%c1%9c|%e0%81%9c'
  r'|%e2%88%95|%e2%88%96|%ef%bc%8f|%ef%bc%bc',
  caseSensitive: false,
);

// Servers such as Tomcat read `..;x` as `..` with a parameter.
final RegExp _segmentParameters = RegExp(';|%3b', caseSensitive: false);

// Servers that decode a path twice read `%252e` as `.`, so every `%` followed
// by one or more `25` is read as `%` before the path is split, however often
// it is nested. One pass keeps the check linear in the length of the path.
final RegExp _encodedPercent = RegExp('%(?:25)+', caseSensitive: false);

bool _hasDotSegment(String path) => path.replaceAll(_encodedPercent, '%').split(_segmentSeparator).any(_isDotSegment);

// What a server may read as `.`: `%2e`, the IIS form `%u002e`, the overlong
// UTF-8 forms `%c0%ae` and `%e0%80%ae` that lenient decoders accept, and the
// full-width, small and one-dot-leader dots, the two-dot leader and the
// ellipsis, which Unicode normalisation turns into `.`, `..` and `...`; raw,
// as `%u` forms or percent-encoded as UTF-8. Each becomes one `.`, which is
// enough: a segment made only of dots is refused whatever their number.
final RegExp _dotLike = RegExp(
  r'%2e|%u(?:002e|ff0e|fe52|2024|2025|2026)|%c0%ae|%e0%80%ae|[\uFF0E\uFE52\u2024\u2025\u2026]'
  r'|%ef%bc%8e|%ef%b9%92|%e2%80%a[4-6]',
  caseSensitive: false,
);

// What a server may drop from a segment: NUL, which ends a C string, the other
// control characters (line breaks, tabs, DEL), which servers and proxies strip
// or split at, and spaces including the no-break space, which IIS and Windows
// trim from the end of a name. Raw or percent-encoded.
final RegExp _droppedByServers = RegExp(r'%[01][0-9a-f]|%7f|%20|%c2%a0|[\s\x00-\x1f\x7f]', caseSensitive: false);

final RegExp _onlyDots = RegExp(r'^\.+$');

bool _isDotSegment(String segment) {
  final name = segment.split(_segmentParameters).first;
  final decoded = name.replaceAll(_dotLike, '.').replaceAll(_droppedByServers, '');
  return _onlyDots.hasMatch(decoded);
}

// The messages do not repeat the value: it may hold a password or a key.
Uri _checkedBaseUrl(String value) {
  final Uri uri;
  try {
    uri = Uri.parse(value);
  } on FormatException {
    throw ArgumentError('baseUrl is not a valid URL.', 'baseUrl');
  }
  if (!(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
    throw ArgumentError('baseUrl must be an absolute http or https URL.', 'baseUrl');
  }
  if (uri.userInfo.isNotEmpty || uri.hasQuery || uri.hasFragment) {
    throw ArgumentError('baseUrl must not contain user information, a query or a fragment.', 'baseUrl');
  }
  return uri;
}
