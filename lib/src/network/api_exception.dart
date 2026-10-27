import 'forge_request.dart';
import 'forge_response.dart';

/// The errors a `ForgeClient` throws.
///
/// The class is sealed, so a `switch` over it is checked for completeness:
///
/// ```dart
/// String message(ApiException error) => switch (error) {
///       ConnectionException() => 'You appear to be offline.',
///       RequestTimeoutException() => 'The server took too long to answer.',
///       RequestCancelledException() => 'Cancelled.',
///       HttpStatusException(:final statusCode) => 'The server answered $statusCode.',
///       DecodingException() => 'The server sent data the app cannot read.',
///       ResponseTooLargeException() => 'The response was too large.',
///       RedirectException() => 'The server redirected the request somewhere unsafe.',
///     };
/// ```
///
/// [toString] names the method and host only. The path, query, headers and
/// body are left out, so printing an exception does not copy identifiers or
/// tokens into a log.
sealed class ApiException implements Exception {
  const ApiException(this.request, [this.cause]);

  /// The request that failed.
  final ForgeRequest request;

  /// The lower-level error, when there is one.
  final Object? cause;

  /// Whether sending the same request again may succeed.
  bool get isTransient;

  String get _kind;

  String get _detail => '';

  @override
  String toString() => '$_kind: ${request.describe()}$_detail';
}

/// The server could not be reached: no network, DNS failure, refused or
/// reset connection, TLS failure.
final class ConnectionException extends ApiException {
  /// Creates the exception.
  const ConnectionException(super.request, [super.cause]);

  @override
  bool get isTransient => true;

  @override
  String get _kind => 'ConnectionException';
}

/// An attempt took longer than its time limit.
final class RequestTimeoutException extends ApiException {
  /// Creates the exception.
  const RequestTimeoutException(super.request, this.timeout);

  /// The time limit that was exceeded.
  final Duration timeout;

  @override
  bool get isTransient => true;

  @override
  String get _kind => 'RequestTimeoutException';

  @override
  String get _detail => ' (after ${timeout.inMilliseconds} ms)';
}

/// The request was cancelled through its `CancelToken`.
final class RequestCancelledException extends ApiException {
  /// Creates the exception.
  const RequestCancelledException(super.request);

  @override
  bool get isTransient => false;

  @override
  String get _kind => 'RequestCancelledException';
}

/// The server answered with a status code outside the 2xx range.
final class HttpStatusException extends ApiException {
  /// Creates the exception.
  HttpStatusException(this.response) : super(response.request);

  /// The response, including its body.
  final ForgeResponse response;

  /// The status code of [response].
  int get statusCode => response.statusCode;

  @override
  bool get isTransient => statusCode == 408 || statusCode == 429 || statusCode >= 500;

  @override
  String get _kind => 'HttpStatusException';

  @override
  String get _detail => ' answered $statusCode';
}

/// The body could not be read as the expected data: invalid UTF-8, invalid
/// JSON, or a decode function that threw.
final class DecodingException extends ApiException {
  /// Creates the exception.
  const DecodingException(super.request, super.cause, {this.response});

  /// The response whose body could not be decoded.
  final ForgeResponse? response;

  @override
  bool get isTransient => false;

  @override
  String get _kind => 'DecodingException';

  @override
  String get _detail => ' (${cause.runtimeType})';
}

/// The response body was longer than the client's `maxResponseBytes`.
///
/// The client stops reading at the limit, so a large or endless response does
/// not fill the memory of the app.
final class ResponseTooLargeException extends ApiException {
  /// Creates the exception.
  const ResponseTooLargeException(super.request, this.limit);

  /// The limit in bytes.
  final int limit;

  @override
  bool get isTransient => false;

  @override
  String get _kind => 'ResponseTooLargeException';

  @override
  String get _detail => ' (limit $limit bytes)';
}

/// A redirect was not followed because it was unsafe or there were too many.
final class RedirectException extends ApiException {
  /// Creates the exception.
  const RedirectException(super.request, this.reason);

  /// Why the redirect was refused.
  final String reason;

  @override
  bool get isTransient => false;

  @override
  String get _kind => 'RedirectException';

  @override
  String get _detail => ': $reason';
}
