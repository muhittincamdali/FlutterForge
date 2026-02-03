/// HTTP interceptors for request/response modification.
///
/// Provides common interceptor implementations for authentication,
/// logging, caching, and error handling.
library;

import 'dart:convert';

import 'api_client.dart';

/// Interceptor for adding authentication headers.
class AuthInterceptor extends RequestInterceptor {
  /// Creates a new [AuthInterceptor].
  AuthInterceptor({
    required this.getAccessToken,
    this.getRefreshToken,
    this.onTokenRefresh,
    this.headerName = 'Authorization',
    this.tokenPrefix = 'Bearer ',
  });

  /// Function to get the current access token.
  final Future<String?> Function() getAccessToken;

  /// Function to get the refresh token.
  final Future<String?> Function()? getRefreshToken;

  /// Callback when token is refreshed.
  final Future<void> Function(String newToken)? onTokenRefresh;

  /// Header name for the token.
  final String headerName;

  /// Prefix for the token value.
  final String tokenPrefix;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      final headers = Map<String, String>.from(options.headers ?? {});
      headers[headerName] = '$tokenPrefix$token';
      return options.copyWith(headers: headers);
    }
    return options;
  }

  @override
  Future<void> onError(ApiException error) async {
    if (error.isUnauthorized && getRefreshToken != null) {
      // Token refresh logic could be implemented here
    }
  }
}

/// Interceptor for logging requests and responses.
class LoggingInterceptor extends RequestInterceptor {
  /// Creates a new [LoggingInterceptor].
  LoggingInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logHeaders = false,
    this.logBody = true,
    this.maxBodyLength = 1000,
    this.logger,
  });

  /// Whether to log requests.
  final bool logRequest;

  /// Whether to log responses.
  final bool logResponse;

  /// Whether to log headers.
  final bool logHeaders;

  /// Whether to log body.
  final bool logBody;

  /// Maximum body length to log.
  final int maxBodyLength;

  /// Custom logger function.
  final void Function(String)? logger;

  void _log(String message) {
    if (logger != null) {
      logger!(message);
    } else {
      print(message);
    }
  }

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    if (!logRequest) return options;

    final buffer = StringBuffer();
    buffer.writeln('┌────── Request ──────');
    buffer.writeln('│ ${options.method.name} ${options.path}');

    if (logHeaders && options.headers != null) {
      buffer.writeln('│ Headers:');
      options.headers!.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    if (logBody && options.body != null) {
      buffer.writeln('│ Body:');
      final bodyStr = _formatBody(options.body);
      buffer.writeln('│   $bodyStr');
    }

    buffer.writeln('└─────────────────────');
    _log(buffer.toString());

    return options;
  }

  @override
  Future<ApiResponse<dynamic>> onResponse(
      ApiResponse<dynamic> response) async {
    if (!logResponse) return response;

    final buffer = StringBuffer();
    buffer.writeln('┌────── Response ──────');
    buffer.writeln('│ Status: ${response.statusCode}');

    if (logHeaders) {
      buffer.writeln('│ Headers:');
      response.headers.forEach((key, values) {
        buffer.writeln('│   $key: ${values.join(', ')}');
      });
    }

    if (logBody && response.data != null) {
      buffer.writeln('│ Body:');
      final bodyStr = _formatBody(response.data);
      buffer.writeln('│   $bodyStr');
    }

    buffer.writeln('└──────────────────────');
    _log(buffer.toString());

    return response;
  }

  @override
  Future<void> onError(ApiException error) async {
    final buffer = StringBuffer();
    buffer.writeln('┌────── Error ──────');
    buffer.writeln('│ Status: ${error.statusCode}');
    buffer.writeln('│ Message: ${error.message}');
    if (error.data != null) {
      buffer.writeln('│ Data: ${_formatBody(error.data)}');
    }
    buffer.writeln('└───────────────────');
    _log(buffer.toString());
  }

  String _formatBody(dynamic body) {
    String result;
    if (body is Map || body is List) {
      try {
        result = const JsonEncoder.withIndent('  ').convert(body);
      } catch (_) {
        result = body.toString();
      }
    } else {
      result = body.toString();
    }

    if (result.length > maxBodyLength) {
      result = '${result.substring(0, maxBodyLength)}... [truncated]';
    }

    return result;
  }
}

/// Interceptor for retry logic.
class RetryInterceptor extends RequestInterceptor {
  /// Creates a new [RetryInterceptor].
  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const {408, 500, 502, 503, 504},
    this.shouldRetry,
  });

  /// Maximum number of retries.
  final int maxRetries;

  /// Delay between retries.
  final Duration retryDelay;

  /// Status codes that should trigger a retry.
  final Set<int> retryStatusCodes;

  /// Custom function to determine if a request should be retried.
  final bool Function(ApiException)? shouldRetry;

  int _currentRetry = 0;

  @override
  Future<void> onError(ApiException error) async {
    final shouldRetryRequest = shouldRetry?.call(error) ??
        (error.isNetworkError ||
            error.isTimeout ||
            retryStatusCodes.contains(error.statusCode));

    if (shouldRetryRequest && _currentRetry < maxRetries) {
      _currentRetry++;
      await Future.delayed(retryDelay * _currentRetry);
      // Retry logic would need access to original request
    } else {
      _currentRetry = 0;
    }
  }
}

/// Interceptor for caching responses.
class CacheInterceptor extends RequestInterceptor {
  /// Creates a new [CacheInterceptor].
  CacheInterceptor({
    this.maxAge = const Duration(minutes: 5),
    this.maxEntries = 100,
    this.cacheableMethods = const {HttpMethod.get},
    this.shouldCache,
  });

  /// Maximum age of cached entries.
  final Duration maxAge;

  /// Maximum number of cache entries.
  final int maxEntries;

  /// HTTP methods that should be cached.
  final Set<HttpMethod> cacheableMethods;

  /// Custom function to determine if a response should be cached.
  final bool Function(ApiResponse<dynamic>)? shouldCache;

  final Map<String, _CacheEntry> _cache = {};

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    if (!cacheableMethods.contains(options.method)) {
      return options;
    }

    final key = _getCacheKey(options);
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      // Return cached response by setting extra data
      return options.copyWith(
        extra: {...?options.extra, '_cachedResponse': entry.response},
      );
    }

    return options;
  }

  @override
  Future<ApiResponse<dynamic>> onResponse(
      ApiResponse<dynamic> response) async {
    final options = response.requestOptions;
    if (options == null || !cacheableMethods.contains(options.method)) {
      return response;
    }

    final shouldCacheResponse = shouldCache?.call(response) ?? response.isSuccess;
    if (shouldCacheResponse) {
      final key = _getCacheKey(options);
      _cache[key] = _CacheEntry(
        response: response,
        timestamp: DateTime.now(),
        maxAge: maxAge,
      );

      // Cleanup old entries if needed
      if (_cache.length > maxEntries) {
        _cleanupCache();
      }
    }

    return response;
  }

  String _getCacheKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(options.method.name);
    buffer.write(':');
    buffer.write(options.path);
    if (options.queryParameters != null) {
      buffer.write('?');
      buffer.write(options.queryParameters.toString());
    }
    return buffer.toString();
  }

  void _cleanupCache() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => entry.isExpired);

    // Remove oldest entries if still over limit
    while (_cache.length > maxEntries) {
      String? oldestKey;
      DateTime? oldestTime;

      for (final entry in _cache.entries) {
        if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
          oldestKey = entry.key;
          oldestTime = entry.value.timestamp;
        }
      }

      if (oldestKey != null) {
        _cache.remove(oldestKey);
      }
    }
  }

  /// Clears the cache.
  void clearCache() {
    _cache.clear();
  }

  /// Invalidates a specific cache entry.
  void invalidate(String path) {
    _cache.removeWhere((key, _) => key.contains(path));
  }
}

class _CacheEntry {
  const _CacheEntry({
    required this.response,
    required this.timestamp,
    required this.maxAge,
  });

  final ApiResponse<dynamic> response;
  final DateTime timestamp;
  final Duration maxAge;

  bool get isExpired => DateTime.now().difference(timestamp) > maxAge;
}

/// Interceptor for adding custom headers.
class HeadersInterceptor extends RequestInterceptor {
  /// Creates a new [HeadersInterceptor].
  HeadersInterceptor(this.headers);

  /// Headers to add to requests.
  final Map<String, String> headers;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    return options.copyWith(
      headers: {...?options.headers, ...headers},
    );
  }
}

/// Interceptor for request timeout.
class TimeoutInterceptor extends RequestInterceptor {
  /// Creates a new [TimeoutInterceptor].
  TimeoutInterceptor({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    return options.copyWith(
      timeout: options.timeout ?? receiveTimeout,
    );
  }
}

/// Interceptor for error transformation.
class ErrorInterceptor extends RequestInterceptor {
  /// Creates a new [ErrorInterceptor].
  ErrorInterceptor({this.errorMapper});

  /// Custom error mapper.
  final ApiException Function(ApiException)? errorMapper;

  @override
  Future<void> onError(ApiException error) async {
    if (errorMapper != null) {
      throw errorMapper!(error);
    }
  }
}

/// Interceptor for request/response encoding.
class EncodingInterceptor extends RequestInterceptor {
  /// Creates a new [EncodingInterceptor].
  EncodingInterceptor({
    this.requestEncoding = 'utf-8',
    this.responseEncoding = 'utf-8',
  });

  /// Request encoding.
  final String requestEncoding;

  /// Response encoding.
  final String responseEncoding;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    final headers = Map<String, String>.from(options.headers ?? {});
    headers['Accept-Charset'] = responseEncoding;
    return options.copyWith(headers: headers);
  }
}

/// Interceptor for tracking request metrics.
class MetricsInterceptor extends RequestInterceptor {
  /// Creates a new [MetricsInterceptor].
  MetricsInterceptor({this.onMetric});

  /// Callback for metrics.
  final void Function(RequestMetric)? onMetric;

  final Map<String, DateTime> _startTimes = {};

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    _startTimes[options.path] = DateTime.now();
    return options;
  }

  @override
  Future<ApiResponse<dynamic>> onResponse(
      ApiResponse<dynamic> response) async {
    final path = response.requestOptions?.path;
    if (path != null) {
      final startTime = _startTimes.remove(path);
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        onMetric?.call(RequestMetric(
          path: path,
          method: response.requestOptions!.method,
          statusCode: response.statusCode,
          duration: duration,
        ));
      }
    }
    return response;
  }
}

/// Request metric data.
class RequestMetric {
  /// Creates a new [RequestMetric].
  const RequestMetric({
    required this.path,
    required this.method,
    required this.statusCode,
    required this.duration,
  });

  /// Request path.
  final String path;

  /// HTTP method.
  final HttpMethod method;

  /// Response status code.
  final int statusCode;

  /// Request duration.
  final Duration duration;
}
