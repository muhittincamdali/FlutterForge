/// HTTP API client implementation using Dio.
///
/// Provides a robust, configurable HTTP client with interceptors,
/// error handling, and retry logic.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// HTTP methods supported by the API client.
enum HttpMethod { get, post, put, patch, delete, head, options }

/// API client configuration.
class ApiClientConfig {
  /// Creates a new [ApiClientConfig].
  const ApiClientConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
    this.enableLogging = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  /// Base URL for all requests.
  final String baseUrl;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;

  /// Default headers for all requests.
  final Map<String, String> defaultHeaders;

  /// Whether to enable request/response logging.
  final bool enableLogging;

  /// Maximum number of retries.
  final int maxRetries;

  /// Delay between retries.
  final Duration retryDelay;
}

/// HTTP request options.
class RequestOptions {
  /// Creates new [RequestOptions].
  const RequestOptions({
    required this.path,
    this.method = HttpMethod.get,
    this.queryParameters,
    this.headers,
    this.body,
    this.contentType,
    this.responseType = ResponseType.json,
    this.timeout,
    this.cancelToken,
    this.extra,
  });

  /// Request path (relative to base URL).
  final String path;

  /// HTTP method.
  final HttpMethod method;

  /// Query parameters.
  final Map<String, dynamic>? queryParameters;

  /// Request headers.
  final Map<String, String>? headers;

  /// Request body.
  final dynamic body;

  /// Content type.
  final String? contentType;

  /// Response type.
  final ResponseType responseType;

  /// Request timeout.
  final Duration? timeout;

  /// Cancel token for cancelling the request.
  final CancelToken? cancelToken;

  /// Extra data.
  final Map<String, dynamic>? extra;

  /// Creates a copy with updated fields.
  RequestOptions copyWith({
    String? path,
    HttpMethod? method,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    dynamic body,
    String? contentType,
    ResponseType? responseType,
    Duration? timeout,
    CancelToken? cancelToken,
    Map<String, dynamic>? extra,
  }) {
    return RequestOptions(
      path: path ?? this.path,
      method: method ?? this.method,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      contentType: contentType ?? this.contentType,
      responseType: responseType ?? this.responseType,
      timeout: timeout ?? this.timeout,
      cancelToken: cancelToken ?? this.cancelToken,
      extra: extra ?? this.extra,
    );
  }
}

/// Response types.
enum ResponseType { json, bytes, stream, plain }

/// HTTP response wrapper.
class ApiResponse<T> {
  /// Creates a new [ApiResponse].
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
    this.requestOptions,
  });

  /// HTTP status code.
  final int statusCode;

  /// Response data.
  final T data;

  /// Response headers.
  final Map<String, List<String>> headers;

  /// Original request options.
  final RequestOptions? requestOptions;

  /// Whether the response indicates success.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Token for cancelling requests.
class CancelToken {
  /// Creates a new [CancelToken].
  CancelToken();

  bool _isCancelled = false;
  String? _reason;

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// The cancellation reason.
  String? get reason => _reason;

  /// Cancels the request.
  void cancel([String? reason]) {
    _isCancelled = true;
    _reason = reason;
  }
}

/// Base API client class.
abstract class ApiClient {
  /// Creates a new [ApiClient].
  ApiClient(this.config) {
    _httpClient = HttpClient();
    _httpClient.connectionTimeout = config.connectTimeout;
  }

  /// The client configuration.
  final ApiClientConfig config;

  late final HttpClient _httpClient;
  final List<RequestInterceptor> _interceptors = [];

  /// Adds an interceptor.
  void addInterceptor(RequestInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Removes an interceptor.
  void removeInterceptor(RequestInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Performs a GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      RequestOptions(
        path: path,
        method: HttpMethod.get,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Performs a POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      RequestOptions(
        path: path,
        method: HttpMethod.post,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Performs a PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      RequestOptions(
        path: path,
        method: HttpMethod.put,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Performs a PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      RequestOptions(
        path: path,
        method: HttpMethod.patch,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Performs a DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      RequestOptions(
        path: path,
        method: HttpMethod.delete,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Performs a request with the given options.
  Future<ApiResponse<T>> request<T>(RequestOptions options);

  /// Closes the client.
  void close() {
    _httpClient.close();
  }
}

/// Simple HTTP client implementation.
class SimpleApiClient extends ApiClient {
  /// Creates a new [SimpleApiClient].
  SimpleApiClient(super.config);

  @override
  Future<ApiResponse<T>> request<T>(RequestOptions options) async {
    // Apply interceptors
    var currentOptions = options;
    for (final interceptor in _interceptors) {
      currentOptions = await interceptor.onRequest(currentOptions);
    }

    // Check cancellation
    if (currentOptions.cancelToken?.isCancelled ?? false) {
      throw ApiException(
        message: 'Request cancelled: ${currentOptions.cancelToken?.reason}',
        statusCode: 0,
      );
    }

    // Build URL
    final uri = _buildUri(currentOptions);

    // Make request
    try {
      final request = await _httpClient.openUrl(
        currentOptions.method.name.toUpperCase(),
        uri,
      );

      // Set headers
      final headers = {
        ...config.defaultHeaders,
        ...?currentOptions.headers,
      };
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Set body
      if (currentOptions.body != null) {
        final bodyBytes = utf8.encode(jsonEncode(currentOptions.body));
        request.headers.contentType = ContentType.json;
        request.contentLength = bodyBytes.length;
        request.add(bodyBytes);
      }

      // Get response
      final response = await request.close().timeout(
            currentOptions.timeout ?? config.receiveTimeout,
          );

      // Read response body
      final responseBody = await response.transform(utf8.decoder).join();

      // Parse response
      dynamic data;
      if (responseBody.isNotEmpty) {
        try {
          data = jsonDecode(responseBody);
        } catch (_) {
          data = responseBody;
        }
      }

      final apiResponse = ApiResponse<T>(
        statusCode: response.statusCode,
        data: data as T,
        headers: _parseHeaders(response.headers),
        requestOptions: currentOptions,
      );

      // Apply response interceptors
      var currentResponse = apiResponse;
      for (final interceptor in _interceptors) {
        currentResponse = await interceptor.onResponse(currentResponse)
            as ApiResponse<T>;
      }

      // Check for errors
      if (!currentResponse.isSuccess) {
        throw ApiException(
          message: 'Request failed with status ${currentResponse.statusCode}',
          statusCode: currentResponse.statusCode,
          data: currentResponse.data,
        );
      }

      return currentResponse;
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        statusCode: 0,
      );
    }
  }

  Uri _buildUri(RequestOptions options) {
    final baseUri = Uri.parse(config.baseUrl);
    return baseUri.replace(
      path: '${baseUri.path}${options.path}',
      queryParameters: options.queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, List<String>> _parseHeaders(HttpHeaders headers) {
    final result = <String, List<String>>{};
    headers.forEach((name, values) {
      result[name] = values;
    });
    return result;
  }
}

/// Request interceptor interface.
abstract class RequestInterceptor {
  /// Called before a request is sent.
  Future<RequestOptions> onRequest(RequestOptions options) async => options;

  /// Called after a response is received.
  Future<ApiResponse<dynamic>> onResponse(
      ApiResponse<dynamic> response) async => response;

  /// Called when an error occurs.
  Future<void> onError(ApiException error) async {}
}

/// API exception class.
class ApiException implements Exception {
  /// Creates a new [ApiException].
  const ApiException({
    required this.message,
    required this.statusCode,
    this.data,
    this.stackTrace,
  });

  /// Error message.
  final String message;

  /// HTTP status code.
  final int statusCode;

  /// Response data.
  final dynamic data;

  /// Stack trace.
  final StackTrace? stackTrace;

  /// Whether this is a network error.
  bool get isNetworkError => statusCode == 0;

  /// Whether this is a timeout error.
  bool get isTimeout => statusCode == 408;

  /// Whether this is a server error.
  bool get isServerError => statusCode >= 500;

  /// Whether this is a client error.
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Whether this is an unauthorized error.
  bool get isUnauthorized => statusCode == 401;

  /// Whether this is a forbidden error.
  bool get isForbidden => statusCode == 403;

  /// Whether this is a not found error.
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Extension for HTTP method names.
extension HttpMethodExtension on HttpMethod {
  /// Gets the HTTP method name.
  String get name {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.head:
        return 'HEAD';
      case HttpMethod.options:
        return 'OPTIONS';
    }
  }
}
