/// Tests for storage components.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/src/storage/local_storage.dart';
import 'package:flutter_forge/src/storage/secure_storage.dart';
import 'package:flutter_forge/src/storage/cache.dart';

void main() {
  group('InMemoryStorage Tests', () {
    late InMemoryStorage storage;

    setUp(() {
      storage = InMemoryStorage();
    });

    test('stores and retrieves string', () async {
      await storage.setString('key', 'value');
      expect(await storage.getString('key'), equals('value'));
    });

    test('stores and retrieves int', () async {
      await storage.setInt('key', 42);
      expect(await storage.getInt('key'), equals(42));
    });

    test('stores and retrieves double', () async {
      await storage.setDouble('key', 3.14);
      expect(await storage.getDouble('key'), equals(3.14));
    });

    test('stores and retrieves bool', () async {
      await storage.setBool('key', true);
      expect(await storage.getBool('key'), isTrue);
    });

    test('stores and retrieves string list', () async {
      await storage.setStringList('key', ['a', 'b', 'c']);
      expect(await storage.getStringList('key'), equals(['a', 'b', 'c']));
    });

    test('stores and retrieves JSON', () async {
      final json = {'name': 'test', 'value': 42};
      await storage.setJson('key', json);
      expect(await storage.getJson('key'), equals(json));
    });

    test('removes value correctly', () async {
      await storage.setString('key', 'value');
      await storage.remove('key');
      expect(await storage.getString('key'), isNull);
    });

    test('clears all values', () async {
      await storage.setString('key1', 'value1');
      await storage.setString('key2', 'value2');
      await storage.clear();
      expect(await storage.getString('key1'), isNull);
      expect(await storage.getString('key2'), isNull);
    });

    test('containsKey works correctly', () async {
      await storage.setString('key', 'value');
      expect(await storage.containsKey('key'), isTrue);
      expect(await storage.containsKey('nonexistent'), isFalse);
    });

    test('getKeys returns all keys', () async {
      await storage.setString('key1', 'value1');
      await storage.setString('key2', 'value2');
      final keys = await storage.getKeys();
      expect(keys, containsAll(['key1', 'key2']));
    });
  });

  group('InMemorySecureStorage Tests', () {
    late InMemorySecureStorage storage;

    setUp(() {
      storage = InMemorySecureStorage();
    });

    test('write and read value', () async {
      await storage.write(key: 'token', value: 'secret123');
      expect(await storage.read(key: 'token'), equals('secret123'));
    });

    test('delete value', () async {
      await storage.write(key: 'token', value: 'secret123');
      await storage.delete(key: 'token');
      expect(await storage.read(key: 'token'), isNull);
    });

    test('deleteAll clears storage', () async {
      await storage.write(key: 'key1', value: 'value1');
      await storage.write(key: 'key2', value: 'value2');
      await storage.deleteAll();
      expect(await storage.read(key: 'key1'), isNull);
      expect(await storage.read(key: 'key2'), isNull);
    });

    test('containsKey works correctly', () async {
      await storage.write(key: 'token', value: 'secret');
      expect(await storage.containsKey(key: 'token'), isTrue);
      expect(await storage.containsKey(key: 'nonexistent'), isFalse);
    });

    test('readAll returns all values', () async {
      await storage.write(key: 'key1', value: 'value1');
      await storage.write(key: 'key2', value: 'value2');
      final all = await storage.readAll();
      expect(all['key1'], equals('value1'));
      expect(all['key2'], equals('value2'));
    });

    test('write null removes value', () async {
      await storage.write(key: 'token', value: 'secret');
      await storage.write(key: 'token', value: null);
      expect(await storage.read(key: 'token'), isNull);
    });
  });

  group('TypedSecureStorage Tests', () {
    late TypedSecureStorage typedStorage;
    late InMemorySecureStorage baseStorage;

    setUp(() {
      baseStorage = InMemorySecureStorage();
      typedStorage = TypedSecureStorage(baseStorage);
    });

    test('access token operations', () async {
      await typedStorage.setAccessToken('token123');
      expect(await typedStorage.getAccessToken(), equals('token123'));

      await typedStorage.setAccessToken(null);
      expect(await typedStorage.getAccessToken(), isNull);
    });

    test('refresh token operations', () async {
      await typedStorage.setRefreshToken('refresh123');
      expect(await typedStorage.getRefreshToken(), equals('refresh123'));
    });

    test('isAuthenticated checks token', () async {
      expect(await typedStorage.isAuthenticated(), isFalse);

      await typedStorage.setAccessToken('token');
      expect(await typedStorage.isAuthenticated(), isTrue);
    });

    test('clearAuth removes all auth data', () async {
      await typedStorage.setAccessToken('access');
      await typedStorage.setRefreshToken('refresh');
      await typedStorage.clearAuth();

      expect(await typedStorage.getAccessToken(), isNull);
      expect(await typedStorage.getRefreshToken(), isNull);
    });

    test('credentials operations', () async {
      const credentials = UserCredentials(
        email: 'test@example.com',
        password: 'password123',
      );

      await typedStorage.setCredentials(credentials);
      final retrieved = await typedStorage.getCredentials();

      expect(retrieved?.email, equals('test@example.com'));
      expect(retrieved?.password, equals('password123'));
    });
  });

  group('TokenPair Tests', () {
    test('isExpired returns correct value', () {
      final expiredToken = TokenPair(
        accessToken: 'token',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(expiredToken.isExpired, isTrue);

      final validToken = TokenPair(
        accessToken: 'token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(validToken.isExpired, isFalse);
    });

    test('isAboutToExpire returns correct value', () {
      final aboutToExpire = TokenPair(
        accessToken: 'token',
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      );
      expect(aboutToExpire.isAboutToExpire, isTrue);

      final notAboutToExpire = TokenPair(
        accessToken: 'token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(notAboutToExpire.isAboutToExpire, isFalse);
    });

    test('fromJson creates token correctly', () {
      final json = {
        'access_token': 'access123',
        'refresh_token': 'refresh123',
        'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };

      final token = TokenPair.fromJson(json);
      expect(token.accessToken, equals('access123'));
      expect(token.refreshToken, equals('refresh123'));
      expect(token.isExpired, isFalse);
    });
  });

  group('MemoryCache Tests', () {
    late MemoryCache<String, int> cache;

    setUp(() {
      cache = MemoryCache(maxSize: 3);
    });

    test('stores and retrieves values', () {
      cache.set('a', 1);
      cache.set('b', 2);
      expect(cache.get('a'), equals(1));
      expect(cache.get('b'), equals(2));
    });

    test('returns null for missing keys', () {
      expect(cache.get('nonexistent'), isNull);
    });

    test('evicts oldest when at max size', () {
      cache.set('a', 1);
      cache.set('b', 2);
      cache.set('c', 3);
      cache.set('d', 4); // Should evict 'a'

      expect(cache.get('a'), isNull);
      expect(cache.get('d'), equals(4));
    });

    test('remove works correctly', () {
      cache.set('a', 1);
      cache.remove('a');
      expect(cache.get('a'), isNull);
    });

    test('clear removes all values', () {
      cache.set('a', 1);
      cache.set('b', 2);
      cache.clear();
      expect(cache.isEmpty, isTrue);
    });

    test('containsKey works correctly', () {
      cache.set('a', 1);
      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isFalse);
    });

    test('length returns correct count', () {
      cache.set('a', 1);
      cache.set('b', 2);
      expect(cache.length, equals(2));
    });
  });

  group('LruCache Tests', () {
    late LruCache<String, int> cache;

    setUp(() {
      cache = LruCache(maxSize: 3);
    });

    test('moves accessed items to front', () {
      cache.set('a', 1);
      cache.set('b', 2);
      cache.set('c', 3);

      // Access 'a' to make it most recently used
      cache.get('a');

      // Add new item, should evict 'b' (least recently used)
      cache.set('d', 4);

      expect(cache.get('a'), equals(1));
      expect(cache.get('b'), isNull);
      expect(cache.get('d'), equals(4));
    });
  });

  group('TtlCache Tests', () {
    late TtlCache<String, int> cache;

    setUp(() {
      cache = TtlCache(
        defaultTtl: const Duration(milliseconds: 100),
        maxSize: 10,
        cleanupInterval: const Duration(milliseconds: 50),
      );
    });

    tearDown(() {
      cache.dispose();
    });

    test('values expire after TTL', () async {
      cache.set('a', 1);
      expect(cache.get('a'), equals(1));

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 150));

      expect(cache.get('a'), isNull);
    });

    test('custom TTL works', () async {
      cache.set('short', 1, ttl: const Duration(milliseconds: 50));
      cache.set('long', 2, ttl: const Duration(milliseconds: 200));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cache.get('short'), isNull);
      expect(cache.get('long'), equals(2));
    });
  });

  group('CacheStats Tests', () {
    test('tracks hits and misses', () {
      final stats = CacheStats();
      stats.recordHit();
      stats.recordHit();
      stats.recordMiss();

      expect(stats.hits, equals(2));
      expect(stats.misses, equals(1));
      expect(stats.hitRate, closeTo(0.66, 0.01));
    });

    test('reset clears statistics', () {
      final stats = CacheStats();
      stats.recordHit();
      stats.recordMiss();
      stats.reset();

      expect(stats.hits, equals(0));
      expect(stats.misses, equals(0));
    });
  });
}
