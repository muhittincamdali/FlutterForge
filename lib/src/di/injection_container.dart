/// Dependency injection container and service registration.
///
/// Provides a simple yet powerful dependency injection solution
/// with support for singletons, factories, and lazy initialization.
library;

import 'dart:async';

/// Type alias for factory functions.
typedef Factory<T> = T Function();

/// Type alias for async factory functions.
typedef AsyncFactory<T> = Future<T> Function();

/// Type alias for parameterized factory functions.
typedef FactoryWithParam<T, P> = T Function(P param);

/// Dependency injection container.
class InjectionContainer {
  /// Creates a new [InjectionContainer].
  InjectionContainer();

  /// The global instance.
  static final InjectionContainer instance = InjectionContainer();

  final Map<Type, _Registration> _registrations = {};
  final Map<Type, dynamic> _singletonInstances = {};
  final Map<Type, Future<dynamic>> _asyncSingletons = {};

  /// Registers a singleton instance.
  void registerSingleton<T>(T instance) {
    _singletonInstances[T] = instance;
    _registrations[T] = _Registration(
      type: _RegistrationType.singleton,
      factory: () => instance,
    );
  }

  /// Registers a lazy singleton.
  void registerLazySingleton<T>(Factory<T> factory) {
    _registrations[T] = _Registration(
      type: _RegistrationType.lazySingleton,
      factory: factory,
    );
  }

  /// Registers a factory.
  void registerFactory<T>(Factory<T> factory) {
    _registrations[T] = _Registration(
      type: _RegistrationType.factory,
      factory: factory,
    );
  }

  /// Registers an async singleton.
  void registerSingletonAsync<T>(AsyncFactory<T> factory) {
    _registrations[T] = _Registration(
      type: _RegistrationType.asyncSingleton,
      asyncFactory: factory,
    );
  }

  /// Registers a parameterized factory.
  void registerFactoryParam<T, P>(FactoryWithParam<T, P> factory) {
    _registrations[T] = _Registration(
      type: _RegistrationType.factoryWithParam,
      factoryWithParam: factory,
    );
  }

  /// Gets an instance of type [T].
  T get<T>() {
    // Check for pre-resolved singleton
    if (_singletonInstances.containsKey(T)) {
      return _singletonInstances[T] as T;
    }

    final registration = _registrations[T];
    if (registration == null) {
      throw InjectionException('No registration found for type $T');
    }

    switch (registration.type) {
      case _RegistrationType.singleton:
        return registration.factory!() as T;

      case _RegistrationType.lazySingleton:
        final instance = registration.factory!() as T;
        _singletonInstances[T] = instance;
        return instance;

      case _RegistrationType.factory:
        return registration.factory!() as T;

      case _RegistrationType.asyncSingleton:
        throw InjectionException(
          'Use getAsync() for async singletons: $T',
        );

      case _RegistrationType.factoryWithParam:
        throw InjectionException(
          'Use getWithParam() for parameterized factories: $T',
        );
    }
  }

  /// Gets an instance of type [T] asynchronously.
  Future<T> getAsync<T>() async {
    // Check for pre-resolved singleton
    if (_singletonInstances.containsKey(T)) {
      return _singletonInstances[T] as T;
    }

    // Check for in-progress async singleton
    if (_asyncSingletons.containsKey(T)) {
      return await _asyncSingletons[T] as T;
    }

    final registration = _registrations[T];
    if (registration == null) {
      throw InjectionException('No registration found for type $T');
    }

    if (registration.type == _RegistrationType.asyncSingleton) {
      final future = registration.asyncFactory!();
      _asyncSingletons[T] = future;

      final instance = await future;
      _singletonInstances[T] = instance;
      _asyncSingletons.remove(T);

      return instance as T;
    }

    return get<T>();
  }

  /// Gets an instance with a parameter.
  T getWithParam<T, P>(P param) {
    final registration = _registrations[T];
    if (registration == null) {
      throw InjectionException('No registration found for type $T');
    }

    if (registration.type != _RegistrationType.factoryWithParam) {
      throw InjectionException('$T is not registered with parameters');
    }

    return registration.factoryWithParam!(param) as T;
  }

  /// Checks if a type is registered.
  bool isRegistered<T>() => _registrations.containsKey(T);

  /// Unregisters a type.
  void unregister<T>() {
    _registrations.remove(T);
    _singletonInstances.remove(T);
    _asyncSingletons.remove(T);
  }

  /// Resets the container.
  void reset() {
    _registrations.clear();
    _singletonInstances.clear();
    _asyncSingletons.clear();
  }

  /// Initializes all async singletons.
  Future<void> allReady() async {
    final asyncTypes = _registrations.entries
        .where((e) => e.value.type == _RegistrationType.asyncSingleton)
        .map((e) => e.key);

    for (final type in asyncTypes) {
      await getAsync<dynamic>();
    }
  }
}

enum _RegistrationType {
  singleton,
  lazySingleton,
  factory,
  asyncSingleton,
  factoryWithParam,
}

class _Registration {
  const _Registration({
    required this.type,
    this.factory,
    this.asyncFactory,
    this.factoryWithParam,
  });

  final _RegistrationType type;
  final Factory<dynamic>? factory;
  final AsyncFactory<dynamic>? asyncFactory;
  final Function? factoryWithParam;
}

/// Exception thrown by the injection container.
class InjectionException implements Exception {
  /// Creates a new [InjectionException].
  const InjectionException(this.message);

  /// Error message.
  final String message;

  @override
  String toString() => 'InjectionException: $message';
}

/// Global injection container instance.
final getIt = InjectionContainer.instance;

/// Initializes all dependencies.
Future<void> initializeDependencies() async {
  // Register core services
  _registerCoreServices();

  // Register data sources
  _registerDataSources();

  // Register repositories
  _registerRepositories();

  // Register use cases
  _registerUseCases();

  // Wait for all async registrations
  await getIt.allReady();
}

void _registerCoreServices() {
  // Example registrations
  // getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl());
  // getIt.registerLazySingleton<LocalStorage>(() => LocalStorageImpl());
  // getIt.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());
}

void _registerDataSources() {
  // Example registrations
  // getIt.registerLazySingleton<UserRemoteDataSource>(
  //   () => UserRemoteDataSourceImpl(getIt<ApiClient>()),
  // );
}

void _registerRepositories() {
  // Example registrations
  // getIt.registerLazySingleton<UserRepository>(
  //   () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
  // );
}

void _registerUseCases() {
  // Example registrations
  // getIt.registerFactory<GetUserUseCase>(
  //   () => GetUserUseCase(getIt<UserRepository>()),
  // );
}

/// Module interface for organizing registrations.
abstract class InjectionModule {
  /// Registers dependencies for this module.
  void register(InjectionContainer container);
}

/// Core module with essential services.
class CoreModule implements InjectionModule {
  @override
  void register(InjectionContainer container) {
    // Register core services here
  }
}

/// Feature module base class.
abstract class FeatureModule implements InjectionModule {
  /// Feature name.
  String get featureName;

  /// Dependencies this feature requires.
  List<Type> get dependencies => [];
}

/// Module loader for organizing dependency registration.
class ModuleLoader {
  /// Creates a new [ModuleLoader].
  ModuleLoader(this.container);

  /// The injection container.
  final InjectionContainer container;

  /// Loads a module.
  void load(InjectionModule module) {
    module.register(container);
  }

  /// Loads multiple modules.
  void loadAll(List<InjectionModule> modules) {
    for (final module in modules) {
      load(module);
    }
  }
}
