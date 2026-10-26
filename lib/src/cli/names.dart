/// Name rules and case conversions for the `forge` command.
library;

/// The longest project or feature name accepted.
const int maxNameLength = 64;

/// The longest app description accepted.
const int maxDescriptionLength = 200;

/// Dart reserved words and built-in identifiers, which cannot be package or
/// library names (Dart language specification, section 17.37).
const Set<String> dartKeywords = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case', 'catch', 'class', 'const', //
  'continue', 'covariant', 'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export', 'extends',
  'extension', 'external', 'factory', 'false', 'final', 'finally', 'for', 'function', 'get', 'hide', 'if',
  'implements', 'import', 'in', 'interface', 'is', 'late', 'library', 'mixin', 'new', 'null', 'of', 'on',
  'operator', 'part', 'required', 'rethrow', 'return', 'sealed', 'set', 'show', 'static', 'super', 'switch',
  'sync', 'this', 'throw', 'true', 'try', 'type', 'typedef', 'var', 'void', 'when', 'while', 'with', 'yield',
};

/// Package names a generated app depends on; a project with one of these
/// names would shadow its own dependency.
const Set<String> reservedPackageNames = {
  'flutter',
  'flutter_test',
  'flutter_lints',
  'flutter_forge',
  'flutter_riverpod',
  'riverpod',
  'go_router',
  'http',
  'test',
};

// Names the generated files import from dart:core, Flutter's material
// library, flutter_test, Riverpod, go_router or the app itself.
const Set<String> _clashingTypes = {
  'Object', 'String', 'List', 'Map', 'Set', 'Future', 'Stream', 'Type', 'Function', 'Record', 'Error', //
  'Exception', 'Duration', 'DateTime', 'Uri', 'Iterable', 'Symbol', 'Null', 'Never', 'Pattern', 'Match',
  'Text', 'Icon', 'Icons', 'Image', 'Card', 'Container', 'Row', 'Column', 'Center', 'Padding', 'Scaffold',
  'Theme', 'Color', 'Colors', 'Key', 'Widget', 'State', 'Action', 'Actions', 'Intent', 'Title', 'Table',
  'Form', 'Page', 'Route', 'Router', 'Navigator', 'Overlay', 'Tooltip', 'Chip', 'Badge', 'Banner', 'Material',
  'Flex', 'Stack', 'Align', 'Expanded', 'Flexible', 'Wrap', 'Spacer', 'Divider', 'Drawer', 'Dialog', 'Switch',
  'Checkbox', 'Radio', 'Slider', 'Tab', 'Placeholder', 'Visibility', 'Opacity', 'Transform', 'Listener',
  'Notification', 'Animation', 'Curve', 'Size', 'Offset', 'Rect', 'Border', 'Shadow', 'Gradient', 'Path',
  'Canvas', 'Paint', 'Picture', 'Locale', 'Brightness', 'Feature', 'Finder', 'Matcher', 'Provider', 'Ref',
  'Notifier', 'AsyncValue', 'AsyncData', 'AsyncError', 'AsyncLoading', 'Override', 'GoRoute', 'GoRouter',
  'Destination', 'App', 'AppTheme', 'ErrorView', 'HomePage',
};

// Java keywords and literals (JLS 3.9), which cannot be part of an Android
// package name.
const Set<String> _javaKeywords = {
  'abstract', 'assert', 'boolean', 'break', 'byte', 'case', 'catch', 'char', 'class', 'const', 'continue', //
  'default', 'do', 'double', 'else', 'enum', 'extends', 'final', 'finally', 'float', 'for', 'goto', 'if',
  'implements', 'import', 'instanceof', 'int', 'interface', 'long', 'native', 'new', 'package', 'private',
  'protected', 'public', 'return', 'short', 'static', 'strictfp', 'super', 'switch', 'synchronized', 'this',
  'throw', 'throws', 'transient', 'try', 'void', 'volatile', 'while', 'true', 'false', 'null', '_',
};

final RegExp _snake = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');
final RegExp _pascal = RegExp(r'^[A-Z][A-Za-z0-9]*$');
final RegExp _org = RegExp(r'^[A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z][A-Za-z0-9_]*)+$');
final RegExp _descriptionForbidden = RegExp(r'[\x00-\x1F\x7F"\\`$&|<>^%]');
final RegExp _routeSegment = RegExp(r'^/[a-z0-9]+(?:[-/][a-z0-9]+)*$');

/// Thrown when a name or option given to `forge` is not usable.
final class InvalidInput implements Exception {
  /// Creates the exception with a message for the user.
  const InvalidInput(this.message);

  /// What is wrong and how to fix it.
  final String message;

  @override
  String toString() => message;
}

/// Checks a project name: a valid Dart package name that does not clash with
/// a dependency of the generated app.
String checkProjectName(String name) {
  _checkSnake(name, 'project name');
  if (reservedPackageNames.contains(name)) {
    throw InvalidInput('"$name" is the name of a package the app depends on. Choose another project name.');
  }
  return name;
}

/// Checks a feature name: lower case words joined by underscores, such as
/// `orders` or `order_items`.
String checkFeatureName(String name) {
  _checkSnake(name, 'feature name');
  if (const {'app', 'core', 'home'}.contains(name)) {
    throw InvalidInput('"$name" is used by the generated app itself. Choose another feature name.');
  }
  if (const {'material', 'cupertino', 'custom_transition', 'no_transition'}.contains(name)) {
    throw InvalidInput('"${pascalCase(name)}Page" is a Flutter or go_router class. Choose another feature name.');
  }
  return name;
}

void _checkSnake(String name, String what) {
  if (name.isEmpty) throw InvalidInput('The $what is empty.');
  if (name.length > maxNameLength) {
    throw InvalidInput('The $what is longer than $maxNameLength characters.');
  }
  if (!_snake.hasMatch(name)) {
    throw InvalidInput(
      'The $what "${_printable(name)}" must use lower-case letters, digits and single underscores, '
      'start with a letter, and not end with an underscore (for example my_app).',
    );
  }
  if (dartKeywords.contains(name)) {
    throw InvalidInput('"$name" is a Dart keyword and cannot be used as a $what.');
  }
}

/// Checks an entity class name such as `Order`.
String checkEntityName(String name) {
  if (name.length > maxNameLength || !_pascal.hasMatch(name)) {
    throw InvalidInput(
      'The entity name "${_printable(name)}" must be a class name in PascalCase, such as Order, '
      'of at most $maxNameLength characters.',
    );
  }
  if (_clashingTypes.contains(name)) {
    throw InvalidInput(
      '"$name" is also a Dart, Flutter, Riverpod or go_router type, so the generated code would not compile. '
      'Pass another name with --entity.',
    );
  }
  return name;
}

/// Checks a reverse domain organisation such as `com.example`.
String checkOrganization(String org) {
  if (org.length > 128 || !_org.hasMatch(org)) {
    throw InvalidInput(
      'The organization "${_printable(org)}" must be a reverse domain name such as com.example: '
      'two or more parts of letters, digits and underscores, each starting with a letter.',
    );
  }
  for (final part in org.split('.')) {
    if (_javaKeywords.contains(part)) {
      throw InvalidInput('The organization part "$part" is a Java keyword, which Android does not allow in an app id.');
    }
  }
  return org;
}

/// Checks a one-line app description. It is written into `pubspec.yaml` and
/// passed to `flutter create`, so quotes, backslashes, shell metacharacters
/// and control characters are refused.
String checkDescription(String description) {
  final trimmed = description.trim();
  if (trimmed.isEmpty) throw const InvalidInput('The description is empty.');
  if (trimmed.length > maxDescriptionLength) {
    throw const InvalidInput('The description is longer than $maxDescriptionLength characters.');
  }
  if (_descriptionForbidden.hasMatch(trimmed)) {
    throw const InvalidInput(
      r'The description must not contain quotes, \, `, $, &, |, <, >, ^, % or control characters.',
    );
  }
  return trimmed;
}

/// Checks an API path such as `/orders` or `/v2/order-items`.
String checkApiPath(String path) {
  if (path.length > 200 || !_routeSegment.hasMatch(path)) {
    throw InvalidInput(
      'The API path "${_printable(path)}" must start with / and use lower-case letters, digits, - and /, '
      'such as /orders or /v2/order-items.',
    );
  }
  return path;
}

/// `order_items` to `OrderItems`.
String pascalCase(String snake) => snake.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join();

/// `order_items` to `orderItems`.
String camelCase(String snake) {
  final pascal = pascalCase(snake);
  return pascal[0].toLowerCase() + pascal.substring(1);
}

/// `order_items` to `Order items`.
String titleCase(String snake) {
  final words = snake.split('_');
  return [words.first[0].toUpperCase() + words.first.substring(1), ...words.skip(1)].join(' ');
}

/// `order_items` to `order-items`, for URLs.
String kebabCase(String snake) => snake.replaceAll('_', '-');

/// A best-effort singular class name for a plural feature name:
/// `todos` to `Todo`, `categories` to `Category`, `boxes` to `Box`. Words
/// it cannot change safely, such as `status` or `news`, stay as they are; pass
/// `--entity` to choose the name yourself.
String singularEntity(String feature) {
  final words = feature.split('_');
  final last = words.last;
  final String singular;
  if (last.length > 4 && last.endsWith('ies')) {
    singular = '${last.substring(0, last.length - 3)}y';
  } else if (RegExp(r'(?:s|x|z|ch|sh)es$').hasMatch(last) && last.length > 4) {
    singular = last.substring(0, last.length - 2);
  } else if (last.length > 3 && last.endsWith('s') && !RegExp(r'(?:ss|us|is|ews)$').hasMatch(last)) {
    singular = last.substring(0, last.length - 1);
  } else {
    singular = last;
  }
  return pascalCase([...words.take(words.length - 1), singular].join('_'));
}

String _printable(String value) {
  final shortened = value.length > 80 ? '${value.substring(0, 80)}…' : value;
  return shortened.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '?');
}
