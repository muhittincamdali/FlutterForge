/// Template engine for generating project files.
///
/// This class handles the generation of all template files for a new
/// FlutterForge project, including core files, architecture components,
/// and configuration.
library;

/// Architecture patterns supported by FlutterForge.
enum ArchitecturePattern {
  /// Clean Architecture with domain/data/presentation layers
  clean,

  /// Model-View-ViewModel pattern
  mvvm,

  /// Feature-first organization
  feature,
}

/// State management solutions supported by FlutterForge.
enum StateManagement {
  /// Riverpod state management
  riverpod,

  /// BLoC pattern
  bloc,

  /// Provider package
  provider,
}

/// Main template engine for generating project files.
class TemplateEngine {
  /// Creates a new [TemplateEngine] instance.
  TemplateEngine({
    required this.projectName,
    required this.orgIdentifier,
    this.architecture = ArchitecturePattern.clean,
    this.stateManagement = StateManagement.riverpod,
  });

  /// The name of the project being generated.
  final String projectName;

  /// The organization identifier (e.g., com.example).
  final String orgIdentifier;

  /// The architecture pattern to use.
  final ArchitecturePattern architecture;

  /// The state management solution to use.
  final StateManagement stateManagement;

  /// Converts project name to PascalCase.
  String get projectNamePascal => _toPascalCase(projectName);

  /// Gets the package name.
  String get packageName => '$orgIdentifier.$projectName';

  /// Generates the main.dart file content.
  String generateMain() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/di/injection_container.dart';

/// Application entry point.
///
/// Initializes the application with proper configuration,
/// dependency injection, and error handling.
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependencies
  await initializeDependencies();

  // Configure error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _logError(details.exception, details.stack);
  };

  // Run the application
  runApp(
    const ProviderScope(
      child: ${projectNamePascal}App(),
    ),
  );
}

/// Logs errors for debugging and crash reporting.
void _logError(Object error, StackTrace? stackTrace) {
  // TODO: Implement crash reporting (e.g., Firebase Crashlytics)
  debugPrint('Error: \$error');
  if (stackTrace != null) {
    debugPrint('Stack trace: \$stackTrace');
  }
}
''';
  }

  /// Generates the app.dart file content.
  String generateApp() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';

/// Main application widget.
///
/// Configures the application with routing, theming, and localization.
class ${projectNamePascal}App extends ConsumerWidget {
  /// Creates a new [${projectNamePascal}App] instance.
  const ${projectNamePascal}App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: '$projectNamePascal',
      debugShowCheckedModeBanner: false,
      
      // Routing configuration
      routerConfig: router,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Builder for global overlays
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
''';
  }

  /// Generates the pubspec.yaml content.
  String generatePubspec() {
    return '''
name: $projectName
description: A new Flutter project created with FlutterForge.
version: 1.0.0+1
publish_to: 'none'

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Routing
  go_router: ^13.0.0

  # Networking
  dio: ^5.4.0
  connectivity_plus: ^5.0.2

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # UI Components
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.5
  uuid: ^4.2.2
  path_provider: ^2.1.2
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  mockito: ^5.4.4
  mocktail: ^1.0.3
  very_good_analysis: ^5.1.0

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
''';
  }

  /// Generates the analysis_options.yaml content.
  String generateAnalysisOptions() {
    return '''
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - 'lib/generated/**'
    - 'build/**'
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    flutter_style_todos: true
    avoid_dynamic_calls: true
    avoid_type_to_string: true
    cancel_subscriptions: true
    close_sinks: true
    literal_only_boolean_expressions: true
    no_adjacent_strings_in_list: true
    prefer_relative_imports: true
    test_types_in_equals: true
    throw_in_finally: true
    unnecessary_statements: true
    unsafe_html: true
''';
  }

  /// Generates architecture-specific files based on the selected pattern.
  Map<String, String> generateArchitectureFiles() {
    switch (architecture) {
      case ArchitecturePattern.clean:
        return _generateCleanArchitectureFiles();
      case ArchitecturePattern.mvvm:
        return _generateMVVMFiles();
      case ArchitecturePattern.feature:
        return _generateFeatureBasedFiles();
    }
  }

  /// Generates Clean Architecture files.
  Map<String, String> _generateCleanArchitectureFiles() {
    return {
      'lib/src/core/usecases/usecase.dart': _generateUseCaseBase(),
      'lib/src/core/errors/failures.dart': _generateFailures(),
      'lib/src/core/errors/exceptions.dart': _generateExceptions(),
    };
  }

  /// Generates MVVM files.
  Map<String, String> _generateMVVMFiles() {
    return {
      'lib/src/core/base/base_view_model.dart': _generateBaseViewModel(),
      'lib/src/core/base/base_view.dart': _generateBaseView(),
    };
  }

  /// Generates feature-based files.
  Map<String, String> _generateFeatureBasedFiles() {
    return {
      'lib/src/core/base/base_feature.dart': _generateBaseFeature(),
    };
  }

  /// Generates feature files.
  Map<String, String> generateFeature(String featureName) {
    final featureNamePascal = _toPascalCase(featureName);

    return {
      'lib/src/features/$featureName/domain/entities/${featureName}_entity.dart':
          _generateEntity(featureNamePascal),
      'lib/src/features/$featureName/domain/repositories/${featureName}_repository.dart':
          _generateRepositoryInterface(featureNamePascal),
      'lib/src/features/$featureName/data/repositories/${featureName}_repository_impl.dart':
          _generateRepositoryImpl(featureNamePascal),
      'lib/src/features/$featureName/data/datasources/${featureName}_remote_datasource.dart':
          _generateRemoteDataSource(featureNamePascal),
      'lib/src/features/$featureName/presentation/providers/${featureName}_provider.dart':
          _generateProvider(featureNamePascal, featureName),
      'lib/src/features/$featureName/presentation/pages/${featureName}_page.dart':
          _generatePage(featureNamePascal),
    };
  }

  /// Generates test files.
  Map<String, String> generateTests() {
    return {
      'test/helpers/test_helpers.dart': _generateTestHelpers(),
      'test/helpers/mocks.dart': _generateMocks(),
      'test/widget_test.dart': _generateWidgetTest(),
    };
  }

  /// Generates CI/CD configuration files.
  Map<String, String> generateCICD() {
    return {
      '.github/workflows/ci.yml': _generateCIWorkflow(),
      '.github/workflows/release.yml': _generateReleaseWorkflow(),
    };
  }

  // Private generation methods

  String _generateUseCaseBase() {
    return '''
import 'package:equatable/equatable.dart';

/// Base class for all use cases.
///
/// Type Parameters:
/// - [Type]: The return type of the use case
/// - [Params]: The parameters required by the use case
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  Future<Type> call(Params params);
}

/// Use case that doesn't require parameters.
abstract class UseCaseNoParams<Type> {
  /// Executes the use case without parameters.
  Future<Type> call();
}

/// Empty parameters for use cases that don't need input.
class NoParams extends Equatable {
  /// Creates a new [NoParams] instance.
  const NoParams();

  @override
  List<Object?> get props => [];
}
''';
  }

  String _generateFailures() {
    return '''
import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
sealed class Failure extends Equatable {
  /// Creates a new [Failure] with the given [message].
  const Failure(this.message);

  /// The error message describing the failure.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure for server-related errors.
class ServerFailure extends Failure {
  /// Creates a new [ServerFailure].
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure for cache-related errors.
class CacheFailure extends Failure {
  /// Creates a new [CacheFailure].
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Failure for network-related errors.
class NetworkFailure extends Failure {
  /// Creates a new [NetworkFailure].
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Failure for authentication-related errors.
class AuthFailure extends Failure {
  /// Creates a new [AuthFailure].
  const AuthFailure([super.message = 'Authentication error occurred']);
}

/// Failure for validation-related errors.
class ValidationFailure extends Failure {
  /// Creates a new [ValidationFailure].
  const ValidationFailure([super.message = 'Validation error occurred']);
}
''';
  }

  String _generateExceptions() {
    return '''
/// Base class for all exceptions in the application.
sealed class AppException implements Exception {
  /// Creates a new [AppException] with the given [message].
  const AppException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => message;
}

/// Exception for server-related errors.
class ServerException extends AppException {
  /// Creates a new [ServerException].
  const ServerException([super.message = 'Server error']);
}

/// Exception for cache-related errors.
class CacheException extends AppException {
  /// Creates a new [CacheException].
  const CacheException([super.message = 'Cache error']);
}

/// Exception for network-related errors.
class NetworkException extends AppException {
  /// Creates a new [NetworkException].
  const NetworkException([super.message = 'Network error']);
}

/// Exception for authentication-related errors.
class AuthException extends AppException {
  /// Creates a new [AuthException].
  const AuthException([super.message = 'Authentication error']);
}
''';
  }

  String _generateBaseViewModel() {
    return '''
import 'package:flutter/foundation.dart';

/// Base class for all ViewModels in MVVM architecture.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  /// Whether the ViewModel is currently loading.
  bool get isLoading => _isLoading;

  /// The current error message, if any.
  String? get error => _error;

  /// Sets the loading state.
  @protected
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets the error message.
  @protected
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clears the error message.
  void clearError() => setError(null);
}
''';
  }

  String _generateBaseView() {
    return '''
import 'package:flutter/material.dart';

/// Base widget for views in MVVM architecture.
abstract class BaseView<T extends ChangeNotifier> extends StatelessWidget {
  /// Creates a new [BaseView].
  const BaseView({super.key});

  /// Builds the view with the given [viewModel].
  Widget buildView(BuildContext context, T viewModel);
}
''';
  }

  String _generateBaseFeature() {
    return '''
/// Base class for feature modules.
abstract class BaseFeature {
  /// The name of the feature.
  String get name;

  /// Initializes the feature.
  Future<void> initialize();

  /// Disposes of feature resources.
  Future<void> dispose();
}
''';
  }

  String _generateEntity(String name) {
    return '''
import 'package:equatable/equatable.dart';

/// Entity representing a $name.
class ${name}Entity extends Equatable {
  /// Creates a new [${name}Entity].
  const ${name}Entity({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  /// The unique identifier.
  final String id;

  /// The name.
  final String name;

  /// When the entity was created.
  final DateTime? createdAt;

  /// When the entity was last updated.
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
''';
  }

  String _generateRepositoryInterface(String name) {
    return '''
import '../entities/${_toSnakeCase(name)}_entity.dart';

/// Repository interface for $name operations.
abstract class ${name}Repository {
  /// Gets all items.
  Future<List<${name}Entity>> getAll();

  /// Gets an item by [id].
  Future<${name}Entity?> getById(String id);

  /// Creates a new item.
  Future<${name}Entity> create(${name}Entity entity);

  /// Updates an existing item.
  Future<${name}Entity> update(${name}Entity entity);

  /// Deletes an item by [id].
  Future<void> delete(String id);
}
''';
  }

  String _generateRepositoryImpl(String name) {
    return '''
import '../../domain/entities/${_toSnakeCase(name)}_entity.dart';
import '../../domain/repositories/${_toSnakeCase(name)}_repository.dart';
import '../datasources/${_toSnakeCase(name)}_remote_datasource.dart';

/// Implementation of [${name}Repository].
class ${name}RepositoryImpl implements ${name}Repository {
  /// Creates a new [${name}RepositoryImpl].
  const ${name}RepositoryImpl(this._remoteDataSource);

  final ${name}RemoteDataSource _remoteDataSource;

  @override
  Future<List<${name}Entity>> getAll() => _remoteDataSource.getAll();

  @override
  Future<${name}Entity?> getById(String id) => _remoteDataSource.getById(id);

  @override
  Future<${name}Entity> create(${name}Entity entity) => 
      _remoteDataSource.create(entity);

  @override
  Future<${name}Entity> update(${name}Entity entity) => 
      _remoteDataSource.update(entity);

  @override
  Future<void> delete(String id) => _remoteDataSource.delete(id);
}
''';
  }

  String _generateRemoteDataSource(String name) {
    return '''
import '../../domain/entities/${_toSnakeCase(name)}_entity.dart';

/// Remote data source for $name operations.
abstract class ${name}RemoteDataSource {
  /// Gets all items from the remote server.
  Future<List<${name}Entity>> getAll();

  /// Gets an item by [id] from the remote server.
  Future<${name}Entity?> getById(String id);

  /// Creates a new item on the remote server.
  Future<${name}Entity> create(${name}Entity entity);

  /// Updates an existing item on the remote server.
  Future<${name}Entity> update(${name}Entity entity);

  /// Deletes an item by [id] from the remote server.
  Future<void> delete(String id);
}
''';
  }

  String _generateProvider(String name, String featureName) {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/${featureName}_entity.dart';

/// State for $name.
class ${name}State {
  /// Creates a new [${name}State].
  const ${name}State({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  /// The list of items.
  final List<${name}Entity> items;

  /// Whether data is being loaded.
  final bool isLoading;

  /// The current error, if any.
  final String? error;

  /// Creates a copy with the given fields replaced.
  ${name}State copyWith({
    List<${name}Entity>? items,
    bool? isLoading,
    String? error,
  }) {
    return ${name}State(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for $name state.
final ${featureName}Provider =
    StateNotifierProvider<${name}Notifier, ${name}State>((ref) {
  return ${name}Notifier();
});

/// Notifier for $name state.
class ${name}Notifier extends StateNotifier<${name}State> {
  /// Creates a new [${name}Notifier].
  ${name}Notifier() : super(const ${name}State());

  /// Loads all items.
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement data loading
      state = state.copyWith(items: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
''';
  }

  String _generatePage(String name) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page widget for $name.
class ${name}Page extends ConsumerWidget {
  /// Creates a new [${name}Page].
  const ${name}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$name'),
      ),
      body: const Center(
        child: Text('$name Page'),
      ),
    );
  }
}
''';
  }

  String _generateTestHelpers() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget with necessary providers for testing.
Widget createTestWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Pumps a widget and waits for animations.
extension WidgetTesterExtension on WidgetTester {
  /// Pumps the widget and settles animations.
  Future<void> pumpAndSettle2() async {
    await pumpAndSettle(const Duration(milliseconds: 100));
  }
}
''';
  }

  String _generateMocks() {
    return '''
import 'package:mocktail/mocktail.dart';

// Add mock classes here as needed
// Example:
// class MockUserRepository extends Mock implements UserRepository {}
''';
  }

  String _generateWidgetTest() {
    return '''
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App renders correctly', (tester) async {
      // TODO: Add widget tests
    });
  });
}
''';
  }

  String _generateCIWorkflow() {
    return '''
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test --coverage
''';
  }

  String _generateReleaseWorkflow() {
    return '''
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: build/app/outputs/bundle/release/

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
''';
  }

  /// Converts a string to PascalCase.
  String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();
  }

  /// Converts a string to snake_case.
  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }
}
