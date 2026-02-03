/// Service locator pattern implementation.
///
/// Provides an alternative to dependency injection for
/// accessing services throughout the application.
library;

import 'injection_container.dart';

/// Simple service locator for accessing dependencies.
class ServiceLocator {
  ServiceLocator._();

  static final _instance = ServiceLocator._();

  /// Gets the service locator instance.
  static ServiceLocator get instance => _instance;

  final InjectionContainer _container = InjectionContainer();

  /// Registers a service.
  void register<T>(T service) {
    _container.registerSingleton<T>(service);
  }

  /// Registers a lazy service.
  void registerLazy<T>(T Function() factory) {
    _container.registerLazySingleton<T>(factory);
  }

  /// Registers a factory.
  void registerFactory<T>(T Function() factory) {
    _container.registerFactory<T>(factory);
  }

  /// Gets a service.
  T get<T>() => _container.get<T>();

  /// Tries to get a service, returns null if not found.
  T? tryGet<T>() {
    try {
      return _container.get<T>();
    } catch (_) {
      return null;
    }
  }

  /// Checks if a service is registered.
  bool has<T>() => _container.isRegistered<T>();

  /// Unregisters a service.
  void unregister<T>() => _container.unregister<T>();

  /// Resets the locator.
  void reset() => _container.reset();
}

/// Global service locator instance.
final locator = ServiceLocator.instance;

/// Service interface for defining service contracts.
abstract class Service {
  /// Initializes the service.
  Future<void> initialize();

  /// Disposes the service.
  Future<void> dispose();
}

/// Lifecycle-aware service mixin.
mixin ServiceLifecycle on Service {
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// Whether the service is initialized.
  bool get isInitialized => _isInitialized;

  /// Whether the service is disposed.
  bool get isDisposed => _isDisposed;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await onInitialize();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    await onDispose();
    _isDisposed = true;
  }

  /// Override to perform initialization.
  Future<void> onInitialize();

  /// Override to perform cleanup.
  Future<void> onDispose();
}

/// Service registry for managing service lifecycle.
class ServiceRegistry {
  final Map<Type, Service> _services = {};

  /// Registers a service.
  void register<T extends Service>(T service) {
    _services[T] = service;
  }

  /// Gets a service.
  T? get<T extends Service>() {
    return _services[T] as T?;
  }

  /// Initializes all services.
  Future<void> initializeAll() async {
    for (final service in _services.values) {
      await service.initialize();
    }
  }

  /// Disposes all services.
  Future<void> disposeAll() async {
    for (final service in _services.values) {
      await service.dispose();
    }
    _services.clear();
  }
}

/// Scoped service locator for limited lifetimes.
class ScopedLocator {
  /// Creates a new [ScopedLocator].
  ScopedLocator({this.parent});

  /// Parent locator for hierarchical lookup.
  final ScopedLocator? parent;

  final Map<Type, dynamic> _services = {};

  /// Registers a scoped service.
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Gets a service, checking parent if not found.
  T get<T>() {
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }
    if (parent != null) {
      return parent!.get<T>();
    }
    throw Exception('Service not found: $T');
  }

  /// Tries to get a service.
  T? tryGet<T>() {
    try {
      return get<T>();
    } catch (_) {
      return null;
    }
  }

  /// Creates a child scope.
  ScopedLocator createScope() {
    return ScopedLocator(parent: this);
  }

  /// Disposes this scope.
  void dispose() {
    _services.clear();
  }
}

/// Factory interface for creating instances.
abstract class ServiceFactory<T> {
  /// Creates an instance.
  T create();
}

/// Singleton factory that creates only one instance.
class SingletonFactory<T> implements ServiceFactory<T> {
  /// Creates a new [SingletonFactory].
  SingletonFactory(this._factory);

  final T Function() _factory;
  T? _instance;

  @override
  T create() {
    return _instance ??= _factory();
  }

  /// Resets the singleton.
  void reset() {
    _instance = null;
  }
}

/// Transient factory that creates a new instance each time.
class TransientFactory<T> implements ServiceFactory<T> {
  /// Creates a new [TransientFactory].
  TransientFactory(this._factory);

  final T Function() _factory;

  @override
  T create() => _factory();
}

/// Service builder for fluent registration.
class ServiceBuilder<T> {
  /// Creates a new [ServiceBuilder].
  ServiceBuilder(this._locator);

  final ServiceLocator _locator;
  T Function()? _factory;
  bool _singleton = true;

  /// Sets the factory function.
  ServiceBuilder<T> withFactory(T Function() factory) {
    _factory = factory;
    return this;
  }

  /// Makes this service a singleton.
  ServiceBuilder<T> asSingleton() {
    _singleton = true;
    return this;
  }

  /// Makes this service transient.
  ServiceBuilder<T> asTransient() {
    _singleton = false;
    return this;
  }

  /// Registers the service.
  void register() {
    if (_factory == null) {
      throw Exception('Factory must be provided');
    }

    if (_singleton) {
      _locator.registerLazy<T>(_factory!);
    } else {
      _locator.registerFactory<T>(_factory!);
    }
  }
}

/// Extension for fluent service registration.
extension ServiceLocatorExtension on ServiceLocator {
  /// Creates a builder for type [T].
  ServiceBuilder<T> builder<T>() {
    return ServiceBuilder<T>(this);
  }
}
