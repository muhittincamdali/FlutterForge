/// Riverpod provider utilities and patterns.
///
/// Provides helper classes and utilities for building
/// scalable Riverpod-based state management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for dependency injection container.
final dependencyContainerProvider = Provider<DependencyContainer>((ref) {
  return DependencyContainer();
});

/// Simple dependency container for providers.
class DependencyContainer {
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _factories = {};

  /// Registers a singleton.
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Registers a factory.
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Gets an instance of [T].
  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw ArgumentError('No registration found for type $T');
  }

  /// Checks if type is registered.
  bool isRegistered<T>() {
    return _singletons.containsKey(T) || _factories.containsKey(T);
  }
}

/// Extension for easy provider access.
extension ProviderContainerExtension on ProviderContainer {
  /// Gets a dependency from the container.
  T getDependency<T>() {
    return read(dependencyContainerProvider).get<T>();
  }
}

/// Base class for async data providers.
class AsyncDataProvider<T> {
  /// Creates a new [AsyncDataProvider].
  AsyncDataProvider(this._fetch);

  final Future<T> Function() _fetch;

  /// Creates the provider.
  FutureProvider<T> toProvider() {
    return FutureProvider<T>((ref) => _fetch());
  }

  /// Creates an auto-dispose provider.
  AutoDisposeFutureProvider<T> toAutoDisposeProvider() {
    return FutureProvider.autoDispose<T>((ref) => _fetch());
  }

  /// Creates a family provider.
  FutureProviderFamily<T, P> toFamilyProvider<P>(
    Future<T> Function(P) fetcher,
  ) {
    return FutureProvider.family<T, P>((ref, param) => fetcher(param));
  }
}

/// State class for paginated data.
class PaginatedData<T> {
  /// Creates a new [PaginatedData].
  const PaginatedData({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  /// The loaded items.
  final List<T> items;

  /// Current page.
  final int page;

  /// Whether more items are available.
  final bool hasMore;

  /// Whether currently loading.
  final bool isLoading;

  /// Error if any.
  final Object? error;

  /// Creates a copy with updated fields.
  PaginatedData<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    Object? error,
  }) {
    return PaginatedData(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Appends new items.
  PaginatedData<T> appendItems(List<T> newItems, {bool hasMore = true}) {
    return copyWith(
      items: [...items, ...newItems],
      page: page + 1,
      hasMore: hasMore,
      isLoading: false,
    );
  }
}

/// Helper for creating CRUD providers.
class CrudProviders<T, ID> {
  /// Creates new [CrudProviders].
  CrudProviders({
    required this.getAll,
    required this.getById,
    required this.create,
    required this.update,
    required this.delete,
  });

  /// Provider for getting all items.
  final FutureProvider<List<T>> getAll;

  /// Provider family for getting by ID.
  final FutureProviderFamily<T?, ID> getById;

  /// Notifier for creating items.
  final StateNotifierProvider<CreateNotifier<T>, AsyncValue<T?>> create;

  /// Notifier for updating items.
  final StateNotifierProvider<UpdateNotifier<T>, AsyncValue<T?>> update;

  /// Notifier for deleting items.
  final StateNotifierProvider<DeleteNotifier<ID>, AsyncValue<bool>> delete;
}

/// Notifier for create operations.
class CreateNotifier<T> extends StateNotifier<AsyncValue<T?>> {
  /// Creates a new [CreateNotifier].
  CreateNotifier(this._createFn) : super(const AsyncValue.data(null));

  final Future<T> Function(T) _createFn;

  /// Creates an item.
  Future<void> create(T item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _createFn(item));
  }

  /// Resets the state.
  void reset() => state = const AsyncValue.data(null);
}

/// Notifier for update operations.
class UpdateNotifier<T> extends StateNotifier<AsyncValue<T?>> {
  /// Creates a new [UpdateNotifier].
  UpdateNotifier(this._updateFn) : super(const AsyncValue.data(null));

  final Future<T> Function(T) _updateFn;

  /// Updates an item.
  Future<void> update(T item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _updateFn(item));
  }

  /// Resets the state.
  void reset() => state = const AsyncValue.data(null);
}

/// Notifier for delete operations.
class DeleteNotifier<ID> extends StateNotifier<AsyncValue<bool>> {
  /// Creates a new [DeleteNotifier].
  DeleteNotifier(this._deleteFn) : super(const AsyncValue.data(false));

  final Future<void> Function(ID) _deleteFn;

  /// Deletes an item.
  Future<void> delete(ID id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _deleteFn(id);
      return true;
    });
  }

  /// Resets the state.
  void reset() => state = const AsyncValue.data(false);
}

/// Helper for creating form providers.
class FormProviders<T> {
  /// Creates new [FormProviders].
  FormProviders({
    required this.data,
    required this.validation,
    required this.submission,
  });

  /// Provider for form data.
  final StateProvider<T> data;

  /// Provider for validation errors.
  final StateProvider<Map<String, String>> validation;

  /// Provider for submission state.
  final StateNotifierProvider<FormSubmissionNotifier<T>, AsyncValue<bool>>
      submission;
}

/// Notifier for form submission.
class FormSubmissionNotifier<T> extends StateNotifier<AsyncValue<bool>> {
  /// Creates a new [FormSubmissionNotifier].
  FormSubmissionNotifier(this._submitFn) : super(const AsyncValue.data(false));

  final Future<void> Function(T) _submitFn;

  /// Submits the form.
  Future<void> submit(T data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _submitFn(data);
      return true;
    });
  }

  /// Resets the state.
  void reset() => state = const AsyncValue.data(false);
}

/// Extension for AsyncValue.
extension AsyncValueExtension<T> on AsyncValue<T> {
  /// Maps the data to a widget.
  R when2<R>({
    required R Function(T data) data,
    required R Function() loading,
    required R Function(Object error, StackTrace stack) error,
    R Function(T? data)? skipLoadingOnRefresh,
  }) {
    return when(
      data: data,
      loading: () {
        if (skipLoadingOnRefresh != null && hasValue) {
          return skipLoadingOnRefresh(valueOrNull);
        }
        return loading();
      },
      error: error,
    );
  }
}

/// Provider for app-wide settings.
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

/// App settings state.
class AppSettings {
  /// Creates new [AppSettings].
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.isFirstLaunch = true,
  });

  /// Theme mode.
  final ThemeMode themeMode;

  /// App locale.
  final String? locale;

  /// Whether this is first launch.
  final bool isFirstLaunch;

  /// Creates a copy.
  AppSettings copyWith({
    ThemeMode? themeMode,
    String? locale,
    bool? isFirstLaunch,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

/// Theme mode enum.
enum ThemeMode { light, dark, system }

/// Notifier for app settings.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  /// Creates a new [AppSettingsNotifier].
  AppSettingsNotifier() : super(const AppSettings());

  /// Sets the theme mode.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  /// Sets the locale.
  void setLocale(String? locale) {
    state = state.copyWith(locale: locale);
  }

  /// Marks first launch as complete.
  void completeFirstLaunch() {
    state = state.copyWith(isFirstLaunch: false);
  }
}

/// Provider for connectivity status.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  // This is a placeholder - implement with connectivity_plus
  yield true;
});

/// Provider for authentication state.
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

/// Authentication state.
sealed class AuthState {
  const AuthState();
}

/// Unauthenticated state.
class Unauthenticated extends AuthState {
  /// Creates an [Unauthenticated] state.
  const Unauthenticated();
}

/// Authenticated state.
class Authenticated extends AuthState {
  /// Creates an [Authenticated] state.
  const Authenticated(this.userId);

  /// The user ID.
  final String userId;
}

/// Loading authentication state.
class AuthLoading extends AuthState {
  /// Creates an [AuthLoading] state.
  const AuthLoading();
}

/// Notifier for auth state.
class AuthStateNotifier extends StateNotifier<AuthState> {
  /// Creates a new [AuthStateNotifier].
  AuthStateNotifier() : super(const Unauthenticated());

  /// Signs in.
  Future<void> signIn(String userId) async {
    state = const AuthLoading();
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    state = Authenticated(userId);
  }

  /// Signs out.
  void signOut() {
    state = const Unauthenticated();
  }
}
