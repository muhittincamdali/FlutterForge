import 'dart:convert';
import 'dart:typed_data';

import 'api_exception.dart';
import 'forge_request.dart';

/// A complete HTTP response, read into memory.
final class ForgeResponse {
  /// Creates a response.
  ForgeResponse({
    required this.statusCode,
    required this.request,
    Map<String, String> headers = const {},
    Uint8List? bodyBytes,
    this.reasonPhrase,
    this.fromCache = false,
  }) : headers = Map.unmodifiable({for (final MapEntry(:key, :value) in headers.entries) key.toLowerCase(): value}),
       bodyBytes = bodyBytes ?? Uint8List(0);

  /// The status code, such as `200` or `404`.
  final int statusCode;

  /// The request that produced this response. After a redirect it is the
  /// request sent to the final URL.
  final ForgeRequest request;

  /// The headers, with lower-case names.
  final Map<String, String> headers;

  /// The body as bytes.
  final Uint8List bodyBytes;

  /// The reason phrase sent by the server, if any.
  final String? reasonPhrase;

  /// Whether the response came from a cache instead of the network.
  final bool fromCache;

  /// Whether the status code is in the 2xx range.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// The value of the header [name], compared without regard to case.
  String? header(String name) => headers[name.toLowerCase()];

  /// The body decoded as UTF-8. Invalid byte sequences become U+FFFD.
  String get text => utf8.decode(bodyBytes, allowMalformed: true);

  /// The body parsed as JSON, or `null` for an empty body.
  ///
  /// Throws a [DecodingException] when the body is not valid UTF-8 or not
  /// valid JSON.
  Object? json() {
    if (bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(bodyBytes));
    } on FormatException catch (error) {
      throw DecodingException(request, error, response: this);
    }
  }

  /// Returns a copy with the given fields replaced.
  ForgeResponse copyWith({ForgeRequest? request, Map<String, String>? headers, bool? fromCache}) {
    return ForgeResponse(
      statusCode: statusCode,
      request: request ?? this.request,
      headers: headers ?? this.headers,
      bodyBytes: bodyBytes,
      reasonPhrase: reasonPhrase,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  String toString() => 'ForgeResponse($statusCode, ${request.describe()})';
}
