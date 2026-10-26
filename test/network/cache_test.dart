import 'dart:typed_data';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../support/fake_http.dart';

CachedResponse entry(int bytes, {DateTime? at, Duration freshFor = const Duration(minutes: 1)}) => CachedResponse(
  statusCode: 200,
  headers: const {},
  bodyBytes: Uint8List(bytes),
  storedAt: at ?? DateTime.utc(2026),
  freshFor: freshFor,
);

void main() {
  group('MemoryResponseCache', () {
    test('rejects limits below 1', () {
      expect(() => MemoryResponseCache(maxEntries: 0), throwsArgumentError);
      expect(() => MemoryResponseCache(maxBytes: 0), throwsArgumentError);
    });

    test('evicts the least recently used entry when full', () {
      final cache = MemoryResponseCache(maxEntries: 2)
        ..write('a', entry(1))
        ..write('b', entry(1));
      cache
        ..read('a')
        ..write('c', entry(1));
      expect(cache.read('b'), isNull);
      expect(cache.read('a'), isNotNull);
      expect(cache.read('c'), isNotNull);
      expect(cache.length, 2);
    });

    test('keeps the total size under maxBytes', () {
      final cache = MemoryResponseCache(maxBytes: 100)
        ..write('a', entry(40))
        ..write('b', entry(40))
        ..write('c', entry(40));
      expect(cache.bytes, lessThanOrEqualTo(100));
      expect(cache.read('a'), isNull);
    });

    test('does not store an entry larger than maxBytes', () {
      final cache = MemoryResponseCache(maxBytes: 100)..write('big', entry(101));
      expect(cache.read('big'), isNull);
      expect(cache.bytes, 0);
    });

    test('replacing or removing an entry keeps the byte count exact', () {
      final cache = MemoryResponseCache()
        ..write('a', entry(10))
        ..write('a', entry(30));
      expect(cache.bytes, 30);
      cache.remove('a');
      expect(cache.bytes, 0);
      cache
        ..write('b', entry(5))
        ..clear();
      expect(cache.bytes, 0);
      expect(cache.length, 0);
    });

    test('stays bounded under many distinct URLs', () {
      final cache = MemoryResponseCache(maxEntries: 50, maxBytes: 10000);
      for (var i = 0; i < 100000; i++) {
        cache.write('GET https://a.example/$i', entry(64));
      }
      expect(cache.length, lessThanOrEqualTo(50));
      expect(cache.bytes, lessThanOrEqualTo(10000));
    });
  });

  group('parseMaxAge', () {
    test('reads max-age among other directives', () {
      expect(parseMaxAge('max-age=60'), const Duration(seconds: 60));
      expect(parseMaxAge('private, max-age=0'), Duration.zero);
      expect(parseMaxAge('public,MAX-AGE="30"'), const Duration(seconds: 30));
    });

    test('ignores missing, malformed and oversized values', () {
      for (final value in [
        null,
        '',
        'no-store',
        'max-age=',
        'max-age=-1',
        'max-age=1e3',
        's-maxage=60',
        'max-age=99999999999',
      ]) {
        expect(parseMaxAge(value), isNull, reason: value);
      }
    });
  });

  group('CacheInterceptor', () {
    late DateTime now;
    late MemoryResponseCache store;
    setUp(() {
      now = DateTime.utc(2026, 10, 26, 12);
      store = MemoryResponseCache();
    });

    ForgeClient clientFor(FakeHttp fake, {Duration maxAgeLimit = const Duration(days: 7)}) => ForgeClient(
      baseUrl: 'https://api.example.com',
      httpClient: fake,
      retry: RetryPolicy.none,
      interceptors: [CacheInterceptor(store, clock: () => now, maxAgeLimit: maxAgeLimit)],
    );

    test('cacheFirst answers from the cache while the response is fresh', () async {
      final fake = FakeHttp((_) => reply(200, json: 'v1', headers: {'cache-control': 'max-age=60'}));
      final client = clientFor(fake);
      final first = await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      now = now.add(const Duration(seconds: 59));
      final second = await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(first.fromCache, isFalse);
      expect(second.fromCache, isTrue);
      expect(second.json(), 'v1');
      expect(fake.requests, hasLength(1));
    });

    test('a stale response with an ETag is revalidated and kept on 304', () async {
      final fake = FakeHttp(
        (r) => r.headers['if-none-match'] == '"v1"'
            ? reply(304)
            : reply(200, json: 'v1', headers: {'etag': '"v1"', 'cache-control': 'max-age=10'}),
      );
      final client = clientFor(fake);
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      now = now.add(const Duration(seconds: 11));
      final revalidated = await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(fake.requests, hasLength(2));
      expect(fake.requests.last.headers['if-none-match'], '"v1"');
      expect(revalidated.statusCode, 200);
      expect(revalidated.fromCache, isTrue);
      expect(revalidated.json(), 'v1');

      final again = await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(again.fromCache, isTrue);
      expect(fake.requests, hasLength(2), reason: 'the 304 made the entry fresh again');
    });

    test('a stale response without validators is fetched again', () async {
      var version = 0;
      final fake = FakeHttp((_) => reply(200, json: 'v${++version}', headers: {'cache-control': 'max-age=1'}));
      final client = clientFor(fake);
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      now = now.add(const Duration(seconds: 2));
      final next = await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(next.json(), 'v2');
      expect(next.fromCache, isFalse);
    });

    test('no-store is never stored and no-cache is always revalidated', () async {
      final fake = FakeHttp(
        (r) => r.url.path == '/private'
            ? reply(200, json: 'secret', headers: {'cache-control': 'no-store'})
            : reply(200, json: 'x', headers: {'cache-control': 'no-cache', 'etag': '"x"'}),
      );
      final client = clientFor(fake);
      await client.request('GET', '/private', cachePolicy: CachePolicy.cacheFirst);
      expect(store.length, 0);

      await client.request('GET', '/nocache', cachePolicy: CachePolicy.cacheFirst);
      await client.request('GET', '/nocache', cachePolicy: CachePolicy.cacheFirst);
      expect(fake.requests.last.headers['if-none-match'], '"x"');
    });

    test('a GET answer other than 200 is not stored', () async {
      final fake = FakeHttp((r) => r.url.path == '/missing' ? reply(404) : reply(203, json: 1));
      final client = clientFor(fake);
      await expectLater(
        client.request('GET', '/missing', cachePolicy: CachePolicy.cacheFirst),
        throwsA(isA<HttpStatusException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
      await client.request('GET', '/partial', cachePolicy: CachePolicy.cacheFirst);
      expect(store.length, 0);
    });

    test('a 200 answer to a method other than GET is not stored', () async {
      final fake = FakeHttp((_) => reply(200, json: 1));
      final client = clientFor(fake);
      await client.request('POST', '/a', json: {}, cachePolicy: CachePolicy.cacheFirst);
      await client.request('PUT', '/a', json: {}, cachePolicy: CachePolicy.cacheFirst);
      expect(store.length, 0);
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(store.length, 1);
    });

    test('networkFirst falls back to the cache when offline', () async {
      var offline = false;
      final fake = FakeHttp((_) => offline ? throw http.ClientException('offline') : reply(200, json: 'saved'));
      final client = clientFor(fake);
      await client.request('GET', '/a', cachePolicy: CachePolicy.networkFirst);
      offline = true;
      now = now.add(const Duration(days: 30));
      final fallback = await client.request('GET', '/a', cachePolicy: CachePolicy.networkFirst);
      expect(fallback.fromCache, isTrue);
      expect(fallback.json(), 'saved');
    });

    test('networkFirst without a stored response rethrows the error', () async {
      final fake = FakeHttp((_) => throw http.ClientException('offline'));
      await expectLater(
        clientFor(fake).request('GET', '/a', cachePolicy: CachePolicy.networkFirst),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('networkFirst does not hide a server error behind the cache', () async {
      var failing = false;
      final fake = FakeHttp((_) => failing ? reply(500) : reply(200, json: 'saved'));
      final client = clientFor(fake);
      await client.request('GET', '/a', cachePolicy: CachePolicy.networkFirst);
      failing = true;
      await expectLater(
        client.request('GET', '/a', cachePolicy: CachePolicy.networkFirst),
        throwsA(isA<HttpStatusException>()),
      );
    });

    test('noCache requests bypass the cache', () async {
      final fake = FakeHttp((_) => reply(200, json: 1));
      final client = clientFor(fake);
      await client.request('GET', '/a');
      await client.request('GET', '/a');
      expect(fake.requests, hasLength(2));
      expect(store.length, 0);
    });

    test('a huge max-age is capped by maxAgeLimit', () async {
      final fake = FakeHttp((_) => reply(200, json: 1, headers: {'cache-control': 'max-age=9999999999'}));
      final client = clientFor(fake, maxAgeLimit: const Duration(hours: 1));
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      now = now.add(const Duration(hours: 1, seconds: 1));
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(fake.requests, hasLength(2));
    });

    test('the cache parameter of ForgeClient enables it', () async {
      final fake = FakeHttp((_) => reply(200, json: 1));
      final client = ForgeClient(baseUrl: 'https://api.example.com', httpClient: fake, cache: store);
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      await client.request('GET', '/a', cachePolicy: CachePolicy.cacheFirst);
      expect(fake.requests, hasLength(1));
    });
  });
}
