/// State management utilities for Clean Architecture.
///
/// Provides base classes and utilities for managing UI state
/// in a clean and predictable way.
library;

import 'package:equatable/equatable.dart';

/// Represents the status of an asynchronous operation.
enum AsyncStatus {
  /// Initial state, no operation started.
  initial,

  /// Operation is in progress.
  loading,

  /// Operation completed successfully.
  success,

  /// Operation failed.
  failure,

  /// Operation is refreshing (has data but loading more).
  refreshing,
}

/// Base class for UI states with async status.
abstract class AsyncState<T> extends Equatable {
  /// Creates a new [AsyncState].
  const AsyncState({
    this.status = AsyncStatus.initial,
    this.data,
    this.error,
    this.stackTrace,
  });

  /// The current status.
  final AsyncStatus status;

  /// The data, if available.
  final T? data;

  /// The error, if any.
  final Object? error;

  /// The error stack trace.
  final StackTrace? stackTrace;

  /// Whether the state is in initial status.
  bool get isInitial => status == AsyncStatus.initial;

  /// Whether the state is loading.
  bool get isLoading => status == AsyncStatus.loading;

  /// Whether the state is successful.
  bool get isSuccess => status == AsyncStatus.success;

  /// Whether the state has failed.
  bool get isFailure => status == AsyncStatus.failure;

  /// Whether the state is refreshing.
  bool get isRefreshing => status == AsyncStatus.refreshing;

  /// Whether the state has data.
  bool get hasData => data != null;

  /// Whether the state has an error.
  bool get hasError => error != null;

  /// Whether the state is loading for the first time (no data yet).
  bool get isInitialLoading => isLoading && !hasData;

  @override
  List<Object?> get props => [status, data, error, stackTrace];
}

/// Generic async value state.
class AsyncValue<T> extends AsyncState<T> {
  /// Creates a new [AsyncValue].
  const AsyncValue({
    super.status,
    super.data,
    super.error,
    super.stackTrace,
  });

  /// Creates an initial state.
  const AsyncValue.initial() : super(status: AsyncStatus.initial);

  /// Creates a loading state.
  const AsyncValue.loading() : super(status: AsyncStatus.loading);

  /// Creates a success state with [data].
  const AsyncValue.success(T data)
      : super(status: AsyncStatus.success, data: data);

  /// Creates a failure state with [error].
  const AsyncValue.failure(Object error, [StackTrace? stackTrace])
      : super(
          status: AsyncStatus.failure,
          error: error,
          stackTrace: stackTrace,
        );

  /// Creates a refreshing state with existing [data].
  const AsyncValue.refreshing(T data)
      : super(status: AsyncStatus.refreshing, data: data);

  /// Creates a copy with the given fields replaced.
  AsyncValue<T> copyWith({
    AsyncStatus? status,
    T? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AsyncValue<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Transforms the data if present.
  AsyncValue<R> map<R>(R Function(T) transform) {
    return AsyncValue<R>(
      status: status,
      data: data != null ? transform(data as T) : null,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles different states with callbacks.
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(Object error, StackTrace? stackTrace) failure,
    R Function(T data)? refreshing,
  }) {
    switch (status) {
      case AsyncStatus.initial:
        return initial();
      case AsyncStatus.loading:
        return loading();
      case AsyncStatus.success:
        return success(data as T);
      case AsyncStatus.failure:
        return failure(error!, stackTrace);
      case AsyncStatus.refreshing:
        return refreshing != null ? refreshing(data as T) : success(data as T);
    }
  }

  /// Handles states with optional callbacks.
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(Object error, StackTrace? stackTrace)? failure,
    R Function(T data)? refreshing,
    required R Function() orElse,
  }) {
    switch (status) {
      case AsyncStatus.initial:
        return initial?.call() ?? orElse();
      case AsyncStatus.loading:
        return loading?.call() ?? orElse();
      case AsyncStatus.success:
        return success?.call(data as T) ?? orElse();
      case AsyncStatus.failure:
        return failure?.call(error!, stackTrace) ?? orElse();
      case AsyncStatus.refreshing:
        return refreshing?.call(data as T) ??
            success?.call(data as T) ??
            orElse();
    }
  }
}

/// State for paginated data.
class PaginatedState<T> extends Equatable {
  /// Creates a new [PaginatedState].
  const PaginatedState({
    this.items = const [],
    this.status = AsyncStatus.initial,
    this.currentPage = 0,
    this.hasMore = true,
    this.error,
  });

  /// The loaded items.
  final List<T> items;

  /// The current status.
  final AsyncStatus status;

  /// The current page number.
  final int currentPage;

  /// Whether there are more items to load.
  final bool hasMore;

  /// The error, if any.
  final Object? error;

  /// Whether the state is loading.
  bool get isLoading => status == AsyncStatus.loading;

  /// Whether the state has items.
  bool get hasItems => items.isNotEmpty;

  /// Whether initial loading is in progress.
  bool get isInitialLoading => isLoading && items.isEmpty;

  /// Whether loading more items.
  bool get isLoadingMore => isLoading && items.isNotEmpty;

  /// Creates a copy with the given fields replaced.
  PaginatedState<T> copyWith({
    List<T>? items,
    AsyncStatus? status,
    int? currentPage,
    bool? hasMore,
    Object? error,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  /// Appends new items.
  PaginatedState<T> appendItems(List<T> newItems, {bool hasMore = true}) {
    return copyWith(
      items: [...items, ...newItems],
      status: AsyncStatus.success,
      currentPage: currentPage + 1,
      hasMore: hasMore,
    );
  }

  /// Replaces all items.
  PaginatedState<T> replaceItems(List<T> newItems, {bool hasMore = true}) {
    return copyWith(
      items: newItems,
      status: AsyncStatus.success,
      currentPage: 1,
      hasMore: hasMore,
    );
  }

  @override
  List<Object?> get props => [items, status, currentPage, hasMore, error];
}

/// State for form data.
class FormState<T> extends Equatable {
  /// Creates a new [FormState].
  const FormState({
    required this.data,
    this.status = AsyncStatus.initial,
    this.errors = const {},
    this.isValid = false,
    this.isDirty = false,
    this.submitError,
  });

  /// The form data.
  final T data;

  /// The submission status.
  final AsyncStatus status;

  /// Field-level errors.
  final Map<String, String> errors;

  /// Whether the form is valid.
  final bool isValid;

  /// Whether the form has been modified.
  final bool isDirty;

  /// Error from submission attempt.
  final Object? submitError;

  /// Whether the form is submitting.
  bool get isSubmitting => status == AsyncStatus.loading;

  /// Whether submission was successful.
  bool get isSubmitSuccess => status == AsyncStatus.success;

  /// Whether there are validation errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Gets the error for a specific field.
  String? getError(String field) => errors[field];

  /// Creates a copy with the given fields replaced.
  FormState<T> copyWith({
    T? data,
    AsyncStatus? status,
    Map<String, String>? errors,
    bool? isValid,
    bool? isDirty,
    Object? submitError,
  }) {
    return FormState<T>(
      data: data ?? this.data,
      status: status ?? this.status,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      isDirty: isDirty ?? this.isDirty,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props =>
      [data, status, errors, isValid, isDirty, submitError];
}

/// State for selection.
class SelectionState<T> extends Equatable {
  /// Creates a new [SelectionState].
  const SelectionState({
    this.items = const [],
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });

  /// All available items.
  final List<T> items;

  /// IDs of selected items.
  final Set<String> selectedIds;

  /// Whether selection mode is active.
  final bool isSelectionMode;

  /// Number of selected items.
  int get selectedCount => selectedIds.length;

  /// Whether any items are selected.
  bool get hasSelection => selectedIds.isNotEmpty;

  /// Whether all items are selected.
  bool get isAllSelected =>
      items.isNotEmpty && selectedIds.length == items.length;

  /// Checks if an item is selected.
  bool isSelected(String id) => selectedIds.contains(id);

  /// Creates a copy with the given fields replaced.
  SelectionState<T> copyWith({
    List<T>? items,
    Set<String>? selectedIds,
    bool? isSelectionMode,
  }) {
    return SelectionState<T>(
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  /// Toggles selection for an item.
  SelectionState<T> toggleSelection(String id) {
    final newSelection = Set<String>.from(selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    return copyWith(selectedIds: newSelection);
  }

  /// Selects all items.
  SelectionState<T> selectAll(List<String> ids) {
    return copyWith(selectedIds: ids.toSet());
  }

  /// Clears selection.
  SelectionState<T> clearSelection() {
    return copyWith(selectedIds: {}, isSelectionMode: false);
  }

  @override
  List<Object?> get props => [items, selectedIds, isSelectionMode];
}

/// State for search functionality.
class SearchState<T> extends Equatable {
  /// Creates a new [SearchState].
  const SearchState({
    this.query = '',
    this.results = const [],
    this.status = AsyncStatus.initial,
    this.suggestions = const [],
    this.recentSearches = const [],
    this.error,
  });

  /// The search query.
  final String query;

  /// Search results.
  final List<T> results;

  /// Search status.
  final AsyncStatus status;

  /// Search suggestions.
  final List<String> suggestions;

  /// Recent search queries.
  final List<String> recentSearches;

  /// Search error.
  final Object? error;

  /// Whether a search is in progress.
  bool get isSearching => status == AsyncStatus.loading;

  /// Whether there are results.
  bool get hasResults => results.isNotEmpty;

  /// Whether the query is empty.
  bool get isQueryEmpty => query.isEmpty;

  /// Creates a copy with the given fields replaced.
  SearchState<T> copyWith({
    String? query,
    List<T>? results,
    AsyncStatus? status,
    List<String>? suggestions,
    List<String>? recentSearches,
    Object? error,
  }) {
    return SearchState<T>(
      query: query ?? this.query,
      results: results ?? this.results,
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      recentSearches: recentSearches ?? this.recentSearches,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [query, results, status, suggestions, recentSearches, error];
}

/// Mixin for states that track field changes.
mixin FieldTracking {
  /// Set of changed field names.
  final Set<String> _changedFields = {};

  /// Marks a field as changed.
  void markFieldChanged(String field) => _changedFields.add(field);

  /// Checks if a field has changed.
  bool hasFieldChanged(String field) => _changedFields.contains(field);

  /// Gets all changed fields.
  Set<String> get changedFields => Set.unmodifiable(_changedFields);

  /// Clears change tracking.
  void clearFieldTracking() => _changedFields.clear();
}
