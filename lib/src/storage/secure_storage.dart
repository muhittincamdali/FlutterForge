/// Secure storage abstraction for sensitive data.
///
/// Provides encrypted storage for sensitive information
/// like tokens, passwords, and API keys.
library;

import 'dart:convert';

/// Abstract interface for secure storage.
abstract class SecureStorage {
  /// Writes a value to secure storage.
  Future<void> write({required String key, required String? value});

  /// Reads a value from secure storage.
  Future<String?> read({required String key});

  /// Deletes a value from secure storage.
  Future<void> delete({required String key});

  /// Deletes all values from secure storage.
  Future<void> deleteAll();

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey({required String key});

  /// Gets all keys in secure storage.
  Future<Map<String, String>> readAll();
}

/// In-memory implementation of secure storage for testing.
class InMemorySecureStorage implements SecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_storage);
  }
}

/// Secure storage keys for authentication.
class SecureStorageKeys {
  SecureStorageKeys._();

  /// Access token key.
  static const String accessToken = 'access_token';

  /// Refresh token key.
  static const String refreshToken = 'refresh_token';

  /// API key.
  static const String apiKey = 'api_key';

  /// User credentials key.
  static const String credentials = 'credentials';

  /// Encryption key.
  static const String encryptionKey = 'encryption_key';

  /// Biometric key.
  static const String biometricKey = 'biometric_key';

  /// PIN code key.
  static const String pinCode = 'pin_code';

  /// Private key.
  static const String privateKey = 'private_key';
}

/// Wrapper for secure storage with typed access.
class TypedSecureStorage {
  /// Creates a new [TypedSecureStorage].
  TypedSecureStorage(this._storage);

  final SecureStorage _storage;

  /// Stores the access token.
  Future<void> setAccessToken(String? token) async {
    await _storage.write(key: SecureStorageKeys.accessToken, value: token);
  }

  /// Retrieves the access token.
  Future<String?> getAccessToken() async {
    return _storage.read(key: SecureStorageKeys.accessToken);
  }

  /// Stores the refresh token.
  Future<void> setRefreshToken(String? token) async {
    await _storage.write(key: SecureStorageKeys.refreshToken, value: token);
  }

  /// Retrieves the refresh token.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: SecureStorageKeys.refreshToken);
  }

  /// Stores user credentials.
  Future<void> setCredentials(UserCredentials? credentials) async {
    if (credentials == null) {
      await _storage.delete(key: SecureStorageKeys.credentials);
    } else {
      await _storage.write(
        key: SecureStorageKeys.credentials,
        value: jsonEncode(credentials.toJson()),
      );
    }
  }

  /// Retrieves user credentials.
  Future<UserCredentials?> getCredentials() async {
    final json = await _storage.read(key: SecureStorageKeys.credentials);
    if (json == null) return null;
    return UserCredentials.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Clears all authentication data.
  Future<void> clearAuth() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
    await _storage.delete(key: SecureStorageKeys.refreshToken);
    await _storage.delete(key: SecureStorageKeys.credentials);
  }

  /// Checks if user is authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Stores API key.
  Future<void> setApiKey(String? key) async {
    await _storage.write(key: SecureStorageKeys.apiKey, value: key);
  }

  /// Retrieves API key.
  Future<String?> getApiKey() async {
    return _storage.read(key: SecureStorageKeys.apiKey);
  }

  /// Stores PIN code.
  Future<void> setPin(String? pin) async {
    await _storage.write(key: SecureStorageKeys.pinCode, value: pin);
  }

  /// Retrieves PIN code.
  Future<String?> getPin() async {
    return _storage.read(key: SecureStorageKeys.pinCode);
  }

  /// Validates PIN code.
  Future<bool> validatePin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }

  /// Clears all secure storage.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// User credentials model.
class UserCredentials {
  /// Creates new [UserCredentials].
  const UserCredentials({
    required this.email,
    this.password,
    this.userId,
    this.rememberMe = false,
  });

  /// Creates credentials from JSON.
  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      email: json['email'] as String,
      password: json['password'] as String?,
      userId: json['userId'] as String?,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );
  }

  /// User email.
  final String email;

  /// User password (encrypted).
  final String? password;

  /// User ID.
  final String? userId;

  /// Remember me flag.
  final bool rememberMe;

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'userId': userId,
      'rememberMe': rememberMe,
    };
  }
}

/// Token pair for authentication.
class TokenPair {
  /// Creates a new [TokenPair].
  const TokenPair({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  /// Creates from JSON.
  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// The access token.
  final String accessToken;

  /// The refresh token.
  final String? refreshToken;

  /// Token expiration time.
  final DateTime? expiresAt;

  /// Whether the token is expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Whether the token is about to expire (within 5 minutes).
  bool get isAboutToExpire =>
      expiresAt != null &&
      DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt!);

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

/// Secure storage with encryption.
class EncryptedSecureStorage implements SecureStorage {
  /// Creates a new [EncryptedSecureStorage].
  EncryptedSecureStorage({
    required this.delegate,
    required this.encrypt,
    required this.decrypt,
  });

  /// The underlying storage.
  final SecureStorage delegate;

  /// Encryption function.
  final String Function(String) encrypt;

  /// Decryption function.
  final String Function(String) decrypt;

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await delegate.write(key: key, value: null);
    } else {
      await delegate.write(key: key, value: encrypt(value));
    }
  }

  @override
  Future<String?> read({required String key}) async {
    final encrypted = await delegate.read(key: key);
    if (encrypted == null) return null;
    return decrypt(encrypted);
  }

  @override
  Future<void> delete({required String key}) => delegate.delete(key: key);

  @override
  Future<void> deleteAll() => delegate.deleteAll();

  @override
  Future<bool> containsKey({required String key}) =>
      delegate.containsKey(key: key);

  @override
  Future<Map<String, String>> readAll() async {
    final all = await delegate.readAll();
    return all.map((key, value) => MapEntry(key, decrypt(value)));
  }
}

/// Secure storage migration helper.
class SecureStorageMigration {
  /// Creates a new [SecureStorageMigration].
  SecureStorageMigration(this._storage);

  final SecureStorage _storage;

  static const String _versionKey = '_storage_version';

  /// Current storage version.
  int get currentVersion => 1;

  /// Runs migrations if needed.
  Future<void> migrate() async {
    final versionStr = await _storage.read(key: _versionKey);
    final version = versionStr != null ? int.tryParse(versionStr) ?? 0 : 0;

    if (version < currentVersion) {
      await _runMigrations(version);
      await _storage.write(key: _versionKey, value: currentVersion.toString());
    }
  }

  Future<void> _runMigrations(int fromVersion) async {
    // Add migrations here as needed
    // if (fromVersion < 1) await _migrateToV1();
    // if (fromVersion < 2) await _migrateToV2();
  }
}
