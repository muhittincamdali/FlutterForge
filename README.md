<div align="center">

# 🔨 FlutterForge

**Production-ready Flutter project template with CLI, Riverpod & clean architecture**

[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![pub.dev](https://img.shields.io/badge/pub.dev-Package-blue?style=for-the-badge)](https://pub.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 🏗️ **Clean Architecture** — Feature-first structure
- 🎯 **Riverpod** — State management included
- 🔧 **CLI Tool** — Generate features/screens
- 🌍 **i18n Ready** — Localization setup
- 🧪 **Testing** — Unit, widget, integration
- 🎨 **Theming** — Light/dark with tokens

---

## 🚀 Quick Start

```bash
# Create new project
dart pub global activate flutterforge
flutterforge create my_app

# Generate feature
flutterforge generate feature auth

# Generate screen
flutterforge generate screen login
```

```dart
// Clean architecture example
class GetUsersUseCase {
  final UserRepository repository;
  
  Future<List<User>> call() => repository.getUsers();
}
```

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)
