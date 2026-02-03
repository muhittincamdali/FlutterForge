/// Local storage abstraction for persisting data.
///
/// Provides a unified interface for local storage operations
/// with support for different storage backends.
library;

import 'dart:convert';

/// Abstract interface for local storage.
abstract class LocalStorage {
  /// Stores a string value.
  Future<void> setString(String key, String value);

  /// Retrieves a string value.
  Future<String?> getString(String key);

  /// Stores an integer value.
  Future<void> setInt(String key, int value);

  /// Retrieves an integer value.
  Future<int?> getInt(String key);

  /// Stores a double value.
  Future<void> setDouble(String key, double value);

  /// Retrieves a double value.
  Future<double?> getDouble(String key);

  /// Stores a boolean value.
  Future<void> setBool(String key, bool value);

  /// Retrieves a boolean value.
  Future<bool?> getBool(String key);

  /// Stores a list of strings.
  Future<void> setStringList(String key, List<String> value);

  /// Retrieves a list of strings.
  Future<List<String>?> getStringList(String key);

  /// Stores a JSON object.
  Future<void> setJson(String key, Map<String, dynamic> value);

  /// Retrieves a JSON object.
  Future<Map<String, dynamic>?> getJson(String key);

  /// Stores a typed object.
  Future<void> setObject<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  );

  /// Retrieves a typed object.
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// Stores a list of typed objects.
  Future<void> setObjectList<T>(
    String key,
    List<T> value,
    Map<String, dynamic> Function(T) toJson,
  );

  /// Retrieves a list of typed objects.
  Future<List<T>?> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// Removes a value.
  Future<void> remove(String key);

  /// Clears all values.
  Future<void> clear();

  /// Checks if a key exists.
  Future<bool> containsKey(String key);

  /// Gets all keys.
  Future<Set<String>> getKeys();
}

/// In-memory implementation of [LocalStorage].
///
/// Useful for testing or temporary storage.
class InMemoryStorage implements LocalStorage {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _storage[key] as String?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return _storage[key] as int?;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _storage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _storage[key] as double?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _storage[key] as bool?;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _storage[key] = List<String>.from(value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _storage[key];
    if (value == null) return null;
    return List<String>.from(value as List);
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    _storage[key] = Map<String, dynamic>.from(value);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _storage[key];
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  @override
  Future<void> setObject<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    _storage[key] = toJson(value);
  }

  @override
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final json = await getJson(key);
    if (json == null) return null;
    return fromJson(json);
  }

  @override
  Future<void> setObjectList<T>(
    String key,
    List<T> value,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    _storage[key] = value.map(toJson).toList();
  }

  @override
  Future<List<T>?> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final value = _storage[key];
    if (value == null) return null;
    return (value as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _storage.keys.toSet();
  }
}

/// Storage keys constants.
class StorageKeys {
  StorageKeys._();

  /// User related keys.
  static const String userId = 'user_id';
  static const String userToken = 'user_token';
  static const String refreshToken = 'refresh_token';
  static const String userProfile = 'user_profile';

  /// App settings keys.
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingCompleted = 'onboarding_completed';

  /// Cache keys.
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedData = 'cached_data';
}

/// Storage wrapper with type-safe access.
class TypedStorage {
  /// Creates a new [TypedStorage].
  TypedStorage(this._storage);

  final LocalStorage _storage;

  /// User ID storage.
  StorageEntry<String> get userId => StorageEntry(
        storage: _storage,
        key: StorageKeys.userId,
        defaultValue: '',
      );

  /// Theme mode storage.
  StorageEntry<String> get themeMode => StorageEntry(
        storage: _storage,
        key: StorageKeys.themeMode,
        defaultValue: 'system',
      );

  /// Locale storage.
  StorageEntry<String?> get locale => StorageEntry(
        storage: _storage,
        key: StorageKeys.locale,
        defaultValue: null,
      );

  /// First launch flag.
  StorageEntry<bool> get isFirstLaunch => StorageEntry(
        storage: _storage,
        key: StorageKeys.isFirstLaunch,
        defaultValue: true,
      );

  /// Onboarding completed flag.
  StorageEntry<bool> get onboardingCompleted => StorageEntry(
        storage: _storage,
        key: StorageKeys.onboardingCompleted,
        defaultValue: false,
      );
}

/// Single storage entry with type safety.
class StorageEntry<T> {
  /// Creates a new [StorageEntry].
  StorageEntry({
    required LocalStorage storage,
    required this.key,
    required this.defaultValue,
  }) : _storage = storage;

  final LocalStorage _storage;

  /// The storage key.
  final String key;

  /// The default value.
  final T defaultValue;

  /// Gets the value.
  Future<T> get() async {
    if (T == String) {
      return await _storage.getString(key) as T? ?? defaultValue;
    } else if (T == int) {
      return await _storage.getInt(key) as T? ?? defaultValue;
    } else if (T == double) {
      return await _storage.getDouble(key) as T? ?? defaultValue;
    } else if (T == bool) {
      return await _storage.getBool(key) as T? ?? defaultValue;
    }
    return defaultValue;
  }

  /// Sets the value.
  Future<void> set(T value) async {
    if (value == null) {
      await _storage.remove(key);
      return;
    }

    if (T == String || T == String?) {
      await _storage.setString(key, value as String);
    } else if (T == int) {
      await _storage.setInt(key, value as int);
    } else if (T == double) {
      await _storage.setDouble(key, value as double);
    } else if (T == bool) {
      await _storage.setBool(key, value as bool);
    }
  }

  /// Removes the value.
  Future<void> remove() => _storage.remove(key);

  /// Checks if value exists.
  Future<bool> exists() => _storage.containsKey(key);
}

/// Batch storage operations.
class BatchStorage {
  /// Creates a new [BatchStorage].
  BatchStorage(this._storage);

  final LocalStorage _storage;
  final Map<String, dynamic> _pending = {};

  /// Queues a string value for batch write.
  void queueString(String key, String value) => _pending[key] = value;

  /// Queues an int value for batch write.
  void queueInt(String key, int value) => _pending[key] = value;

  /// Queues a bool value for batch write.
  void queueBool(String key, bool value) => _pending[key] = value;

  /// Commits all pending writes.
  Future<void> commit() async {
    for (final entry in _pending.entries) {
      final value = entry.value;
      if (value is String) {
        await _storage.setString(entry.key, value);
      } else if (value is int) {
        await _storage.setInt(entry.key, value);
      } else if (value is bool) {
        await _storage.setBool(entry.key, value);
      }
    }
    _pending.clear();
  }

  /// Clears pending writes.
  void clear() => _pending.clear();
}
