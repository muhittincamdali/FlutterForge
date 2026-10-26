import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_forge/flutter_forge.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show formatHttpDate;
import 'package:test/test.dart';

import '../support/fake_http.dart';

void main() {
  group('RetryPolicy.backoff', () {
    const policy = RetryPolicy(baseDelay: Duration(milliseconds: 300), maxDelay: Duration(seconds: 10));

    test('doubles from the base delay', () {
      expect(policy.backoff(1), const Duration(milliseconds: 300));
      expect(policy.backoff(2), const Duration(milliseconds: 600));
      expect(policy.backoff(3), const Duration(milliseconds: 1200));
    });

    test('never exceeds maxDelay and stays finite for any retry number', () {
      expect(policy.backoff(7), const Duration(seconds: 10));
      for (final retry in [63, 64, 65, 1000, 1 << 40, (1 << 62) + 1]) {
        expect(policy.backoff(retry), const Duration(seconds: 10), reason: '$retry');
      }
    });

    test('a retry number below 1 waits nothing', () {
      expect(policy.backoff(0), Duration.zero);
      expect(policy.backoff(-5), Duration.zero);
    });

    test('zero or negative durations wait nothing', () {
      expect(const RetryPolicy(baseDelay: Duration.zero).backoff(3), Duration.zero);
      expect(const RetryPolicy(baseDelay: Duration(seconds: -1)).backoff(3), Duration.zero);
      expect(const RetryPolicy(maxDelay: Duration(seconds: -1)).backoff(3), Duration.zero);
    });

    test('a very long maxDelay does not overflow', () {
      const long = RetryPolicy(
        baseDelay: Duration(days: 365),
        maxDelay: Duration(days: 365 * 1000),
      );
      expect(long.backoff(200), const Duration(days: 365 * 1000));
    });

    test('attempts is clamped to 1...10', () {
      expect(const RetryPolicy(maxAttempts: 0).attempts, 1);
      expect(const RetryPolicy(maxAttempts: -3).attempts, 1);
      expect(const RetryPolicy(maxAttempts: 1000).attempts, maxRetryAttempts);
    });
  });

  group('parseRetryAfter', () {
    final now = DateTime.utc(2026, 10, 26, 12);

    test('reads seconds', () {
      expect(parseRetryAfter('120', now: now), const Duration(seconds: 120));
      expect(parseRetryAfter(' 5 ', now: now), const Duration(seconds: 5));
      expect(parseRetryAfter('0', now: now), Duration.zero);
    });

    test('reads an HTTP date', () {
      final later = formatHttpDate(now.add(const Duration(seconds: 30)));
      expect(parseRetryAfter(later, now: now), const Duration(seconds: 30));
    });

    test('a date in the past means now', () {
      expect(parseRetryAfter(formatHttpDate(now.subtract(const Duration(hours: 1))), now: now), Duration.zero);
    });

    test('rejects malformed and oversized values instead of overflowing', () {
      for (final value in [null, '', '-1', '1.5', '1e3', 'NaN', 'Infinity', '0x10', '99999999999', '9' * 400, 'soon']) {
        expect(parseRetryAfter(value, now: now), isNull, reason: value);
      }
    });
  });

  group('RetryInterceptor', () {
    late List<Duration> waits;
    Future<void> record(Duration delay) async => waits.add(delay);

    setUp(() => waits = []);

    ForgeClient clientFor(FakeHttp fake, RetryPolicy policy) => ForgeClient(
      baseUrl: 'https://api.example.com',
      httpClient: fake,
      retry: RetryPolicy.none,
      interceptors: [RetryInterceptor(policy, math.Random(7), record)],
    );

    test('retries a 503 and returns the later success', () async {
      var calls = 0;
      final fake = FakeHttp((_) => ++calls < 3 ? reply(503) : reply(200, json: 'ok'));
      final value = await clientFor(fake, const RetryPolicy()).getJson('/x', decode: (json) => json);
      expect(value, 'ok');
      expect(fake.requests, hasLength(3));
      expect(waits, hasLength(2));
    });

    test('waits between half and all of the backoff', () async {
      final fake = FakeHttp((_) => reply(500));
      const policy = RetryPolicy(maxAttempts: 4);
      await expectLater(
        clientFor(fake, policy).getJson('/x', decode: (json) => json),
        throwsA(isA<HttpStatusException>()),
      );
      for (final (index, wait) in waits.indexed) {
        final full = policy.backoff(index + 1);
        expect(wait, greaterThanOrEqualTo(full ~/ 2));
        expect(wait, lessThanOrEqualTo(full));
      }
      expect(waits, hasLength(3));
    });

    test('does not retry a status outside retryStatuses', () async {
      final fake = FakeHttp((_) => reply(404));
      await expectLater(clientFor(fake, const RetryPolicy()).request('GET', '/x'), throwsA(isA<HttpStatusException>()));
      expect(fake.requests, hasLength(1));
    });

    test('never repeats a POST unless retryNonIdempotent is set', () async {
      final fake = FakeHttp((_) => reply(503));
      await expectLater(clientFor(fake, const RetryPolicy()).request('POST', '/x', json: {}), throwsA(anything));
      expect(fake.requests, hasLength(1));

      final again = FakeHttp((_) => reply(503));
      await expectLater(
        clientFor(again, const RetryPolicy(retryNonIdempotent: true)).request('POST', '/x', json: {}),
        throwsA(anything),
      );
      expect(again.requests, hasLength(3));
    });

    test('retries connection errors and rethrows the last one', () async {
      final fake = FakeHttp((_) => throw http.ClientException('reset'));
      await expectLater(
        clientFor(fake, const RetryPolicy(maxAttempts: 2)).request('GET', '/x'),
        throwsA(isA<ConnectionException>()),
      );
      expect(fake.requests, hasLength(2));
    });

    test('uses Retry-After on 429', () async {
      var calls = 0;
      final fake = FakeHttp((_) => ++calls == 1 ? reply(429, headers: {'retry-after': '2'}) : reply(200, json: 1));
      await clientFor(fake, const RetryPolicy()).request('GET', '/x');
      expect(waits, [const Duration(seconds: 2)]);
    });

    test('returns the answer when Retry-After asks for longer than maxDelay', () async {
      final fake = FakeHttp((_) => reply(503, headers: {'retry-after': '3600'}));
      final client = clientFor(fake, const RetryPolicy(maxDelay: Duration(seconds: 10)));
      final response = await client.send(ForgeRequest(method: 'GET', uri: client.resolve('/x')));
      expect(response.statusCode, 503);
      expect(fake.requests, hasLength(1));
      expect(waits, isEmpty);
    });

    test('ignores a malformed Retry-After and falls back to the backoff', () async {
      var calls = 0;
      final fake = FakeHttp((_) => ++calls == 1 ? reply(503, headers: {'retry-after': 'NaN'}) : reply(200));
      await clientFor(fake, const RetryPolicy()).request('GET', '/x');
      expect(waits.single, lessThanOrEqualTo(const RetryPolicy().backoff(1)));
    });

    test('cancelling during the wait ends the retries', () async {
      final fake = FakeHttp((_) => reply(503));
      final token = CancelToken();
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: fake,
        retry: RetryPolicy.none,
        interceptors: [RetryInterceptor(const RetryPolicy(), null, (_) => Completer<void>().future)],
      );
      final future = client.request('GET', '/x', cancelToken: token);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      token.cancel();
      await expectLater(future, throwsA(isA<RequestCancelledException>()));
      expect(fake.requests, hasLength(1));
    });

    test('the client retries by default with its own policy', () async {
      var calls = 0;
      final fake = FakeHttp((_) => ++calls == 1 ? throw http.ClientException('reset') : reply(200, json: 'ok'));
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: fake,
        retry: const RetryPolicy(baseDelay: Duration(milliseconds: 1)),
      );
      expect(await client.getJson('/x', decode: (json) => json), 'ok');
      expect(fake.requests, hasLength(2));
    });
  });
}
