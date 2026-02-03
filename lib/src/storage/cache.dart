/// In-memory caching utilities.
///
/// Provides various caching strategies including LRU, TTL,
/// and priority-based caching.
library;

import 'dart:async';
import 'dart:collection';

/// Cache entry with metadata.
class CacheEntry<T> {
  /// Creates a new [CacheEntry].
  CacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
    this.accessCount = 0,
    this.lastAccessedAt,
    this.priority = CachePriority.normal,
  });

  /// The cached value.
  final T value;

  /// When the entry was created.
  final DateTime createdAt;

  /// When the entry expires.
  DateTime? expiresAt;

  /// Number of times accessed.
  int accessCount;

  /// When last accessed.
  DateTime? lastAccessedAt;

  /// Priority level.
  CachePriority priority;

  /// Whether the entry is expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Records an access.
  void recordAccess() {
    accessCount++;
    lastAccessedAt = DateTime.now();
  }
}

/// Cache priority levels.
enum CachePriority {
  /// Low priority, evicted first.
  low,

  /// Normal priority.
  normal,

  /// High priority, evicted last.
  high,
}

/// Generic cache interface.
abstract class Cache<K, V> {
  /// Gets a value from the cache.
  V? get(K key);

  /// Sets a value in the cache.
  void set(K key, V value, {Duration? ttl});

  /// Removes a value from the cache.
  void remove(K key);

  /// Clears the cache.
  void clear();

  /// Whether the cache contains a key.
  bool containsKey(K key);

  /// The number of entries in the cache.
  int get length;

  /// Whether the cache is empty.
  bool get isEmpty;

  /// All keys in the cache.
  Iterable<K> get keys;
}

/// Simple in-memory cache.
class MemoryCache<K, V> implements Cache<K, V> {
  /// Creates a new [MemoryCache].
  MemoryCache({this.maxSize = 100});

  /// Maximum number of entries.
  final int maxSize;

  final Map<K, CacheEntry<V>> _cache = {};

  @override
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    entry.recordAccess();
    return entry.value;
  }

  @override
  void set(K key, V value, {Duration? ttl}) {
    _evictIfNeeded();

    _cache[key] = CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
    );
  }

  @override
  void remove(K key) {
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  @override
  int get length => _cache.length;

  @override
  bool get isEmpty => _cache.isEmpty;

  @override
  Iterable<K> get keys => _cache.keys;

  /// Removes expired entries.
  void removeExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  void _evictIfNeeded() {
    if (_cache.length >= maxSize) {
      // Remove oldest entry
      K? oldestKey;
      DateTime? oldestTime;

      for (final entry in _cache.entries) {
        final accessTime = entry.value.lastAccessedAt ?? entry.value.createdAt;
        if (oldestTime == null || accessTime.isBefore(oldestTime)) {
          oldestKey = entry.key;
          oldestTime = accessTime;
        }
      }

      if (oldestKey != null) {
        _cache.remove(oldestKey);
      }
    }
  }
}

/// LRU (Least Recently Used) cache.
class LruCache<K, V> implements Cache<K, V> {
  /// Creates a new [LruCache].
  LruCache({required this.maxSize});

  /// Maximum size of the cache.
  final int maxSize;

  final _cache = LinkedHashMap<K, V>();

  @override
  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to end (most recently used)
    }
    return value;
  }

  @override
  void set(K key, V value, {Duration? ttl}) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first); // Remove least recently used
    }
    _cache[key] = value;
  }

  @override
  void remove(K key) {
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  bool containsKey(K key) => _cache.containsKey(key);

  @override
  int get length => _cache.length;

  @override
  bool get isEmpty => _cache.isEmpty;

  @override
  Iterable<K> get keys => _cache.keys;
}

/// TTL (Time To Live) cache with automatic expiration.
class TtlCache<K, V> implements Cache<K, V> {
  /// Creates a new [TtlCache].
  TtlCache({
    required this.defaultTtl,
    this.maxSize = 1000,
    this.cleanupInterval = const Duration(minutes: 1),
  }) {
    _startCleanupTimer();
  }

  /// Default TTL for entries.
  final Duration defaultTtl;

  /// Maximum number of entries.
  final int maxSize;

  /// Interval between cleanups.
  final Duration cleanupInterval;

  final Map<K, CacheEntry<V>> _cache = {};
  Timer? _cleanupTimer;

  @override
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    entry.recordAccess();
    return entry.value;
  }

  @override
  void set(K key, V value, {Duration? ttl}) {
    _evictIfNeeded();

    final actualTtl = ttl ?? defaultTtl;
    _cache[key] = CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(actualTtl),
    );
  }

  @override
  void remove(K key) {
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  @override
  int get length => _cache.length;

  @override
  bool get isEmpty => _cache.isEmpty;

  @override
  Iterable<K> get keys => _cache.keys;

  /// Refreshes the TTL for a key.
  void refresh(K key, {Duration? ttl}) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      entry.expiresAt = DateTime.now().add(ttl ?? defaultTtl);
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());
  }

  void _cleanup() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  void _evictIfNeeded() {
    if (_cache.length >= maxSize) {
      // Remove expired first
      _cleanup();

      // If still over limit, remove oldest
      while (_cache.length >= maxSize) {
        K? oldestKey;
        DateTime? oldestTime;

        for (final entry in _cache.entries) {
          if (oldestTime == null ||
              entry.value.createdAt.isBefore(oldestTime)) {
            oldestKey = entry.key;
            oldestTime = entry.value.createdAt;
          }
        }

        if (oldestKey != null) {
          _cache.remove(oldestKey);
        } else {
          break;
        }
      }
    }
  }

  /// Disposes the cache and stops the cleanup timer.
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

/// Async cache with loader support.
class AsyncCache<K, V> {
  /// Creates a new [AsyncCache].
  AsyncCache({
    required this.loader,
    this.maxSize = 100,
    this.ttl,
  });

  /// Function to load values.
  final Future<V> Function(K key) loader;

  /// Maximum cache size.
  final int maxSize;

  /// Default TTL.
  final Duration? ttl;

  final Map<K, CacheEntry<V>> _cache = {};
  final Map<K, Future<V>> _pending = {};

  /// Gets or loads a value.
  Future<V> get(K key) async {
    // Check cache
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      cached.recordAccess();
      return cached.value;
    }

    // Check if already loading
    if (_pending.containsKey(key)) {
      return _pending[key]!;
    }

    // Load value
    final future = loader(key);
    _pending[key] = future;

    try {
      final value = await future;
      _evictIfNeeded();
      _cache[key] = CacheEntry(
        value: value,
        createdAt: DateTime.now(),
        expiresAt: ttl != null ? DateTime.now().add(ttl!) : null,
      );
      return value;
    } finally {
      _pending.remove(key);
    }
  }

  /// Invalidates a key.
  void invalidate(K key) {
    _cache.remove(key);
  }

  /// Clears the cache.
  void clear() {
    _cache.clear();
  }

  void _evictIfNeeded() {
    while (_cache.length >= maxSize) {
      K? lruKey;
      DateTime? lruTime;

      for (final entry in _cache.entries) {
        final time = entry.value.lastAccessedAt ?? entry.value.createdAt;
        if (lruTime == null || time.isBefore(lruTime)) {
          lruKey = entry.key;
          lruTime = time;
        }
      }

      if (lruKey != null) {
        _cache.remove(lruKey);
      } else {
        break;
      }
    }
  }
}

/// Cache statistics.
class CacheStats {
  /// Creates new [CacheStats].
  CacheStats();

  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  /// Number of cache hits.
  int get hits => _hits;

  /// Number of cache misses.
  int get misses => _misses;

  /// Number of evictions.
  int get evictions => _evictions;

  /// Hit rate.
  double get hitRate {
    final total = _hits + _misses;
    return total > 0 ? _hits / total : 0;
  }

  /// Records a hit.
  void recordHit() => _hits++;

  /// Records a miss.
  void recordMiss() => _misses++;

  /// Records an eviction.
  void recordEviction() => _evictions++;

  /// Resets statistics.
  void reset() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }
}
