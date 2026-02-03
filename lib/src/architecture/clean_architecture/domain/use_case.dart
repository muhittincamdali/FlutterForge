/// Base classes for use cases in Clean Architecture.
///
/// Use cases encapsulate business logic and represent specific
/// operations that can be performed in the application.
library;

import 'package:equatable/equatable.dart';

/// Base class for use cases that return a value.
///
/// Type parameters:
/// - [Type]: The return type of the use case
/// - [Params]: The parameters required by the use case
///
/// Example:
/// ```dart
/// class GetUserUseCase extends UseCase<User, GetUserParams> {
///   final UserRepository repository;
///
///   GetUserUseCase(this.repository);
///
///   @override
///   Future<User> call(GetUserParams params) async {
///     return repository.getUserById(params.userId);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns a [Future] that completes with the result of type [Type].
  Future<Type> call(Params params);
}

/// Base class for use cases that don't require parameters.
///
/// Example:
/// ```dart
/// class GetAllUsersUseCase extends UseCaseNoParams<List<User>> {
///   final UserRepository repository;
///
///   GetAllUsersUseCase(this.repository);
///
///   @override
///   Future<List<User>> call() async {
///     return repository.getAllUsers();
///   }
/// }
/// ```
abstract class UseCaseNoParams<Type> {
  /// Executes the use case without parameters.
  ///
  /// Returns a [Future] that completes with the result of type [Type].
  Future<Type> call();
}

/// Base class for synchronous use cases.
///
/// Use this for operations that don't require async processing.
abstract class SyncUseCase<Type, Params> {
  /// Executes the use case synchronously with the given [params].
  Type call(Params params);
}

/// Base class for synchronous use cases without parameters.
abstract class SyncUseCaseNoParams<Type> {
  /// Executes the use case synchronously without parameters.
  Type call();
}

/// Base class for use cases that return a Stream.
///
/// Useful for operations that need to emit multiple values over time.
///
/// Example:
/// ```dart
/// class WatchUserUseCase extends StreamUseCase<User, WatchUserParams> {
///   final UserRepository repository;
///
///   WatchUserUseCase(this.repository);
///
///   @override
///   Stream<User> call(WatchUserParams params) {
///     return repository.watchUser(params.userId);
///   }
/// }
/// ```
abstract class StreamUseCase<Type, Params> {
  /// Executes the use case and returns a [Stream] of values.
  Stream<Type> call(Params params);
}

/// Base class for stream use cases without parameters.
abstract class StreamUseCaseNoParams<Type> {
  /// Executes the use case and returns a [Stream] of values.
  Stream<Type> call();
}

/// Empty parameters for use cases that don't require input.
///
/// Use this instead of [void] for type safety with the [UseCase] class.
class NoParams extends Equatable {
  /// Creates a new [NoParams] instance.
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Base class for paginated parameters.
///
/// Provides common pagination fields that can be extended.
class PaginatedParams extends Equatable {
  /// Creates a new [PaginatedParams] instance.
  const PaginatedParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.ascending = true,
  });

  /// The page number (1-indexed).
  final int page;

  /// The number of items per page.
  final int pageSize;

  /// Optional field to sort by.
  final String? sortBy;

  /// Whether to sort in ascending order.
  final bool ascending;

  /// Calculates the offset for database queries.
  int get offset => (page - 1) * pageSize;

  @override
  List<Object?> get props => [page, pageSize, sortBy, ascending];
}

/// Base class for search parameters.
class SearchParams extends Equatable {
  /// Creates a new [SearchParams] instance.
  const SearchParams({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
    this.filters = const {},
  });

  /// The search query string.
  final String query;

  /// The page number.
  final int page;

  /// The number of items per page.
  final int pageSize;

  /// Additional filters for the search.
  final Map<String, dynamic> filters;

  @override
  List<Object?> get props => [query, page, pageSize, filters];
}

/// Base class for ID-based parameters.
class IdParams extends Equatable {
  /// Creates a new [IdParams] instance.
  const IdParams(this.id);

  /// The unique identifier.
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Base class for multiple ID parameters.
class IdsParams extends Equatable {
  /// Creates a new [IdsParams] instance.
  const IdsParams(this.ids);

  /// The list of unique identifiers.
  final List<String> ids;

  @override
  List<Object?> get props => [ids];
}

/// Mixin for use cases that need logging.
mixin UseCaseLogging<Type, Params> on UseCase<Type, Params> {
  /// Logger name for this use case.
  String get loggerName => runtimeType.toString();

  /// Logs the execution start.
  void logStart(Params params) {
    // Override to implement logging
  }

  /// Logs the execution success.
  void logSuccess(Type result) {
    // Override to implement logging
  }

  /// Logs the execution failure.
  void logFailure(Object error, StackTrace stackTrace) {
    // Override to implement logging
  }
}

/// Mixin for use cases that need caching.
mixin UseCaseCaching<Type, Params> on UseCase<Type, Params> {
  /// Cache duration for this use case.
  Duration get cacheDuration => const Duration(minutes: 5);

  /// Generates a cache key from params.
  String getCacheKey(Params params) {
    return '${runtimeType}_$params';
  }

  /// Gets cached value if available.
  Future<Type?> getCached(Params params) async {
    // Override to implement caching
    return null;
  }

  /// Caches the result.
  Future<void> cache(Params params, Type result) async {
    // Override to implement caching
  }
}

/// Mixin for use cases that need rate limiting.
mixin UseCaseRateLimiting<Type, Params> on UseCase<Type, Params> {
  /// Minimum interval between calls.
  Duration get minInterval => const Duration(seconds: 1);

  /// Maximum calls per interval.
  int get maxCalls => 10;

  /// Checks if the use case can be executed.
  bool canExecute() {
    // Override to implement rate limiting
    return true;
  }
}
