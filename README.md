<h1 align="center">🔨 FlutterForge</h1>

<p align="center">
  <strong>Stop wasting hours on boilerplate. Generate production-ready Flutter projects with clean architecture in seconds.</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI"/>
  </a>
  <a href="https://github.com/muhittincamdali/FlutterForge/releases">
    <img src="https://img.shields.io/github/v/release/muhittincamdali/FlutterForge?style=flat-square&color=blue" alt="Release"/>
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter 3.24+"/>
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart 3.5+"/>
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-lightgrey?style=flat-square" alt="Platform"/>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/muhittincamdali/FlutterForge?style=flat-square&color=green" alt="License"/>
  </a>
</p>

<p align="center">
  <a href="#why-flutterforge">Why FlutterForge?</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#features">Features</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## Why FlutterForge?

Every Flutter project starts the same way — creating folders, configuring state management, setting up routing, writing DI boilerplate, adding networking layers. It takes **hours** before you write your first line of business logic.

**FlutterForge eliminates that.** One command gives you a fully structured, production-grade Flutter project with all the best practices already in place.

```bash
flutter_forge create my_app    # Full project in ~5 seconds
flutter_forge generate feature auth   # Clean architecture feature module
```

### How It Compares

| | FlutterForge | Manual Setup | Other CLIs |
|---|:---:|:---:|:---:|
| Clean Architecture out of the box | ✅ | ❌ | ⚠️ Partial |
| Riverpod 2.0 + GoRouter pre-configured | ✅ | Manual | ❌ |
| Feature/Model/Repository generators | ✅ | N/A | ⚠️ Limited |
| Dio + Retrofit networking layer | ✅ | Manual | ❌ |
| CI/CD pipeline templates | ✅ | Manual | ❌ |
| Material 3 + Dark mode theming | ✅ | Manual | ❌ |
| Comprehensive test scaffolding | ✅ | Manual | ⚠️ Basic |
| Time to first feature | **~30 sec** | **2-4 hours** | **30-60 min** |

---

## Features

| Feature | Implementation | Description |
|---------|---------------|-------------|
| 🏗️ **Architecture** | Clean Architecture + Feature-first | Scalable, testable, maintainable |
| 🔄 **State Management** | Riverpod 2.0 | Reactive, compile-safe providers |
| 🧭 **Routing** | GoRouter | Type-safe, deep link ready |
| 💉 **Dependency Injection** | Riverpod DI | No service locator needed |
| 🌐 **Networking** | Dio + Retrofit | Code-generated API clients |
| 💾 **Local Storage** | Hive + SharedPreferences | Fast key-value & structured storage |
| 🎨 **Theming** | Material 3 | Light/dark mode with custom tokens |
| 🌍 **Internationalization** | Easy Localization | Multi-language from day one |
| 🧪 **Testing** | Unit + Widget + Integration | Full test pyramid support |
| 🚀 **CI/CD** | GitHub Actions | Lint, test, build, deploy pipelines |
| 📱 **Platforms** | iOS, Android, Web, Desktop | True cross-platform |

---

## Requirements

| Requirement | Version |
|-------------|---------|
| Flutter | 3.24+ |
| Dart | 3.5+ |
| iOS | 12.0+ |
| Android | API 21+ (5.0 Lollipop) |

---

## Installation

### Global Activation (Recommended)

```bash
dart pub global activate flutter_forge
```

### As a Dev Dependency

```yaml
dev_dependencies:
  flutter_forge: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

### 1. Create a New Project

```bash
flutter_forge create my_awesome_app
cd my_awesome_app
flutter run
```

### 2. Generate a Feature Module

```bash
flutter_forge generate feature profile
```

This generates a complete clean architecture module:

```
lib/features/profile/
├── data/
│   ├── datasources/       # Remote & local data sources
│   ├── models/            # DTOs with JSON serialization
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository contracts
│   └── usecases/          # Business logic
└── presentation/
    ├── providers/         # Riverpod providers
    ├── screens/           # Page widgets
    └── widgets/           # Feature-specific widgets
```

### 3. Generate Individual Components

```bash
flutter_forge generate model User          # Freezed model + JSON
flutter_forge generate repository UserRepo # Interface + implementation
flutter_forge generate usecase GetProfile  # Use case with repository DI
flutter_forge generate screen Settings     # Screen + provider wiring
```

---

## Documentation

### Project Structure

```
lib/
├── app/
│   ├── app.dart              # App widget with MaterialApp
│   └── router.dart           # GoRouter configuration
├── core/
│   ├── network/              # Dio client, interceptors, error handling
│   ├── storage/              # Hive boxes, SharedPreferences wrapper
│   ├── theme/                # ThemeData, color schemes, typography
│   └── utils/                # Extensions, helpers, constants
├── features/
│   ├── auth/                 # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/                 # Home feature
├── shared/
│   ├── widgets/              # Cross-feature reusable widgets
│   └── extensions/           # Dart extensions
└── main.dart                 # Entry point with ProviderScope
```

### State Management

Riverpod 2.0 with code generation:

```dart
// Define a provider
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getCurrentUser();
});

// Consume in a widget
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) => UserProfile(user: user),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorWidget(message: e.toString()),
    );
  }
}
```

### Networking

Type-safe API client powered by Retrofit:

```dart
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;
  
  @GET('/users/{id}')
  Future<UserDto> getUser(@Path() String id);
  
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);
  
  @PUT('/users/{id}')
  Future<UserDto> updateUser(
    @Path() String id,
    @Body() UpdateUserRequest request,
  );
}
```

### Theming

Material 3 with automatic light/dark switching:

```dart
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

MaterialApp(
  themeMode: ref.watch(themeProvider),
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
)
```

### Testing

```bash
flutter test                        # All tests
flutter test --coverage             # With coverage report
flutter test integration_test/      # Integration tests
```

Example test:

```dart
void main() {
  group('UserRepository', () {
    late MockApiClient mockApiClient;
    late UserRepository repository;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = UserRepositoryImpl(mockApiClient);
    });

    test('getUser returns user from API', () async {
      when(mockApiClient.getUser('1'))
          .thenAnswer((_) async => UserDto(id: '1', name: 'John'));

      final user = await repository.getUser('1');

      expect(user.name, 'John');
    });
  });
}
```

---

## CLI Commands

| Command | Description |
|---------|-------------|
| `create <name>` | Scaffold a new Flutter project |
| `generate feature <name>` | Generate a clean architecture feature module |
| `generate model <name>` | Generate a Freezed model with JSON serialization |
| `generate repository <name>` | Generate a repository (interface + impl) |
| `generate usecase <name>` | Generate a use case class |
| `generate screen <name>` | Generate a screen with provider |
| `generate widget <name>` | Generate a reusable widget |

---

## CI/CD

Pre-configured GitHub Actions workflows:

| Workflow | Trigger | What It Does |
|----------|---------|--------------|
| **Lint** | Every PR | Runs `flutter analyze` |
| **Test** | Every PR | Runs full test suite with coverage |
| **Build** | Push to `main` | Builds release artifacts |
| **Deploy** | Tag `v*` | Optional store deployment |

---

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See the [open issues](https://github.com/muhittincamdali/FlutterForge/issues) for a list of proposed features and known issues.

---

## License

FlutterForge is released under the MIT License. See [LICENSE](LICENSE) for details.

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/FlutterForge&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/FlutterForge&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/FlutterForge&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/FlutterForge&type=Date" />
 </picture>
</a>

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/muhittincamdali">Muhittin Camdali</a>
</p>
