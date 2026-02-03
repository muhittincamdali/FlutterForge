/// Tests for networking components.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/src/networking/api_client.dart';
import 'package:flutter_forge/src/networking/interceptors.dart';
import 'package:flutter_forge/src/networking/endpoints.dart';

void main() {
  group('ApiClientConfig Tests', () {
    test('creates config with defaults', () {
      const config = ApiClientConfig(baseUrl: 'https://api.example.com');

      expect(config.baseUrl, equals('https://api.example.com'));
      expect(config.connectTimeout, equals(const Duration(seconds: 30)));
      expect(config.maxRetries, equals(3));
    });

    test('creates config with custom values', () {
      const config = ApiClientConfig(
        baseUrl: 'https://api.example.com',
        connectTimeout: Duration(seconds: 60),
        maxRetries: 5,
        enableLogging: false,
      );

      expect(config.connectTimeout, equals(const Duration(seconds: 60)));
      expect(config.maxRetries, equals(5));
      expect(config.enableLogging, isFalse);
    });
  });

  group('RequestOptions Tests', () {
    test('creates options with defaults', () {
      const options = RequestOptions(path: '/users');

      expect(options.path, equals('/users'));
      expect(options.method, equals(HttpMethod.get));
      expect(options.responseType, equals(ResponseType.json));
    });

    test('copyWith creates modified copy', () {
      const original = RequestOptions(
        path: '/users',
        method: HttpMethod.get,
      );

      final modified = original.copyWith(
        method: HttpMethod.post,
        body: {'name': 'John'},
      );

      expect(modified.path, equals('/users'));
      expect(modified.method, equals(HttpMethod.post));
      expect(modified.body, equals({'name': 'John'}));
    });
  });

  group('ApiResponse Tests', () {
    test('isSuccess returns correct value', () {
      const successResponse = ApiResponse<String>(
        statusCode: 200,
        data: 'success',
      );
      expect(successResponse.isSuccess, isTrue);

      const errorResponse = ApiResponse<String>(
        statusCode: 404,
        data: 'not found',
      );
      expect(errorResponse.isSuccess, isFalse);
    });
  });

  group('CancelToken Tests', () {
    test('initially not cancelled', () {
      final token = CancelToken();
      expect(token.isCancelled, isFalse);
    });

    test('cancel sets state', () {
      final token = CancelToken();
      token.cancel('User cancelled');

      expect(token.isCancelled, isTrue);
      expect(token.reason, equals('User cancelled'));
    });
  });

  group('ApiException Tests', () {
    test('identifies network error', () {
      const exception = ApiException(message: 'Network error', statusCode: 0);
      expect(exception.isNetworkError, isTrue);
    });

    test('identifies timeout error', () {
      const exception = ApiException(message: 'Timeout', statusCode: 408);
      expect(exception.isTimeout, isTrue);
    });

    test('identifies server error', () {
      const exception = ApiException(message: 'Server error', statusCode: 500);
      expect(exception.isServerError, isTrue);
    });

    test('identifies client error', () {
      const exception = ApiException(message: 'Not found', statusCode: 404);
      expect(exception.isClientError, isTrue);
      expect(exception.isNotFound, isTrue);
    });

    test('identifies unauthorized', () {
      const exception = ApiException(message: 'Unauthorized', statusCode: 401);
      expect(exception.isUnauthorized, isTrue);
    });

    test('identifies forbidden', () {
      const exception = ApiException(message: 'Forbidden', statusCode: 403);
      expect(exception.isForbidden, isTrue);
    });
  });

  group('HttpMethod Tests', () {
    test('name returns correct string', () {
      expect(HttpMethod.get.name, equals('GET'));
      expect(HttpMethod.post.name, equals('POST'));
      expect(HttpMethod.put.name, equals('PUT'));
      expect(HttpMethod.patch.name, equals('PATCH'));
      expect(HttpMethod.delete.name, equals('DELETE'));
    });
  });

  group('AuthEndpoints Tests', () {
    const endpoints = AuthEndpoints();

    test('generates correct paths', () {
      expect(endpoints.login, equals('/auth/login'));
      expect(endpoints.register, equals('/auth/register'));
      expect(endpoints.logout, equals('/auth/logout'));
      expect(endpoints.refresh, equals('/auth/refresh'));
      expect(endpoints.forgotPassword, equals('/auth/forgot-password'));
    });

    test('social login generates correct path', () {
      expect(endpoints.socialLogin('google'), equals('/auth/social/google'));
      expect(endpoints.socialLogin('facebook'), equals('/auth/social/facebook'));
    });
  });

  group('UserEndpoints Tests', () {
    const endpoints = UserEndpoints();

    test('generates correct paths', () {
      expect(endpoints.all, equals('/users'));
      expect(endpoints.me, equals('/users/me'));
      expect(endpoints.byId('123'), equals('/users/123'));
      expect(endpoints.profile('123'), equals('/users/123/profile'));
    });

    test('search generates correct query', () {
      expect(endpoints.search('john'), equals('/users?q=john'));
    });

    test('paginated generates correct query', () {
      expect(
        endpoints.paginated(page: 2, limit: 10),
        equals('/users?page=2&limit=10'),
      );
    });
  });

  group('ResourceEndpoints Tests', () {
    const endpoints = ResourceEndpoints<dynamic>('products');

    test('generates correct CRUD paths', () {
      expect(endpoints.all, equals('/products'));
      expect(endpoints.byId('123'), equals('/products/123'));
      expect(endpoints.create, equals('/products'));
      expect(endpoints.update('123'), equals('/products/123'));
      expect(endpoints.delete('123'), equals('/products/123'));
    });

    test('paginated generates correct query', () {
      final path = endpoints.paginated(
        page: 1,
        limit: 20,
        sortBy: 'name',
        ascending: false,
      );
      expect(path, contains('page=1'));
      expect(path, contains('limit=20'));
      expect(path, contains('sort=name'));
      expect(path, contains('order=desc'));
    });
  });

  group('ApiConfig Tests', () {
    test('development config', () {
      final config = ApiConfig.development();
      expect(config.baseUrl, contains('localhost'));
    });

    test('staging config', () {
      final config = ApiConfig.staging();
      expect(config.baseUrl, contains('staging'));
    });

    test('production config', () {
      final config = ApiConfig.production();
      expect(config.baseUrl, isNot(contains('localhost')));
      expect(config.baseUrl, isNot(contains('staging')));
    });

    test('fullBaseUrl includes version', () {
      const config = ApiConfig(baseUrl: 'https://api.example.com/api', version: 'v2');
      expect(config.fullBaseUrl, equals('https://api.example.com/api/v2'));
    });

    test('copyWith creates modified config', () {
      const original = ApiConfig(baseUrl: 'https://api.example.com/api');
      final modified = original.copyWith(version: 'v2', timeout: const Duration(seconds: 60));

      expect(modified.version, equals('v2'));
      expect(modified.timeout, equals(const Duration(seconds: 60)));
      expect(modified.baseUrl, equals(original.baseUrl));
    });
  });

  group('UrlBuilder Tests', () {
    late UrlBuilder builder;

    setUp(() {
      builder = UrlBuilder(baseUrl: 'https://api.example.com');
    });

    test('builds simple URL', () {
      final uri = builder.build('/users');
      expect(uri.toString(), equals('https://api.example.com/users'));
    });

    test('builds URL with query parameters', () {
      final uri = builder.build(
        '/users',
        queryParameters: {'page': 1, 'limit': 20},
      );
      expect(uri.toString(), contains('page=1'));
      expect(uri.toString(), contains('limit=20'));
    });

    test('builds URL with path parameters', () {
      final uri = builder.buildWithParams(
        '/users/:id/posts/:postId',
        {'id': '123', 'postId': '456'},
      );
      expect(uri.toString(), contains('/users/123/posts/456'));
    });
  });

  group('RequestMetric Tests', () {
    test('creates metric correctly', () {
      const metric = RequestMetric(
        path: '/users',
        method: HttpMethod.get,
        statusCode: 200,
        duration: Duration(milliseconds: 150),
      );

      expect(metric.path, equals('/users'));
      expect(metric.statusCode, equals(200));
      expect(metric.duration.inMilliseconds, equals(150));
    });
  });
}
