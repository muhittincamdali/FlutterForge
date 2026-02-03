/// Base classes for MVVM architecture ViewModels.
///
/// ViewModels contain presentation logic and state management,
/// acting as an intermediary between the View and the Model.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Base class for all ViewModels.
///
/// Extends [ChangeNotifier] to support Flutter's listener pattern.
///
/// Example:
/// ```dart
/// class CounterViewModel extends ViewModel {
///   int _count = 0;
///   int get count => _count;
///
///   void increment() {
///     _count++;
///     notifyListeners();
///   }
/// }
/// ```
abstract class ViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  bool _isBusy = false;
  String? _errorMessage;

  /// Whether this ViewModel has been disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the ViewModel is currently busy (loading).
  bool get isBusy => _isBusy;

  /// The current error message, if any.
  String? get errorMessage => _errorMessage;

  /// Whether there is an error.
  bool get hasError => _errorMessage != null;

  /// Sets the busy state and notifies listeners.
  @protected
  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  /// Sets the error message and notifies listeners.
  @protected
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the error and notifies listeners.
  void clearError() => setError(null);

  /// Runs an async operation with automatic busy state management.
  @protected
  Future<T?> runBusyFuture<T>(
    Future<T> Function() operation, {
    bool throwOnError = false,
  }) async {
    setBusy(true);
    clearError();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      if (throwOnError) rethrow;
      return null;
    } finally {
      setBusy(false);
    }
  }

  /// Safe notification that checks disposal state.
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// ViewModel with initialization support.
abstract class InitializableViewModel extends ViewModel {
  bool _isInitialized = false;

  /// Whether the ViewModel has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the ViewModel.
  @mustCallSuper
  Future<void> initialize() async {
    if (_isInitialized) return;

    setBusy(true);
    try {
      await onInitialize();
      _isInitialized = true;
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  /// Override to perform initialization logic.
  @protected
  Future<void> onInitialize();
}

/// ViewModel with lifecycle awareness.
abstract class LifecycleViewModel extends InitializableViewModel {
  /// Called when the view becomes visible.
  void onResume() {}

  /// Called when the view becomes invisible.
  void onPause() {}

  /// Called when the view is about to be destroyed.
  void onDestroy() {}
}

/// ViewModel with single data value.
abstract class SingleValueViewModel<T> extends ViewModel {
  T? _value;

  /// The current value.
  T? get value => _value;

  /// Whether a value is present.
  bool get hasValue => _value != null;

  /// Sets the value and notifies listeners.
  @protected
  void setValue(T? value) {
    _value = value;
    notifyListeners();
  }

  /// Loads the value.
  Future<void> load() async {
    await runBusyFuture(() async {
      _value = await fetchValue();
      notifyListeners();
    });
  }

  /// Override to fetch the value.
  @protected
  Future<T> fetchValue();
}

/// ViewModel with a list of items.
abstract class ListViewModel<T> extends ViewModel {
  final List<T> _items = [];

  /// The current list of items.
  List<T> get items => List.unmodifiable(_items);

  /// The number of items.
  int get itemCount => _items.length;

  /// Whether the list is empty.
  bool get isEmpty => _items.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Gets an item at [index].
  T? itemAt(int index) {
    if (index < 0 || index >= _items.length) return null;
    return _items[index];
  }

  /// Sets the items and notifies listeners.
  @protected
  void setItems(List<T> items) {
    _items.clear();
    _items.addAll(items);
    notifyListeners();
  }

  /// Adds an item and notifies listeners.
  @protected
  void addItem(T item) {
    _items.add(item);
    notifyListeners();
  }

  /// Removes an item and notifies listeners.
  @protected
  void removeItem(T item) {
    _items.remove(item);
    notifyListeners();
  }

  /// Removes an item at [index] and notifies listeners.
  @protected
  void removeItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Clears all items and notifies listeners.
  @protected
  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  /// Loads the items.
  Future<void> load() async {
    await runBusyFuture(() async {
      final items = await fetchItems();
      setItems(items);
    });
  }

  /// Override to fetch items.
  @protected
  Future<List<T>> fetchItems();
}

/// ViewModel with pagination support.
abstract class PaginatedViewModel<T> extends ListViewModel<T> {
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  /// The current page number.
  int get currentPage => _currentPage;

  /// Whether there are more items to load.
  bool get hasMore => _hasMore;

  /// Whether more items are being loaded.
  bool get isLoadingMore => _isLoadingMore;

  /// The page size.
  int get pageSize => 20;

  /// Loads the first page.
  @override
  Future<void> load() async {
    _currentPage = 0;
    _hasMore = true;
    await runBusyFuture(() async {
      final items = await fetchPage(0);
      setItems(items);
      _currentPage = 1;
      _hasMore = items.length >= pageSize;
    });
  }

  /// Loads the next page.
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || isBusy) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final items = await fetchPage(_currentPage);
      _items.addAll(items);
      _currentPage++;
      _hasMore = items.length >= pageSize;
    } catch (e) {
      setError(e.toString());
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refreshes the list.
  Future<void> refresh() async {
    await load();
  }

  @override
  Future<List<T>> fetchItems() => fetchPage(0);

  /// Override to fetch a specific page.
  @protected
  Future<List<T>> fetchPage(int page);
}

/// ViewModel with search functionality.
abstract class SearchableViewModel<T> extends ListViewModel<T> {
  String _searchQuery = '';
  Timer? _debounceTimer;
  final List<T> _allItems = [];

  /// The current search query.
  String get searchQuery => _searchQuery;

  /// Whether a search is active.
  bool get isSearching => _searchQuery.isNotEmpty;

  /// The debounce duration for search.
  Duration get searchDebounce => const Duration(milliseconds: 300);

  /// Sets the search query with debouncing.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(searchDebounce, _performSearch);
    notifyListeners();
  }

  /// Clears the search query.
  void clearSearch() {
    _searchQuery = '';
    _debounceTimer?.cancel();
    setItems(_allItems);
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setItems(_allItems);
    } else {
      final filtered = _allItems.where((item) => matchesSearch(item, _searchQuery)).toList();
      setItems(filtered);
    }
  }

  /// Override to define search matching logic.
  @protected
  bool matchesSearch(T item, String query);

  @override
  Future<void> load() async {
    await runBusyFuture(() async {
      final items = await fetchItems();
      _allItems.clear();
      _allItems.addAll(items);
      setItems(items);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// ViewModel for form handling.
abstract class FormViewModel<T> extends ViewModel {
  T _formData;
  final Map<String, String?> _fieldErrors = {};
  bool _isSubmitting = false;
  bool _isValid = false;

  /// Creates a [FormViewModel] with initial data.
  FormViewModel(this._formData);

  /// The current form data.
  T get formData => _formData;

  /// Whether the form is valid.
  bool get isValid => _isValid;

  /// Whether the form is being submitted.
  bool get isSubmitting => _isSubmitting;

  /// Whether the form can be submitted.
  bool get canSubmit => _isValid && !_isSubmitting;

  /// Gets the error for a field.
  String? getFieldError(String field) => _fieldErrors[field];

  /// Whether a field has an error.
  bool hasFieldError(String field) => _fieldErrors[field] != null;

  /// Updates the form data.
  @protected
  void updateFormData(T data) {
    _formData = data;
    validate();
    notifyListeners();
  }

  /// Sets a field error.
  @protected
  void setFieldError(String field, String? error) {
    _fieldErrors[field] = error;
    notifyListeners();
  }

  /// Clears all field errors.
  @protected
  void clearFieldErrors() {
    _fieldErrors.clear();
    notifyListeners();
  }

  /// Validates the form.
  void validate() {
    clearFieldErrors();
    _isValid = performValidation();
    notifyListeners();
  }

  /// Override to perform validation logic.
  @protected
  bool performValidation();

  /// Submits the form.
  Future<bool> submit() async {
    validate();
    if (!_isValid) return false;

    _isSubmitting = true;
    clearError();
    notifyListeners();

    try {
      await performSubmit();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Override to perform submission logic.
  @protected
  Future<void> performSubmit();
}

/// Mixin for ViewModels that need to track dirty state.
mixin DirtyTrackingMixin on ViewModel {
  bool _isDirty = false;
  final Set<String> _dirtyFields = {};

  /// Whether any data has been modified.
  bool get isDirty => _isDirty;

  /// The set of modified field names.
  Set<String> get dirtyFields => Set.unmodifiable(_dirtyFields);

  /// Marks the ViewModel as dirty.
  @protected
  void markDirty([String? field]) {
    _isDirty = true;
    if (field != null) _dirtyFields.add(field);
    notifyListeners();
  }

  /// Clears the dirty state.
  @protected
  void clearDirty() {
    _isDirty = false;
    _dirtyFields.clear();
    notifyListeners();
  }

  /// Checks if a specific field is dirty.
  bool isFieldDirty(String field) => _dirtyFields.contains(field);
}

/// Mixin for ViewModels with undo/redo support.
mixin UndoRedoMixin<T> on ViewModel {
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];
  int _maxHistorySize = 50;

  /// Whether undo is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether redo is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Sets the maximum history size.
  set maxHistorySize(int value) => _maxHistorySize = value;

  /// Saves the current state for undo.
  @protected
  void saveState(T state) {
    _undoStack.add(state);
    _redoStack.clear();
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// Performs undo and returns the previous state.
  T? undo(T currentState) {
    if (!canUndo) return null;
    _redoStack.add(currentState);
    return _undoStack.removeLast();
  }

  /// Performs redo and returns the next state.
  T? redo(T currentState) {
    if (!canRedo) return null;
    _undoStack.add(currentState);
    return _redoStack.removeLast();
  }

  /// Clears the history.
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

/// Mixin for ViewModels that need periodic refresh.
mixin AutoRefreshMixin on ViewModel {
  Timer? _refreshTimer;

  /// The refresh interval.
  Duration get refreshInterval => const Duration(minutes: 1);

  /// Starts auto-refresh.
  @protected
  void startAutoRefresh() {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(refreshInterval, (_) => onAutoRefresh());
  }

  /// Stops auto-refresh.
  @protected
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Override to handle auto-refresh.
  @protected
  void onAutoRefresh();

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
