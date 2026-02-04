<p align="center">
  <img src="assets/logo.png" alt="FlutterForge" width="200"/>
</p>

<h1 align="center">FlutterForge</h1>

<p align="center">
  <strong>🔨 Production-ready Flutter project template with CLI, Riverpod & clean architecture</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI"/>
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.24-blue.svg" alt="Flutter 3.24"/>
  <img src="https://img.shields.io/badge/Dart-3.5-blue.svg" alt="Dart 3.5"/>
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"/>
</p>

---

## Why FlutterForge?

Starting a new Flutter project means hours of setup - folder structure, state management, DI, routing, theming. **FlutterForge** gives you a production-ready foundation in seconds.

```bash
# Create new project
flutter_forge create my_app

# Generate features
flutter_forge generate feature auth
flutter_forge generate model User
flutter_forge generate repository UserRepository
```

## What's Included

| Feature | Implementation |
|---------|---------------|
| 🏗️ **Architecture** | Clean Architecture + Feature-first |
| 🔄 **State** | Riverpod 2.0 |
| 🧭 **Routing** | GoRouter |
| 💉 **DI** | Riverpod |
| 🌐 **Network** | Dio + Retrofit |
| 💾 **Storage** | Hive + SharedPrefs |
| 🎨 **Theming** | Material 3 + Dark mode |
| 🌍 **i18n** | Easy Localization |
| 🧪 **Testing** | Unit + Widget + Integration |
| 🚀 **CI/CD** | GitHub Actions |

## Installation

```bash
dart pub global activate flutter_forge
```

## Quick Start

### Create Project

```bash
flutter_forge create my_awesome_app
cd my_awesome_app
flutter run
```

### Project Structure

```
lib/
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/
├── shared/
│   ├── widgets/
│   └── extensions/
└── main.dart
```

### Generate Code

```bash
# Generate a new feature
flutter_forge generate feature profile

# Creates:
# lib/features/profile/
# ├── data/
# │   ├── datasources/
# │   ├── models/
# │   └── repositories/
# ├── domain/
# │   ├── entities/
# │   ├── repositories/
# │   └── usecases/
# └── presentation/
#     ├── providers/
#     ├── screens/
#     └── widgets/
```

## State Management

```dart
// Provider
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getCurrentUser();
});

// Usage
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) => UserProfile(user: user),
      loading: () => LoadingIndicator(),
      error: (e, _) => ErrorWidget(message: e.toString()),
    );
  }
}
```

## Networking

```dart
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;
  
  @GET('/users/{id}')
  Future<UserDto> getUser(@Path() String id);
  
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);
}
```

## Theming

```dart
// Automatic light/dark mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Usage
MaterialApp(
  themeMode: ref.watch(themeProvider),
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
)
```

## Testing

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
```

## CI/CD

Pre-configured GitHub Actions:
- Lint on PR
- Test on PR
- Build on main
- Deploy to stores (optional)

## CLI Commands

| Command | Description |
|---------|-------------|
| `create <name>` | New project |
| `generate feature <name>` | New feature |
| `generate model <name>` | New model |
| `generate repository <name>` | New repository |
| `generate usecase <name>` | New use case |
| `generate screen <name>` | New screen |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/FlutterForge&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/FlutterForge&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/FlutterForge&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/FlutterForge&type=Date" />
 </picture>
</a>
