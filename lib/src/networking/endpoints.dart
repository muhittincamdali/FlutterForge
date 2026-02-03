/// API endpoint definitions and URL builders.
///
/// Provides a type-safe way to define and construct API endpoints.
library;

/// Base class for API endpoints.
abstract class Endpoints {
  /// Creates a new [Endpoints] instance.
  const Endpoints();

  /// The base path for all endpoints in this group.
  String get basePath;

  /// Builds a full path with the given segments.
  String buildPath(List<String> segments) {
    return [basePath, ...segments].join('/');
  }

  /// Builds a path with a single ID parameter.
  String withId(String id) => buildPath([id]);

  /// Builds a path with query parameters.
  String withQuery(String path, Map<String, dynamic> params) {
    if (params.isEmpty) return path;

    final queryString = params.entries
        .where((e) => e.value != null)
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return queryString.isEmpty ? path : '$path?$queryString';
  }
}

/// Authentication endpoints.
class AuthEndpoints extends Endpoints {
  /// Creates a new [AuthEndpoints] instance.
  const AuthEndpoints();

  @override
  String get basePath => '/auth';

  /// Login endpoint.
  String get login => buildPath(['login']);

  /// Register endpoint.
  String get register => buildPath(['register']);

  /// Logout endpoint.
  String get logout => buildPath(['logout']);

  /// Refresh token endpoint.
  String get refresh => buildPath(['refresh']);

  /// Forgot password endpoint.
  String get forgotPassword => buildPath(['forgot-password']);

  /// Reset password endpoint.
  String get resetPassword => buildPath(['reset-password']);

  /// Verify email endpoint.
  String get verifyEmail => buildPath(['verify-email']);

  /// Resend verification endpoint.
  String get resendVerification => buildPath(['resend-verification']);

  /// Social login endpoint.
  String socialLogin(String provider) => buildPath(['social', provider]);
}

/// User endpoints.
class UserEndpoints extends Endpoints {
  /// Creates a new [UserEndpoints] instance.
  const UserEndpoints();

  @override
  String get basePath => '/users';

  /// Get all users.
  String get all => basePath;

  /// Get current user.
  String get me => buildPath(['me']);

  /// Get user by ID.
  String byId(String id) => withId(id);

  /// Get user profile.
  String profile(String id) => buildPath([id, 'profile']);

  /// Update user avatar.
  String avatar(String id) => buildPath([id, 'avatar']);

  /// Get user settings.
  String settings(String id) => buildPath([id, 'settings']);

  /// User search.
  String search(String query) => withQuery(basePath, {'q': query});

  /// Paginated users.
  String paginated({int page = 1, int limit = 20}) =>
      withQuery(basePath, {'page': page, 'limit': limit});
}

/// Resource endpoints (generic CRUD).
class ResourceEndpoints<T> extends Endpoints {
  /// Creates a new [ResourceEndpoints] instance.
  const ResourceEndpoints(this.resourceName);

  /// The resource name.
  final String resourceName;

  @override
  String get basePath => '/$resourceName';

  /// Get all resources.
  String get all => basePath;

  /// Get resource by ID.
  String byId(String id) => withId(id);

  /// Create resource.
  String get create => basePath;

  /// Update resource.
  String update(String id) => withId(id);

  /// Delete resource.
  String delete(String id) => withId(id);

  /// Search resources.
  String search(String query) => withQuery(basePath, {'q': query});

  /// Paginated resources.
  String paginated({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) {
    return withQuery(basePath, {
      'page': page,
      'limit': limit,
      if (sortBy != null) 'sort': sortBy,
      if (sortBy != null) 'order': ascending ? 'asc' : 'desc',
    });
  }

  /// Filtered resources.
  String filtered(Map<String, dynamic> filters) =>
      withQuery(basePath, filters);
}

/// API version wrapper.
class VersionedEndpoints {
  /// Creates a new [VersionedEndpoints] instance.
  const VersionedEndpoints({
    this.version = 'v1',
    this.auth = const AuthEndpoints(),
    this.users = const UserEndpoints(),
  });

  /// API version.
  final String version;

  /// Authentication endpoints.
  final AuthEndpoints auth;

  /// User endpoints.
  final UserEndpoints users;

  /// Gets the versioned path.
  String versionedPath(String path) => '/$version$path';

  /// Creates resource endpoints.
  ResourceEndpoints<T> resource<T>(String name) =>
      ResourceEndpoints<T>('$version/$name');
}

/// URL builder utility.
class UrlBuilder {
  /// Creates a new [UrlBuilder].
  UrlBuilder({
    required this.baseUrl,
    this.defaultHeaders = const {},
  });

  /// Base URL.
  final String baseUrl;

  /// Default headers.
  final Map<String, String> defaultHeaders;

  /// Builds a full URL.
  Uri build(String path, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  /// Builds a URL with path parameters.
  Uri buildWithParams(
    String path,
    Map<String, String> pathParams, {
    Map<String, dynamic>? queryParameters,
  }) {
    var resolvedPath = path;
    pathParams.forEach((key, value) {
      resolvedPath = resolvedPath.replaceAll(':$key', value);
      resolvedPath = resolvedPath.replaceAll('{$key}', value);
    });
    return build(resolvedPath, queryParameters: queryParameters);
  }
}

/// API configuration.
class ApiConfig {
  /// Creates a new [ApiConfig].
  const ApiConfig({
    required this.baseUrl,
    this.version = 'v1',
    this.timeout = const Duration(seconds: 30),
    this.headers = const {},
  });

  /// Development configuration.
  factory ApiConfig.development() => const ApiConfig(
        baseUrl: 'http://localhost:3000/api',
        version: 'v1',
      );

  /// Staging configuration.
  factory ApiConfig.staging() => const ApiConfig(
        baseUrl: 'https://staging-api.example.com/api',
        version: 'v1',
      );

  /// Production configuration.
  factory ApiConfig.production() => const ApiConfig(
        baseUrl: 'https://api.example.com/api',
        version: 'v1',
      );

  /// Base URL.
  final String baseUrl;

  /// API version.
  final String version;

  /// Request timeout.
  final Duration timeout;

  /// Default headers.
  final Map<String, String> headers;

  /// Full base URL with version.
  String get fullBaseUrl => '$baseUrl/$version';

  /// Creates a copy with updated values.
  ApiConfig copyWith({
    String? baseUrl,
    String? version,
    Duration? timeout,
    Map<String, String>? headers,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      version: version ?? this.version,
      timeout: timeout ?? this.timeout,
      headers: headers ?? this.headers,
    );
  }
}

/// Environment-based API configuration.
class EnvironmentConfig {
  EnvironmentConfig._();

  static ApiConfig _current = ApiConfig.development();

  /// The current configuration.
  static ApiConfig get current => _current;

  /// Sets up for development.
  static void development() => _current = ApiConfig.development();

  /// Sets up for staging.
  static void staging() => _current = ApiConfig.staging();

  /// Sets up for production.
  static void production() => _current = ApiConfig.production();

  /// Sets a custom configuration.
  static void custom(ApiConfig config) => _current = config;
}
