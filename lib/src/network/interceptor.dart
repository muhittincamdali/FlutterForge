import 'forge_request.dart';
import 'forge_response.dart';

/// Sends a request to the rest of the chain and returns its response.
typedef RequestHandler = Future<ForgeResponse> Function(ForgeRequest request);

/// A step between a `ForgeClient` call and the network.
///
/// An interceptor receives the request and the [RequestHandler] for the rest
/// of the chain. It may change the request, call `next` any number of times,
/// change the response, or answer without calling `next` at all:
///
/// ```dart
/// final class AppVersionHeader implements Interceptor {
///   @override
///   Future<ForgeResponse> intercept(ForgeRequest request, RequestHandler next) =>
///       next(request.withHeaders(add: {'x-app-version': '4.2.0'}));
/// }
/// ```
///
/// Interceptors run in list order on the way out and in reverse order on the
/// way back, like the layers of an onion.
abstract interface class Interceptor {
  /// Creates an interceptor from a function.
  factory Interceptor.from(Future<ForgeResponse> Function(ForgeRequest request, RequestHandler next) intercept) =
      _FunctionInterceptor;

  /// Handles [request], usually by calling [next].
  Future<ForgeResponse> intercept(ForgeRequest request, RequestHandler next);
}

final class _FunctionInterceptor implements Interceptor {
  _FunctionInterceptor(this._intercept);

  final Future<ForgeResponse> Function(ForgeRequest request, RequestHandler next) _intercept;

  @override
  Future<ForgeResponse> intercept(ForgeRequest request, RequestHandler next) => _intercept(request, next);
}

/// Wraps [last] in [interceptors], the first interceptor being the outermost.
RequestHandler buildChain(List<Interceptor> interceptors, RequestHandler last) {
  var handler = last;
  for (final interceptor in interceptors.reversed) {
    final next = handler;
    handler = (request) => interceptor.intercept(request, next);
  }
  return handler;
}
