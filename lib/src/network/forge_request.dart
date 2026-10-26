import 'dart:typed_data';

import 'cache_policy.dart';
import 'cancel_token.dart';

/// Methods that a server must treat as safe to repeat (RFC 9110, section 9.2.2).
///
/// The retry interceptor only repeats these unless told otherwise.
const Set<String> idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE', 'TRACE'};

final RegExp _token = RegExp(r"^[!#$%&'*+\-.^_`|~0-9A-Za-z]+$");

/// One HTTP request as it travels through the interceptors of a
/// `ForgeClient`.
///
/// A request is immutable: an interceptor that needs a different header or
/// URL calls [copyWith] or [withHeaders] and passes the copy on. The body is
/// kept as bytes, so the same request can be sent again by the retry logic.
///
/// Header names are stored in lower case. The constructor rejects a method or
/// header name that is not an HTTP token and a header value that contains a
/// line break or a NUL character, so a value read from user input cannot add
/// a header of its own.
final class ForgeRequest {
  /// Creates a request.
  ///
  /// Throws an [ArgumentError] when [uri] is not an absolute `http` or
  /// `https` URL, when it contains user information (`user:password@`), or
  /// when a method, header name or header value is invalid.
  ForgeRequest({
    required String method,
    required this.uri,
    Map<String, String> headers = const {},
    Uint8List? body,
    this.cachePolicy = CachePolicy.noCache,
    this.cancelToken,
    this.timeout,
  }) : method = _checkedMethod(method),
       headers = Map.unmodifiable(_checkedHeaders(headers)),
       body = body ?? Uint8List(0) {
    if (!(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
      throw ArgumentError.value(uri.scheme, 'uri', 'must be an absolute http or https URL');
    }
    // The message does not repeat the URL: the user information is a secret.
    if (uri.userInfo.isNotEmpty) {
      throw ArgumentError('The URL must not contain user information.', 'uri');
    }
    final limit = timeout;
    if (limit != null && limit <= Duration.zero) {
      throw ArgumentError.value(limit, 'timeout', 'must be positive');
    }
  }

  /// The method in upper case, such as `GET` or `POST`.
  final String method;

  /// The absolute URL.
  final Uri uri;

  /// The headers, with lower-case names.
  final Map<String, String> headers;

  /// The body; empty when the request has none.
  final Uint8List body;

  /// How a cache interceptor may answer this request.
  final CachePolicy cachePolicy;

  /// Cancels the request when its `cancel` method is called.
  final CancelToken? cancelToken;

  /// The time limit for one attempt, or `null` for the client's default.
  final Duration? timeout;

  /// Whether repeating the request is safe according to its method.
  bool get isIdempotent => idempotentMethods.contains(method);

  /// The value of the header [name], compared without regard to case.
  String? header(String name) => headers[name.toLowerCase()];

  /// Returns a copy with the given fields replaced.
  ForgeRequest copyWith({
    String? method,
    Uri? uri,
    Map<String, String>? headers,
    Uint8List? body,
    CachePolicy? cachePolicy,
  }) {
    return ForgeRequest(
      method: method ?? this.method,
      uri: uri ?? this.uri,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      cachePolicy: cachePolicy ?? this.cachePolicy,
      cancelToken: cancelToken,
      timeout: timeout,
    );
  }

  /// Returns a copy with [add] set (replacing headers of the same name) and
  /// every header named in [remove] taken out.
  ForgeRequest withHeaders({Map<String, String> add = const {}, Iterable<String> remove = const []}) {
    final next = Map<String, String>.of(headers);
    for (final name in remove) {
      next.remove(name.toLowerCase());
    }
    for (final MapEntry(:key, :value) in add.entries) {
      next[key.toLowerCase()] = value;
    }
    return copyWith(headers: next);
  }

  /// The method, scheme, host and port, for messages. The path and query are
  /// left out because they can carry identifiers or tokens.
  ///
  /// The host is written only when it is a plain DNS name, an IPv4 address or
  /// an IPv6 address without a zone, and none of its labels looks like a card
  /// number (13 or more digits) or a key (32 or more hexadecimal digits).
  /// Any other host, such as `h.example;password=hunter2`, is written as
  /// `[R]`, followed by nothing: `GET https://[R]`.
  String describe() => '$method ${_describeOrigin(uri)}';

  @override
  String toString() => 'ForgeRequest(${describe()})';
}

final RegExp _dnsLabel = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$');
final RegExp _ipv6 = RegExp(r'^[0-9A-Fa-f:.]+$');
final RegExp _longDigits = RegExp(r'^\d{13,}$');
final RegExp _longHex = RegExp(r'^[0-9A-Fa-f]{32,}$');
const int _maxHostLength = 253;

// The scheme, host and port of `uri` for a message, with a host that is not
// a plain name or address written as `[R]`; see ForgeRequest.describe.
String _describeOrigin(Uri uri) {
  final host = uri.host;
  final port = uri.hasPort ? ':${uri.port}' : '';
  if (host.contains(':')) {
    return _ipv6.hasMatch(host) ? '${uri.scheme}://[$host]$port' : '${uri.scheme}://[R]';
  }
  final labels = host.split('.');
  final plain =
      host.length <= _maxHostLength &&
      labels.every(_dnsLabel.hasMatch) &&
      !labels.any((label) => _longDigits.hasMatch(label) || _longHex.hasMatch(label));
  return plain ? '${uri.scheme}://$host$port' : '${uri.scheme}://[R]';
}

String _checkedMethod(String method) {
  if (!_token.hasMatch(method)) {
    throw ArgumentError.value(method, 'method', 'is not an HTTP token');
  }
  return method.toUpperCase();
}

Map<String, String> _checkedHeaders(Map<String, String> headers) {
  final checked = <String, String>{};
  for (final MapEntry(:key, :value) in headers.entries) {
    if (!_token.hasMatch(key)) {
      throw ArgumentError.value(key, 'headers', 'has a name that is not an HTTP token');
    }
    if (value.contains('\r') || value.contains('\n') || value.contains('\u0000')) {
      throw ArgumentError('The value of header "$key" contains a line break or NUL character.', 'headers');
    }
    checked[key.toLowerCase()] = value;
  }
  return checked;
}
