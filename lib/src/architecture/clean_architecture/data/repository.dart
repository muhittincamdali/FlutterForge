/// Base repository patterns for Clean Architecture.
///
/// Repositories act as an abstraction layer between the domain
/// and data layers, providing a clean API for data operations.
library;

/// Base interface for repository operations.
///
/// Defines the common CRUD operations that most repositories
/// should implement.
///
/// Type parameters:
/// - [T]: The entity type
/// - [ID]: The identifier type
abstract class Repository<T, ID> {
  /// Retrieves all entities.
  Future<List<T>> getAll();

  /// Retrieves an entity by its [id].
  Future<T?> getById(ID id);

  /// Creates a new entity.
  Future<T> create(T entity);

  /// Updates an existing entity.
  Future<T> update(T entity);

  /// Deletes an entity by its [id].
  Future<void> delete(ID id);
}

/// Extended repository interface with additional operations.
abstract class ExtendedRepository<T, ID> extends Repository<T, ID> {
  /// Retrieves multiple entities by their [ids].
  Future<List<T>> getByIds(List<ID> ids);

  /// Creates multiple entities.
  Future<List<T>> createMany(List<T> entities);

  /// Updates multiple entities.
  Future<List<T>> updateMany(List<T> entities);

  /// Deletes multiple entities by their [ids].
  Future<void> deleteMany(List<ID> ids);

  /// Checks if an entity with the given [id] exists.
  Future<bool> exists(ID id);

  /// Returns the total count of entities.
  Future<int> count();
}

/// Repository interface with pagination support.
abstract class PaginatedRepository<T, ID> extends Repository<T, ID> {
  /// Retrieves a page of entities.
  Future<PagedResult<T>> getPage({
    required int page,
    required int pageSize,
    String? sortBy,
    bool ascending = true,
  });
}

/// Repository interface with search support.
abstract class SearchableRepository<T, ID> extends Repository<T, ID> {
  /// Searches for entities matching the [query].
  Future<List<T>> search(String query);

  /// Searches with pagination.
  Future<PagedResult<T>> searchPaginated({
    required String query,
    required int page,
    required int pageSize,
  });
}

/// Repository interface with soft delete support.
abstract class SoftDeletableRepository<T, ID> extends Repository<T, ID> {
  /// Soft deletes an entity by its [id].
  Future<void> softDelete(ID id);

  /// Restores a soft-deleted entity.
  Future<void> restore(ID id);

  /// Retrieves all soft-deleted entities.
  Future<List<T>> getDeleted();

  /// Permanently deletes a soft-deleted entity.
  Future<void> hardDelete(ID id);
}

/// Repository interface with caching support.
abstract class CacheableRepository<T, ID> extends Repository<T, ID> {
  /// Refreshes the cache.
  Future<void> refreshCache();

  /// Clears the cache.
  Future<void> clearCache();

  /// Checks if data is cached.
  Future<bool> isCached();
}

/// Repository interface for reactive data.
abstract class ReactiveRepository<T, ID> extends Repository<T, ID> {
  /// Watches all entities.
  Stream<List<T>> watchAll();

  /// Watches a single entity by its [id].
  Stream<T?> watchById(ID id);
}

/// Result class for paginated queries.
class PagedResult<T> {
  /// Creates a new [PagedResult].
  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  /// The items in this page.
  final List<T> items;

  /// The total count of all items.
  final int totalCount;

  /// The current page number.
  final int page;

  /// The page size.
  final int pageSize;

  /// The total number of pages.
  int get totalPages => (totalCount / pageSize).ceil();

  /// Whether there is a next page.
  bool get hasNextPage => page < totalPages;

  /// Whether there is a previous page.
  bool get hasPreviousPage => page > 1;

  /// Whether this is the first page.
  bool get isFirstPage => page == 1;

  /// Whether this is the last page.
  bool get isLastPage => page >= totalPages;

  /// Creates a copy with the given fields replaced.
  PagedResult<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? page,
    int? pageSize,
  }) {
    return PagedResult(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Maps the items to a different type.
  PagedResult<R> map<R>(R Function(T) transform) {
    return PagedResult(
      items: items.map(transform).toList(),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Sort direction enum.
enum SortDirection {
  /// Ascending order.
  ascending,

  /// Descending order.
  descending,
}

/// Sort options for queries.
class SortOptions {
  /// Creates a new [SortOptions].
  const SortOptions({
    required this.field,
    this.direction = SortDirection.ascending,
  });

  /// The field to sort by.
  final String field;

  /// The sort direction.
  final SortDirection direction;

  /// Whether sorting is ascending.
  bool get isAscending => direction == SortDirection.ascending;
}

/// Filter options for queries.
class FilterOptions {
  /// Creates a new [FilterOptions].
  const FilterOptions({
    this.filters = const {},
    this.sort,
  });

  /// The filter criteria.
  final Map<String, dynamic> filters;

  /// The sort options.
  final SortOptions? sort;

  /// Creates a copy with additional filters.
  FilterOptions withFilter(String key, dynamic value) {
    return FilterOptions(
      filters: {...filters, key: value},
      sort: sort,
    );
  }

  /// Creates a copy with sort options.
  FilterOptions withSort(SortOptions sort) {
    return FilterOptions(
      filters: filters,
      sort: sort,
    );
  }
}

/// Query builder for complex queries.
class QueryBuilder<T> {
  /// Creates a new [QueryBuilder].
  QueryBuilder();

  final List<_QueryCondition> _conditions = [];
  SortOptions? _sort;
  int? _limit;
  int? _offset;

  /// Adds a where condition.
  QueryBuilder<T> where(String field, dynamic value) {
    _conditions.add(_QueryCondition(field, _Operator.equals, value));
    return this;
  }

  /// Adds a not equal condition.
  QueryBuilder<T> whereNot(String field, dynamic value) {
    _conditions.add(_QueryCondition(field, _Operator.notEquals, value));
    return this;
  }

  /// Adds a greater than condition.
  QueryBuilder<T> whereGreaterThan(String field, dynamic value) {
    _conditions.add(_QueryCondition(field, _Operator.greaterThan, value));
    return this;
  }

  /// Adds a less than condition.
  QueryBuilder<T> whereLessThan(String field, dynamic value) {
    _conditions.add(_QueryCondition(field, _Operator.lessThan, value));
    return this;
  }

  /// Adds an in condition.
  QueryBuilder<T> whereIn(String field, List<dynamic> values) {
    _conditions.add(_QueryCondition(field, _Operator.inList, values));
    return this;
  }

  /// Adds a contains condition.
  QueryBuilder<T> whereContains(String field, String value) {
    _conditions.add(_QueryCondition(field, _Operator.contains, value));
    return this;
  }

  /// Sets the sort order.
  QueryBuilder<T> orderBy(String field, {bool ascending = true}) {
    _sort = SortOptions(
      field: field,
      direction: ascending ? SortDirection.ascending : SortDirection.descending,
    );
    return this;
  }

  /// Sets the limit.
  QueryBuilder<T> limit(int limit) {
    _limit = limit;
    return this;
  }

  /// Sets the offset.
  QueryBuilder<T> offset(int offset) {
    _offset = offset;
    return this;
  }

  /// Builds the query options.
  QueryOptions build() {
    return QueryOptions(
      conditions: List.unmodifiable(_conditions),
      sort: _sort,
      limit: _limit,
      offset: _offset,
    );
  }
}

/// Query options for repositories.
class QueryOptions {
  /// Creates a new [QueryOptions].
  const QueryOptions({
    this.conditions = const [],
    this.sort,
    this.limit,
    this.offset,
  });

  /// The query conditions.
  final List<_QueryCondition> conditions;

  /// The sort options.
  final SortOptions? sort;

  /// The limit.
  final int? limit;

  /// The offset.
  final int? offset;
}

enum _Operator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  inList,
  contains,
}

class _QueryCondition {
  const _QueryCondition(this.field, this.operator, this.value);

  final String field;
  final _Operator operator;
  final dynamic value;
}

/// Mixin for repositories with offline support.
mixin OfflineSupport<T, ID> on Repository<T, ID> {
  /// Queues an operation for when online.
  Future<void> queueOperation(_OfflineOperation operation);

  /// Syncs queued operations.
  Future<void> syncOperations();

  /// Returns pending operations count.
  Future<int> pendingOperationsCount();
}

enum _OfflineOperation { create, update, delete }
