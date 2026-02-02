# Contributing to FlutterForge

First off, thanks for taking the time to contribute! 🎉

The following is a set of guidelines for contributing to FlutterForge. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)

## Code of Conduct

This project and everyone participating in it is governed by the [FlutterForge Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, screenshots)
- **Describe the behavior you observed and what you expected**
- **Include your environment details** (Flutter version, OS, device)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List any alternatives you've considered**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure the test suite passes
4. Make sure your code follows the style guidelines
5. Issue your pull request

## Development Setup

1. **Fork and clone the repository**

```bash
git clone https://github.com/YOUR_USERNAME/FlutterForge.git
cd FlutterForge
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Create a branch**

```bash
git checkout -b feature/your-feature-name
```

5. **Make your changes and test**

```bash
flutter analyze
flutter test
```

## Style Guidelines

### Dart Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `very_good_analysis` linter rules
- Run `dart format lib/ test/` before committing
- Maximum line length: 80 characters (flexible)
- Prefer `const` constructors where possible
- Use trailing commas for better formatting

### File Organization

- One class per file (exceptions for small related classes)
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Variable/function names: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE`

### Architecture Rules

- **Domain layer** must not depend on Data or Presentation
- **Data layer** depends only on Domain
- **Presentation layer** depends on Domain (not Data directly)
- Use cases should have a single public method
- Repositories should be defined as abstract classes in Domain

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style changes (formatting, etc.) |
| `refactor` | Code refactoring |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |
| `perf` | Performance improvements |
| `ci` | CI/CD changes |

### Examples

```
feat(auth): add biometric login support
fix(network): handle timeout errors gracefully
docs(readme): update installation instructions
test(auth): add login use case unit tests
```

## Pull Requests

### PR Checklist

- [ ] Code follows the project style guidelines
- [ ] Self-reviewed the code
- [ ] Added/updated tests as needed
- [ ] All tests pass (`flutter test`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Updated documentation if needed
- [ ] Commit messages follow conventional commits
- [ ] PR title is clear and descriptive

### PR Title Format

```
type(scope): brief description
```

Example: `feat(auth): add social login support`

### PR Description Template

Your PR description should include:
- **What**: What changes were made
- **Why**: Why were these changes needed
- **How**: How were the changes implemented
- **Testing**: How were the changes tested

---

Thank you for contributing! 🚀
