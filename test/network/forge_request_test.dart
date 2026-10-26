import 'dart:typed_data';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:test/test.dart';

void main() {
  final uri = Uri.parse('https://api.example.com/v1/users?id=42');

  group('ForgeRequest', () {
    test('upper-cases the method and lower-cases header names', () {
      final request = ForgeRequest(method: 'get', uri: uri, headers: {'X-Trace': 'a'});
      expect(request.method, 'GET');
      expect(request.headers, {'x-trace': 'a'});
      expect(request.header('X-TRACE'), 'a');
    });

    test('rejects a URL that is not absolute http or https', () {
      expect(() => ForgeRequest(method: 'GET', uri: Uri.parse('/relative')), throwsArgumentError);
      expect(() => ForgeRequest(method: 'GET', uri: Uri.parse('ftp://example.com/a')), throwsArgumentError);
      expect(() => ForgeRequest(method: 'GET', uri: Uri.parse('file:///etc/hosts')), throwsArgumentError);
    });

    test('rejects a method that is not an HTTP token', () {
      expect(() => ForgeRequest(method: 'GET /admin', uri: uri), throwsArgumentError);
      expect(() => ForgeRequest(method: '', uri: uri), throwsArgumentError);
    });

    test('rejects header values that could start a new header line', () {
      for (final value in ['a\r\nx-admin: 1', 'a\nb', 'a\rb', 'a\u0000b']) {
        expect(
          () => ForgeRequest(method: 'GET', uri: uri, headers: {'x-name': value}),
          throwsArgumentError,
          reason: value,
        );
      }
    });

    test('rejects header names that are not HTTP tokens', () {
      for (final name in ['', 'x name', 'x:y', 'x\n']) {
        expect(
          () => ForgeRequest(method: 'GET', uri: uri, headers: {name: 'v'}),
          throwsArgumentError,
          reason: name,
        );
      }
    });

    test('rejects a timeout that is zero or negative', () {
      expect(() => ForgeRequest(method: 'GET', uri: uri, timeout: Duration.zero), throwsArgumentError);
      expect(() => ForgeRequest(method: 'GET', uri: uri, timeout: const Duration(seconds: -1)), throwsArgumentError);
    });

    test('withHeaders adds, replaces and removes without regard to case', () {
      final request = ForgeRequest(method: 'GET', uri: uri, headers: {'Accept': 'text/plain', 'Cookie': 'a=1'});
      final changed = request.withHeaders(add: {'ACCEPT': 'application/json'}, remove: ['COOKIE']);
      expect(changed.headers, {'accept': 'application/json'});
      expect(request.headers, {'accept': 'text/plain', 'cookie': 'a=1'}, reason: 'the original is unchanged');
    });

    test('headers cannot be changed in place', () {
      final request = ForgeRequest(method: 'GET', uri: uri, headers: {'a': 'b'});
      expect(() => request.headers['c'] = 'd', throwsUnsupportedError);
    });

    test('isIdempotent follows RFC 9110', () {
      for (final method in ['GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE']) {
        expect(
          ForgeRequest(method: method, uri: uri).isIdempotent,
          isTrue,
          reason: method,
        );
      }
      for (final method in ['POST', 'PATCH']) {
        expect(
          ForgeRequest(method: method, uri: uri).isIdempotent,
          isFalse,
          reason: method,
        );
      }
    });

    test('describe and toString leave out the path and query', () {
      final request = ForgeRequest(
        method: 'POST',
        uri: Uri.parse('https://api.example.com:8443/reset/abc123?token=s3cr3t'),
      );
      expect(request.describe(), 'POST https://api.example.com:8443');
      expect(request.toString(), isNot(contains('s3cr3t')));
      expect(request.toString(), isNot(contains('abc123')));
    });

    test('copyWith keeps the body, token and timeout', () {
      final token = CancelToken();
      final request = ForgeRequest(
        method: 'PUT',
        uri: uri,
        body: Uint8List.fromList([1, 2, 3]),
        cancelToken: token,
        timeout: const Duration(seconds: 2),
      );
      final copy = request.copyWith(uri: Uri.parse('https://api.example.com/v2'));
      expect(copy.body, [1, 2, 3]);
      expect(copy.cancelToken, same(token));
      expect(copy.timeout, const Duration(seconds: 2));
      expect(copy.uri.path, '/v2');
    });
  });

  group('ForgeResponse', () {
    final request = ForgeRequest(method: 'GET', uri: uri);

    test('json returns null for an empty body', () {
      expect(ForgeResponse(statusCode: 204, request: request).json(), isNull);
    });

    test('json throws DecodingException for invalid JSON and invalid UTF-8', () {
      final invalidJson = ForgeResponse(
        statusCode: 200,
        request: request,
        bodyBytes: Uint8List.fromList('{"a":'.codeUnits),
      );
      final invalidUtf8 = ForgeResponse(
        statusCode: 200,
        request: request,
        bodyBytes: Uint8List.fromList([0x22, 0xff, 0x22]),
      );
      expect(invalidJson.json, throwsA(isA<DecodingException>()));
      expect(invalidUtf8.json, throwsA(isA<DecodingException>()));
    });

    test('json reads deeply nested arrays without overflowing the stack', () {
      const depth = 100000;
      final body = Uint8List.fromList(('[' * depth + ']' * depth).codeUnits);
      final response = ForgeResponse(statusCode: 200, request: request, bodyBytes: body);
      expect(response.json(), isA<List<Object?>>());
    });

    test('text replaces invalid UTF-8 instead of throwing', () {
      final response = ForgeResponse(statusCode: 200, request: request, bodyBytes: Uint8List.fromList([0x61, 0xff]));
      expect(response.text, 'a�');
    });

    test('header names are compared without regard to case', () {
      final response = ForgeResponse(statusCode: 200, request: request, headers: {'ETag': '"v1"'});
      expect(response.header('etag'), '"v1"');
      expect(response.headers.keys, ['etag']);
    });
  });
}
