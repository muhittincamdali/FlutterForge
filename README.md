<h1 align="center">FlutterForge</h1>

<p align="center">
  <strong>🔨 Production-ready Flutter project template with CLI, Riverpod & clean architecture</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI"/>
  </a>
  <a href="https://pub.dev/packages/flutter_forge">
    <img src="https://img.shields.io/badge/pub.dev-flutter__forge-blue?style=flat-square&logo=dart" alt="pub.dev"/>
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.24-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter 3.24"/>
  <img src="https://img.shields.io/badge/Dart-3.5-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart 3.5"/>
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey?style=flat-square" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 📋 Table of Contents

- [Why FlutterForge?](#why-flutterforge)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
  - [Project Structure](#project-structure)
  - [Code Generation](#code-generation)
  - [State Management](#state-management)
  - [Networking](#networking)
  - [Theming](#theming)
  - [Testing](#testing)
- [CLI Commands](#cli-commands)
- [CI/CD](#cicd)
- [Contributing](#contributing)
- [License](#license)
- [Star History](#-star-history)

---

## Why FlutterForge?

Starting a new Flutter project means hours of setup - folder structure, state management, DI, routing, theming. **FlutterForge** gives you a production-ready foundation in seconds.

```bash
# Create new project with best practices baked in
flutter_forge create my_app

# Generate features following clean architecture
flutter_forge generate feature auth
flutter_forge generate model User
flutter_forge generate repository UserRepository
```

## Features

| Feature | Implementation |
|---------|---------------|
| 🏗️ **Architecture** | Clean Architecture + Feature-first |
| 🔄 **State** | Riverpod 2.0 |
| 🧭 **Routing** | GoRouter with type-safe routes |
| 💉 **DI** | Riverpod dependency injection |
| 🌐 **Network** | Dio + Retrofit code generation |
| 💾 **Storage** | Hive + SharedPreferences |
| 🎨 **Theming** | Material 3 + Dark mode |
| 🌍 **i18n** | Easy Localization |
| 🧪 **Testing** | Unit + Widget + Integration |
| 🚀 **CI/CD** | GitHub Actions ready |
| 📱 **Platform** | iOS, Android, Web, Desktop |

## Requirements

| Requirement | Version |
|-------------|---------|
| Flutter | 3.24+ |
| Dart | 3.5+ |
| iOS | 12.0+ |
| Android | API 21+ (Android 5.0) |

## Installation

### Global Activation

```bash
dart pub global activate flutter_forge
```

### As a Dev Dependency

```yaml
dev_dependencies:
  flutter_forge: ^1.0.0
```

## Quick Start

### Create a New Project

```bash
flutter_forge create my_awesome_app
cd my_awesome_app
flutter run
```

### Generate a Feature

```bash
flutter_forge generate feature profile
```

This creates:
```
lib/features/profile/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

## Documentation

### Project Structure

```
lib/
├── app/
│   ├── app.dart              # App widget
│   └── router.dart           # GoRouter configuration
├── core/
│   ├── network/              # Dio setup, interceptors
│   ├── storage/              # Local storage
│   ├── theme/                # Theme data
│   └── utils/                # Helpers, extensions
├── features/
│   ├── auth/                 # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/                 # Home feature
├── shared/
│   ├── widgets/              # Reusable widgets
│   └── extensions/           # Dart extensions
└── main.dart                 # Entry point
```

### Code Generation

```bash
# Generate a model with JSON serialization
flutter_forge generate model User

# Generate a repository with interface
flutter_forge generate repository UserRepository

# Generate a use case
flutter_forge generate usecase GetUserProfile

# Generate a screen with provider
flutter_forge generate screen Settings
```

### State Management

Using Riverpod 2.0 for reactive state management:

```dart
// Provider definition
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getCurrentUser();
});

// Usage in widget
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

Type-safe API client with Retrofit:

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

Automatic light/dark mode support:

```dart
// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Usage in app
MaterialApp(
  themeMode: ref.watch(themeProvider),
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
)
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
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

## CLI Commands

| Command | Description |
|---------|-------------|
| `create <name>` | Create a new project |
| `generate feature <name>` | Generate a new feature module |
| `generate model <name>` | Generate a model with JSON |
| `generate repository <name>` | Generate a repository |
| `generate usecase <name>` | Generate a use case |
| `generate screen <name>` | Generate a screen |
| `generate widget <name>` | Generate a widget |

## CI/CD

Pre-configured GitHub Actions workflows:

- **Lint** - Code analysis on every PR
- **Test** - Run tests on every PR
- **Build** - Build artifacts on main
- **Deploy** - Optional store deployment

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

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
