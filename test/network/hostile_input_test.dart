// Values a broken or hostile server can send, fed to the parsers and the
// transport. Each must end in a result or an ApiException, never in an
// unexpected error type, a hang or an overflow.
import 'dart:math' as math;

import 'package:flutter_forge/flutter_forge.dart';
import 'package:test/test.dart';

import '../support/fake_http.dart';

const _alphabet = '0123456789 -+.,:;=eE"\'/%\\\r\n\t\u0000\u00a0\u202eaZ#?@[]{}()&*~GMTSunMonJan';

String _randomText(math.Random random, int maxLength) {
  final length = random.nextInt(maxLength + 1);
  return String.fromCharCodes([
    for (var i = 0; i < length; i++) _alphabet.codeUnitAt(random.nextInt(_alphabet.length)),
  ]);
}

void main() {
  final random = math.Random(20261026);
  final samples = [
    for (var i = 0; i < 3000; i++) _randomText(random, 40),
    '9' * 10000,
    '-9223372036854775808',
    '9223372036854775807',
    '1e309',
    'NaN',
    '-0',
    'Sun, 06 Nov 1994 08:49:37 GMT',
    'Sun, 31 Feb 1994 08:49:37 GMT',
    'Fri, 31 Dec 9999 23:59:59 GMT',
    'max-age=${'9' * 400}',
  ];

  test('parseRetryAfter returns a non-negative duration or null for any text', () {
    for (final sample in samples) {
      final result = parseRetryAfter(sample, now: DateTime.utc(2026, 10, 26));
      if (result != null) expect(result.isNegative, isFalse, reason: sample);
    }
  });

  test('parseMaxAge returns a non-negative duration or null for any text', () {
    for (final sample in samples) {
      final result = parseMaxAge(sample);
      if (result != null) expect(result.isNegative, isFalse, reason: sample);
    }
  });

  test('any Location header ends in a response or a RedirectException', () async {
    for (final location in samples.take(600)) {
      final fake = FakeHttp((r) => r.url.path == '/start' ? reply(302, headers: {'location': location}) : reply(200));
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: fake,
        retry: RetryPolicy.none,
        maxRedirects: 2,
      );
      try {
        await client.send(ForgeRequest(method: 'GET', uri: client.resolve('/start')));
      } on ApiException catch (error) {
        expect(error, isA<RedirectException>(), reason: location);
      }
    }
  });

  test('any Retry-After or Cache-Control value is handled without an unexpected error', () async {
    for (final value in samples.take(600)) {
      var calls = 0;
      final fake = FakeHttp(
        (_) => ++calls == 1
            ? reply(503, headers: {'retry-after': value.replaceAll(RegExp('[\r\n]'), '')})
            : reply(200, json: 1, headers: {'cache-control': value.replaceAll(RegExp('[\r\n]'), '')}),
      );
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: fake,
        retry: const RetryPolicy(maxDelay: Duration(milliseconds: 1)),
        cache: MemoryResponseCache(),
      );
      final response = await client.send(
        ForgeRequest(method: 'GET', uri: client.resolve('/x'), cachePolicy: CachePolicy.cacheFirst),
      );
      expect([200, 503], contains(response.statusCode), reason: value);
    }
  });

  test('random header values are either sent intact or refused up front', () {
    final uri = Uri.parse('https://api.example.com');
    for (final value in samples) {
      final unsafe = value.contains('\r') || value.contains('\n') || value.contains('\u0000');
      if (unsafe) {
        expect(() => ForgeRequest(method: 'GET', uri: uri, headers: {'x-v': value}), throwsArgumentError);
      } else {
        expect(ForgeRequest(method: 'GET', uri: uri, headers: {'x-v': value}).header('x-v'), value);
      }
    }
  });
}
