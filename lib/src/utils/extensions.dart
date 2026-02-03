/// Dart and Flutter extension methods.
///
/// Provides useful extension methods for common types
/// to improve code readability and reduce boilerplate.
library;

import 'package:flutter/material.dart';

// String extensions
extension StringExtension on String {
  /// Capitalizes the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes each word.
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Checks if string is a valid email.
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Checks if string is a valid phone number.
  bool get isValidPhone {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(this);
  }

  /// Checks if string is a valid URL.
  bool get isValidUrl {
    return Uri.tryParse(this)?.hasAbsolutePath ?? false;
  }

  /// Checks if string contains only digits.
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Checks if string contains only letters.
  bool get isAlpha {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Checks if string contains only letters and digits.
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Truncates string to max length with ellipsis.
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Removes all whitespace.
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Converts to snake_case.
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst('_', '');
  }

  /// Converts to camelCase.
  String get toCamelCase {
    final words = split(RegExp(r'[_\s-]'));
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize).join();
  }

  /// Converts to PascalCase.
  String get toPascalCase {
    return split(RegExp(r'[_\s-]')).map((w) => w.capitalize).join();
  }

  /// Returns null if empty.
  String? get nullIfEmpty => isEmpty ? null : this;
}

// Nullable String extensions
extension NullableStringExtension on String? {
  /// Returns true if null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the value or default.
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}

// List extensions
extension ListExtension<T> on List<T> {
  /// Gets element at index or null if out of bounds.
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Gets first element or null if empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Gets last element or null if empty.
  T? get lastOrNull => isEmpty ? null : last;

  /// Separates elements with a separator.
  List<T> separatedBy(T separator) {
    if (length <= 1) return this;
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }

  /// Splits list into chunks.
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }
}

// Iterable extensions
extension IterableExtension<T> on Iterable<T> {
  /// Maps with index.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    var index = 0;
    for (final element in this) {
      yield transform(index++, element);
    }
  }

  /// Filters with index.
  Iterable<T> whereIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index++, element)) yield element;
    }
  }

  /// Groups elements by key.
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }

  /// Gets distinct elements.
  List<T> distinct() => toSet().toList();

  /// Gets distinct elements by key.
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((e) => seen.add(keySelector(e))).toList();
  }
}

// Map extensions
extension MapExtension<K, V> on Map<K, V> {
  /// Gets value or default.
  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;

  /// Gets value or computes it.
  V getOrPut(K key, V Function() defaultValue) {
    return this[key] ??= defaultValue();
  }

  /// Filters entries.
  Map<K, V> where(bool Function(K key, V value) test) {
    return Map.fromEntries(entries.where((e) => test(e.key, e.value)));
  }

  /// Maps values.
  Map<K, R> mapValues<R>(R Function(V value) transform) {
    return map((k, v) => MapEntry(k, transform(v)));
  }
}

// DateTime extensions
extension DateTimeExtension on DateTime {
  /// Checks if same day.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Checks if today.
  bool get isToday => isSameDay(DateTime.now());

  /// Checks if yesterday.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Checks if tomorrow.
  bool get isTomorrow =>
      isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Gets start of day.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Gets end of day.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Gets start of week (Monday).
  DateTime get startOfWeek {
    final days = weekday - 1;
    return subtract(Duration(days: days)).startOfDay;
  }

  /// Gets start of month.
  DateTime get startOfMonth => DateTime(year, month);

  /// Gets days in month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Adds working days.
  DateTime addWorkingDays(int days) {
    var result = this;
    var added = 0;
    while (added < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        added++;
      }
    }
    return result;
  }
}

// Duration extensions
extension DurationExtension on Duration {
  /// Formats as HH:MM:SS.
  String get formatted {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Formats as human readable.
  String get humanReadable {
    if (inDays > 0) return '$inDays day${inDays > 1 ? 's' : ''}';
    if (inHours > 0) return '$inHours hour${inHours > 1 ? 's' : ''}';
    if (inMinutes > 0) return '$inMinutes minute${inMinutes > 1 ? 's' : ''}';
    return '$inSeconds second${inSeconds > 1 ? 's' : ''}';
  }
}

// Num extensions
extension NumExtension on num {
  /// Clamps value between min and max.
  num clampValue(num min, num max) => this < min ? min : (this > max ? max : this);

  /// Checks if between min and max.
  bool isBetween(num min, num max) => this >= min && this <= max;
}

// BuildContext extensions
extension BuildContextExtension on BuildContext {
  /// Gets theme data.
  ThemeData get theme => Theme.of(this);

  /// Gets color scheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Gets text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Gets media query data.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Gets screen size.
  Size get screenSize => mediaQuery.size;

  /// Gets screen width.
  double get screenWidth => screenSize.width;

  /// Gets screen height.
  double get screenHeight => screenSize.height;

  /// Checks if keyboard is visible.
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// Checks if dark mode.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Shows a snackbar.
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration ?? const Duration(seconds: 3)),
    );
  }

  /// Pops the navigator.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Pushes a route.
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  }
}
