/// Base data source patterns for Clean Architecture.
///
/// Data sources are responsible for actual data operations,
/// whether from remote APIs, local databases, or other sources.
library;

/// Base interface for remote data sources.
///
/// Remote data sources handle all network-related operations.
abstract class RemoteDataSource<T, ID> {
  /// Fetches all items from the remote server.
  Future<List<T>> fetchAll();

  /// Fetches a single item by [id] from the remote server.
  Future<T?> fetchById(ID id);

  /// Creates an item on the remote server.
  Future<T> create(T item);

  /// Updates an item on the remote server.
  Future<T> update(T item);

  /// Deletes an item from the remote server.
  Future<void> delete(ID id);
}

/// Extended remote data source with additional operations.
abstract class ExtendedRemoteDataSource<T, ID> extends RemoteDataSource<T, ID> {
  /// Fetches items with pagination.
  Future<RemotePagedResponse<T>> fetchPaginated({
    required int page,
    required int pageSize,
    String? sortBy,
    bool ascending = true,
  });

  /// Searches for items.
  Future<List<T>> search(String query);

  /// Fetches items by IDs.
  Future<List<T>> fetchByIds(List<ID> ids);

  /// Creates multiple items.
  Future<List<T>> createMany(List<T> items);

  /// Updates multiple items.
  Future<List<T>> updateMany(List<T> items);

  /// Deletes multiple items.
  Future<void> deleteMany(List<ID> ids);
}

/// Response wrapper for paginated remote data.
class RemotePagedResponse<T> {
  /// Creates a new [RemotePagedResponse].
  const RemotePagedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    this.hasMore,
  });

  /// The data items.
  final List<T> data;

  /// Total number of items.
  final int total;

  /// Current page.
  final int page;

  /// Page size.
  final int pageSize;

  /// Whether there are more items.
  final bool? hasMore;

  /// Calculates if there are more pages.
  bool get hasMorePages => hasMore ?? (page * pageSize < total);
}

/// Base interface for local data sources.
///
/// Local data sources handle all local storage operations.
abstract class LocalDataSource<T, ID> {
  /// Retrieves all cached items.
  Future<List<T>> getAll();

  /// Retrieves a cached item by [id].
  Future<T?> getById(ID id);

  /// Saves an item to local storage.
  Future<void> save(T item);

  /// Saves multiple items to local storage.
  Future<void> saveAll(List<T> items);

  /// Removes an item from local storage.
  Future<void> remove(ID id);

  /// Clears all cached items.
  Future<void> clear();
}

/// Extended local data source with additional operations.
abstract class ExtendedLocalDataSource<T, ID> extends LocalDataSource<T, ID> {
  /// Checks if an item exists.
  Future<bool> exists(ID id);

  /// Returns the count of cached items.
  Future<int> count();

  /// Gets items by IDs.
  Future<List<T>> getByIds(List<ID> ids);

  /// Searches cached items.
  Future<List<T>> search(String query);

  /// Gets the last update time.
  Future<DateTime?> getLastUpdated();

  /// Sets the last update time.
  Future<void> setLastUpdated(DateTime time);
}

/// Local data source with expiration support.
abstract class ExpirableLocalDataSource<T, ID> extends LocalDataSource<T, ID> {
  /// Gets the cache duration.
  Duration get cacheDuration;

  /// Checks if the cache is expired.
  Future<bool> isExpired();

  /// Checks if a specific item is expired.
  Future<bool> isItemExpired(ID id);

  /// Removes expired items.
  Future<void> removeExpired();
}

/// Mixin for in-memory caching.
mixin InMemoryCache<T, ID> on LocalDataSource<T, ID> {
  /// The in-memory cache.
  final Map<ID, T> cache = {};

  /// The cache timestamps.
  final Map<ID, DateTime> timestamps = {};

  @override
  Future<List<T>> getAll() async => cache.values.toList();

  @override
  Future<T?> getById(ID id) async => cache[id];

  @override
  Future<void> save(T item) async {
    final id = _getId(item);
    cache[id] = item;
    timestamps[id] = DateTime.now();
  }

  @override
  Future<void> saveAll(List<T> items) async {
    for (final item in items) {
      await save(item);
    }
  }

  @override
  Future<void> remove(ID id) async {
    cache.remove(id);
    timestamps.remove(id);
  }

  @override
  Future<void> clear() async {
    cache.clear();
    timestamps.clear();
  }

  /// Gets the ID from an item.
  ID _getId(T item);
}

/// Interface for data source adapters.
///
/// Adapters convert between different data formats.
abstract class DataSourceAdapter<TSource, TTarget> {
  /// Converts from source to target format.
  TTarget fromSource(TSource source);

  /// Converts from target to source format.
  TSource toSource(TTarget target);

  /// Converts a list from source to target format.
  List<TTarget> fromSourceList(List<TSource> sources) {
    return sources.map(fromSource).toList();
  }

  /// Converts a list from target to source format.
  List<TSource> toSourceList(List<TTarget> targets) {
    return targets.map(toSource).toList();
  }
}

/// Mixin for retry logic in data sources.
mixin RetrySupport {
  /// Maximum number of retry attempts.
  int get maxRetries => 3;

  /// Delay between retries.
  Duration get retryDelay => const Duration(seconds: 1);

  /// Executes an operation with retry logic.
  Future<T> withRetry<T>(Future<T> Function() operation) async {
    var attempts = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(retryDelay * attempts);
      }
    }
  }
}

/// Mixin for batch operations.
mixin BatchSupport<T, ID> on RemoteDataSource<T, ID> {
  /// Maximum batch size.
  int get maxBatchSize => 50;

  /// Executes operations in batches.
  Future<List<R>> inBatches<R>(
    List<T> items,
    Future<R> Function(T) operation,
  ) async {
    final results = <R>[];
    for (var i = 0; i < items.length; i += maxBatchSize) {
      final batch = items.skip(i).take(maxBatchSize);
      final batchResults = await Future.wait(batch.map(operation));
      results.addAll(batchResults);
    }
    return results;
  }
}

/// Mixin for sync tracking.
mixin SyncTracking<T, ID> on LocalDataSource<T, ID> {
  /// Records for syncing.
  final Set<ID> _pendingSync = {};

  /// Marks an item as needing sync.
  void markForSync(ID id) => _pendingSync.add(id);

  /// Gets items that need syncing.
  Set<ID> get pendingSync => Set.unmodifiable(_pendingSync);

  /// Clears sync status for an item.
  void clearSyncStatus(ID id) => _pendingSync.remove(id);

  /// Clears all sync statuses.
  void clearAllSyncStatus() => _pendingSync.clear();
}

/// Abstract factory for creating data sources.
abstract class DataSourceFactory<T, ID> {
  /// Creates a remote data source.
  RemoteDataSource<T, ID> createRemoteDataSource();

  /// Creates a local data source.
  LocalDataSource<T, ID> createLocalDataSource();
}

/// Data source configuration.
class DataSourceConfig {
  /// Creates a new [DataSourceConfig].
  const DataSourceConfig({
    this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.enableCache = true,
    this.cacheDuration = const Duration(minutes: 5),
  });

  /// The base URL for remote data source.
  final String? baseUrl;

  /// Request timeout.
  final Duration timeout;

  /// Maximum retry attempts.
  final int maxRetries;

  /// Whether caching is enabled.
  final bool enableCache;

  /// Cache duration.
  final Duration cacheDuration;
}

/// Result type for data source operations.
sealed class DataSourceResult<T> {
  const DataSourceResult();
}

/// Successful result.
class DataSourceSuccess<T> extends DataSourceResult<T> {
  /// Creates a new [DataSourceSuccess].
  const DataSourceSuccess(this.data);

  /// The result data.
  final T data;
}

/// Failure result.
class DataSourceFailure<T> extends DataSourceResult<T> {
  /// Creates a new [DataSourceFailure].
  const DataSourceFailure(this.error, [this.stackTrace]);

  /// The error.
  final Object error;

  /// The stack trace.
  final StackTrace? stackTrace;
}

/// Extension for DataSourceResult.
extension DataSourceResultExtension<T> on DataSourceResult<T> {
  /// Returns true if this is a success.
  bool get isSuccess => this is DataSourceSuccess<T>;

  /// Returns true if this is a failure.
  bool get isFailure => this is DataSourceFailure<T>;

  /// Gets the data if success, throws if failure.
  T get data {
    final self = this;
    if (self is DataSourceSuccess<T>) return self.data;
    throw (self as DataSourceFailure<T>).error;
  }

  /// Gets the data or null.
  T? get dataOrNull {
    final self = this;
    if (self is DataSourceSuccess<T>) return self.data;
    return null;
  }

  /// Maps the data if success.
  DataSourceResult<R> map<R>(R Function(T) transform) {
    final self = this;
    if (self is DataSourceSuccess<T>) {
      return DataSourceSuccess(transform(self.data));
    }
    return DataSourceFailure<R>(
      (self as DataSourceFailure<T>).error,
      self.stackTrace,
    );
  }
}
