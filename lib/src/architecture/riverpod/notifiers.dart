/// Riverpod notifier base classes and utilities.
///
/// Provides reusable notifier patterns for common use cases
/// in Riverpod state management.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for async notifiers with error handling.
abstract class AsyncNotifier<T> extends StateNotifier<AsyncValue<T>> {
  /// Creates a new [AsyncNotifier].
  AsyncNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  /// Initializes the notifier.
  Future<void> _init() async {
    await load();
  }

  /// Loads the initial data.
  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  /// Refreshes the data.
  Future<void> refresh() async {
    state = AsyncValue.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(build);
  }

  /// Override to build the initial state.
  Future<T> build();
}

/// Extension for AsyncValue with previous value.
extension AsyncValueCopyWithPrevious<T> on AsyncValue<T> {
  /// Creates a loading state with previous value.
  AsyncValue<T> copyWithPrevious(AsyncValue<T> previous) {
    return previous.when(
      data: (d) => AsyncValue<T>.loading().copyWithPrevious(previous),
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue<T>.error(e, s),
    );
  }
}

/// Base notifier for list operations.
abstract class ListNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  /// Creates a new [ListNotifier].
  ListNotifier() : super(const AsyncValue.data([])) {
    _init();
  }

  /// Initializes the notifier.
  Future<void> _init() async {
    await load();
  }

  /// Loads all items.
  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fetchAll);
  }

  /// Refreshes items.
  Future<void> refresh() async {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current);
    state = await AsyncValue.guard(fetchAll);
  }

  /// Adds an item.
  Future<void> add(T item) async {
    final current = state.valueOrNull ?? [];
    state = await AsyncValue.guard(() async {
      final created = await create(item);
      return [...current, created];
    });
  }

  /// Updates an item.
  Future<void> updateItem(T item) async {
    final current = state.valueOrNull ?? [];
    state = await AsyncValue.guard(() async {
      final updated = await update(item);
      return current.map((i) => getId(i) == getId(updated) ? updated : i).toList();
    });
  }

  /// Removes an item.
  Future<void> remove(T item) async {
    final current = state.valueOrNull ?? [];
    final id = getId(item);
    state = await AsyncValue.guard(() async {
      await delete(id);
      return current.where((i) => getId(i) != id).toList();
    });
  }

  /// Gets the ID of an item.
  dynamic getId(T item);

  /// Fetches all items.
  Future<List<T>> fetchAll();

  /// Creates an item.
  Future<T> create(T item);

  /// Updates an item.
  Future<T> update(T item);

  /// Deletes an item by ID.
  Future<void> delete(dynamic id);
}

/// Base notifier for paginated data.
abstract class PaginatedNotifier<T>
    extends StateNotifier<PaginatedState<T>> {
  /// Creates a new [PaginatedNotifier].
  PaginatedNotifier() : super(PaginatedState<T>.initial()) {
    _init();
  }

  /// Page size for pagination.
  int get pageSize => 20;

  /// Initializes the notifier.
  Future<void> _init() async {
    await loadFirstPage();
  }

  /// Loads the first page.
  Future<void> loadFirstPage() async {
    state = state.copyWith(status: PaginatedStatus.loading);
    try {
      final items = await fetchPage(0, pageSize);
      state = state.copyWith(
        items: items,
        page: 1,
        hasMore: items.length >= pageSize,
        status: PaginatedStatus.success,
      );
    } catch (e, s) {
      state = state.copyWith(
        status: PaginatedStatus.error,
        error: e,
      );
    }
  }

  /// Loads the next page.
  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(status: PaginatedStatus.loadingMore);
    try {
      final items = await fetchPage(state.page, pageSize);
      state = state.copyWith(
        items: [...state.items, ...items],
        page: state.page + 1,
        hasMore: items.length >= pageSize,
        status: PaginatedStatus.success,
      );
    } catch (e, s) {
      state = state.copyWith(status: PaginatedStatus.success);
    }
  }

  /// Refreshes from the first page.
  Future<void> refresh() async {
    state = PaginatedState<T>.initial();
    await loadFirstPage();
  }

  /// Fetches a page of items.
  Future<List<T>> fetchPage(int page, int pageSize);
}

/// Status for paginated data.
enum PaginatedStatus {
  /// Initial state.
  initial,

  /// Loading first page.
  loading,

  /// Loading more items.
  loadingMore,

  /// Loaded successfully.
  success,

  /// Error occurred.
  error,
}

/// State for paginated notifiers.
class PaginatedState<T> {
  /// Creates a new [PaginatedState].
  const PaginatedState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.status = PaginatedStatus.initial,
    this.error,
  });

  /// Initial state.
  factory PaginatedState.initial() => PaginatedState<T>();

  /// The items.
  final List<T> items;

  /// Current page.
  final int page;

  /// Whether more pages exist.
  final bool hasMore;

  /// Current status.
  final PaginatedStatus status;

  /// Error if any.
  final Object? error;

  /// Whether initial loading.
  bool get isLoading => status == PaginatedStatus.loading;

  /// Whether loading more.
  bool get isLoadingMore => status == PaginatedStatus.loadingMore;

  /// Whether has error.
  bool get hasError => status == PaginatedStatus.error;

  /// Creates a copy.
  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    PaginatedStatus? status,
    Object? error,
  }) {
    return PaginatedState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      status: status ?? this.status,
      error: error,
    );
  }
}

/// Base notifier for form state.
abstract class FormNotifier<T> extends StateNotifier<FormNotifierState<T>> {
  /// Creates a new [FormNotifier].
  FormNotifier(T initialData)
      : super(FormNotifierState(data: initialData));

  /// Updates form data.
  void updateData(T data) {
    state = state.copyWith(data: data, isDirty: true);
    validate();
  }

  /// Updates a field.
  void updateField(T Function(T) updater) {
    state = state.copyWith(data: updater(state.data), isDirty: true);
    validate();
  }

  /// Validates the form.
  void validate() {
    final errors = performValidation(state.data);
    state = state.copyWith(
      errors: errors,
      isValid: errors.isEmpty,
    );
  }

  /// Submits the form.
  Future<void> submit() async {
    validate();
    if (!state.isValid) return;

    state = state.copyWith(isSubmitting: true);
    try {
      await performSubmit(state.data);
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: e.toString(),
      );
    }
  }

  /// Resets the form.
  void reset(T initialData) {
    state = FormNotifierState(data: initialData);
  }

  /// Performs validation.
  Map<String, String> performValidation(T data);

  /// Performs submission.
  Future<void> performSubmit(T data);
}

/// State for form notifiers.
class FormNotifierState<T> {
  /// Creates a new [FormNotifierState].
  const FormNotifierState({
    required this.data,
    this.errors = const {},
    this.isValid = false,
    this.isDirty = false,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.submitError,
  });

  /// Form data.
  final T data;

  /// Field errors.
  final Map<String, String> errors;

  /// Whether form is valid.
  final bool isValid;

  /// Whether form has been modified.
  final bool isDirty;

  /// Whether form is being submitted.
  final bool isSubmitting;

  /// Whether form has been submitted.
  final bool isSubmitted;

  /// Submission error.
  final String? submitError;

  /// Creates a copy.
  FormNotifierState<T> copyWith({
    T? data,
    Map<String, String>? errors,
    bool? isValid,
    bool? isDirty,
    bool? isSubmitting,
    bool? isSubmitted,
    String? submitError,
  }) {
    return FormNotifierState(
      data: data ?? this.data,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      isDirty: isDirty ?? this.isDirty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submitError: submitError,
    );
  }
}

/// Base notifier for selection state.
class SelectionNotifier<T> extends StateNotifier<SelectionState<T>> {
  /// Creates a new [SelectionNotifier].
  SelectionNotifier() : super(SelectionState<T>.initial());

  /// Sets the items.
  void setItems(List<T> items) {
    state = state.copyWith(items: items);
  }

  /// Toggles selection for an item.
  void toggle(String id) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedIds: selected);
  }

  /// Selects all items.
  void selectAll(List<String> ids) {
    state = state.copyWith(selectedIds: ids.toSet());
  }

  /// Clears selection.
  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  /// Enters selection mode.
  void enterSelectionMode() {
    state = state.copyWith(isSelectionMode: true);
  }

  /// Exits selection mode.
  void exitSelectionMode() {
    state = state.copyWith(isSelectionMode: false, selectedIds: {});
  }
}

/// State for selection notifiers.
class SelectionState<T> {
  /// Creates a new [SelectionState].
  const SelectionState({
    this.items = const [],
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });

  /// Initial state.
  factory SelectionState.initial() => SelectionState<T>();

  /// All items.
  final List<T> items;

  /// Selected IDs.
  final Set<String> selectedIds;

  /// Whether in selection mode.
  final bool isSelectionMode;

  /// Number of selected items.
  int get selectedCount => selectedIds.length;

  /// Whether any items selected.
  bool get hasSelection => selectedIds.isNotEmpty;

  /// Creates a copy.
  SelectionState<T> copyWith({
    List<T>? items,
    Set<String>? selectedIds,
    bool? isSelectionMode,
  }) {
    return SelectionState(
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}

/// Mixin for debounced state updates.
mixin DebouncedNotifier<T> on StateNotifier<T> {
  Timer? _debounceTimer;

  /// Debounce duration.
  Duration get debounceDuration => const Duration(milliseconds: 300);

  /// Updates state with debounce.
  void debouncedUpdate(T newState) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      state = newState;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Mixin for notifiers with undo support.
mixin UndoableNotifier<T> on StateNotifier<T> {
  final List<T> _history = [];
  int _historyIndex = -1;

  /// Maximum history size.
  int get maxHistorySize => 50;

  /// Whether can undo.
  bool get canUndo => _historyIndex > 0;

  /// Whether can redo.
  bool get canRedo => _historyIndex < _history.length - 1;

  /// Records state for undo.
  void recordState() {
    // Remove any redo states
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(state);
    _historyIndex = _history.length - 1;

    // Limit history size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  /// Undoes the last change.
  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    state = _history[_historyIndex];
  }

  /// Redoes the last undone change.
  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    state = _history[_historyIndex];
  }
}
