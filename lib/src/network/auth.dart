import 'dart:async';

import 'forge_request.dart';
import 'forge_response.dart';
import 'interceptor.dart';

/// Returns the current access token, or `null` when the user is signed out.
typedef TokenReader = FutureOr<String?> Function();

/// Gets a new access token after the server rejected the current one, or
/// returns `null` when that is not possible (the user must sign in again).
///
/// Store the new token before returning it, so that the [TokenReader]
/// returns it from then on.
typedef TokenRefresher = Future<String?> Function();

/// Adds `Authorization: Bearer <token>` to requests for the trusted origins
/// and refreshes the token once when the server answers `401`.
///
/// When several requests fail with `401` at the same time, they share one
/// call to the refresher and are then sent again with the new token. A
/// request is sent again at most once, so a server that keeps answering `401`
/// does not cause a loop.
///
/// The token is only added for the trusted origins (scheme, host and port), so a
/// request to an absolute URL on another host, such as a link to a CDN, does
/// not carry it. `ForgeClient` passes the origin of its base URL, and drops the
/// header itself when a redirect leaves that origin.
final class BearerAuthInterceptor implements Interceptor {
  /// Creates the interceptor.
  ///
  /// Throws an [ArgumentError] when [trustedOrigins] is empty.
  BearerAuthInterceptor({required this._readToken, required Iterable<Uri> trustedOrigins, this._refreshToken})
    : _origins = trustedOrigins.map(_origin).toSet() {
    if (_origins.isEmpty) {
      throw ArgumentError.value(trustedOrigins, 'trustedOrigins', 'must not be empty');
    }
  }

  final TokenReader _readToken;
  final TokenRefresher? _refreshToken;
  final Set<String> _origins;
  Future<String?>? _refreshing;

  static String _origin(Uri uri) => '${uri.scheme}://${uri.host}:${uri.port}';

  @override
  Future<ForgeResponse> intercept(ForgeRequest request, RequestHandler next) async {
    if (!_origins.contains(_origin(request.uri))) {
      return next(request);
    }
    final token = await _readToken();
    final response = await next(_authorized(request, token));
    final refresh = _refreshToken;
    if (response.statusCode != 401 || refresh == null || token == null) return response;

    final current = await _readToken();
    final fresh = current != null && current != token ? current : await _sharedRefresh(refresh);
    if (fresh == null || fresh == token) return response;
    return next(_authorized(request, fresh));
  }

  Future<String?> _sharedRefresh(TokenRefresher refresh) {
    return _refreshing ??= refresh().whenComplete(() => _refreshing = null);
  }

  ForgeRequest _authorized(ForgeRequest request, String? token) {
    if (token == null || token.isEmpty) {
      return request.withHeaders(remove: const ['authorization']);
    }
    return request.withHeaders(add: {'authorization': 'Bearer $token'});
  }
}

/// Settings for the bearer token support of `ForgeClient`.
final class BearerAuth {
  /// Creates the settings. See [BearerAuthInterceptor].
  const BearerAuth({required this.readToken, this.refreshToken});

  /// Returns the current token.
  final TokenReader readToken;

  /// Gets a new token after a `401` answer.
  final TokenRefresher? refreshToken;
}
