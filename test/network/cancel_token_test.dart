import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_forge/src/network/cancel_token.dart' show pendingCancelCallbacks;
import 'package:test/test.dart';

import '../support/fake_http.dart';

void main() {
  group('CancelToken.onCancel', () {
    test('runs each callback once when the token is cancelled', () {
      final token = CancelToken();
      var calls = 0;
      token
        ..onCancel(() => calls++)
        ..onCancel(() => calls++)
        ..cancel()
        ..cancel();
      expect(calls, 2);
      expect(pendingCancelCallbacks(token), 0);
    });

    test('a removed callback does not run', () {
      final token = CancelToken();
      var calls = 0;
      final remove = token.onCancel(() => calls++);
      remove();
      remove();
      token.cancel();
      expect(calls, 0);
    });

    test('runs right away on a cancelled token', () {
      final token = CancelToken()..cancel();
      var calls = 0;
      token.onCancel(() => calls++)();
      expect(calls, 1);
    });
  });

  group('a long-lived token', () {
    test('holds no callback after the requests that used it finished', () async {
      final token = CancelToken();
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: FakeHttp((request) => request.url.path == '/fails' ? reply(500) : reply(200, json: {})),
        retry: RetryPolicy.none,
      );
      for (var i = 0; i < 50; i++) {
        await client.request('POST', '/upload', body: Uint8List(1024), cancelToken: token);
      }
      await expectLater(client.request('GET', '/fails', cancelToken: token), throwsA(isA<HttpStatusException>()));
      expect(pendingCancelCallbacks(token), 0);
    });

    test('holds no callback after a retry wait ended', () async {
      var calls = 0;
      final token = CancelToken();
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: FakeHttp((_) => (++calls).isOdd ? reply(503) : reply(200)),
        retry: const RetryPolicy(baseDelay: Duration(milliseconds: 1)),
      );
      for (var i = 0; i < 10; i++) {
        await client.request('GET', '/x', cancelToken: token);
      }
      expect(calls, 20);
      expect(pendingCancelCallbacks(token), 0);
    });

    test('still cancels the request that is running', () async {
      final token = CancelToken();
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: FakeHttp((_) => Completer<Never>().future),
        retry: RetryPolicy.none,
      );
      final future = client.request('GET', '/slow', cancelToken: token);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(pendingCancelCallbacks(token), 1);
      token.cancel();
      await expectLater(future, throwsA(isA<RequestCancelledException>()));
      expect(pendingCancelCallbacks(token), 0);
    });
  });
}
