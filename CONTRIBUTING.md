# Contributing to FlutterForge

First off, thank you for considering contributing to FlutterForge! It's people like you that make FlutterForge such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps which reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include Flutter/Dart version and OS version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing style (analysis_options.yaml)
6. Issue that pull request!

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/FlutterForge.git

# Navigate to the project
cd FlutterForge

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the CLI locally
dart run bin/flutter_forge.dart create test_app
```

## Project Structure

```
lib/
├── src/
│   ├── commands/       # CLI command implementations
│   ├── generators/     # Code generators for features, models, etc.
│   ├── templates/      # Template files for code generation
│   └── utils/          # Shared utilities
├── flutter_forge.dart  # Public API
bin/
└── flutter_forge.dart  # CLI entry point
test/
└── ...                 # Test files
```

## Style Guide

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use the project's `analysis_options.yaml` for linting
- Write meaningful commit messages following [Conventional Commits](https://www.conventionalcommits.org/)
- Document public APIs with dartdoc comments

## Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code change that neither fixes a bug nor adds a feature
- `test:` Adding missing tests
- `chore:` Changes to the build process or auxiliary tools

Example: `feat(generator): add service layer code generation`

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/commands/create_test.dart
```

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
