/// Text input formatters and data formatting utilities.
///
/// Provides formatters for phone numbers, credit cards,
/// currency, and other common data types.
library;

import 'package:flutter/services.dart';

/// Phone number input formatter.
class PhoneNumberFormatter extends TextInputFormatter {
  /// Creates a new [PhoneNumberFormatter].
  PhoneNumberFormatter({
    this.mask = '(###) ###-####',
    this.separator = '#',
  });

  /// The mask pattern.
  final String mask;

  /// The separator character in the mask.
  final String separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    var digitIndex = 0;

    for (var i = 0; i < mask.length && digitIndex < digitsOnly.length; i++) {
      if (mask[i] == separator) {
        buffer.write(digitsOnly[digitIndex]);
        digitIndex++;
      } else {
        buffer.write(mask[i]);
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Credit card number formatter.
class CreditCardFormatter extends TextInputFormatter {
  /// Creates a new [CreditCardFormatter].
  CreditCardFormatter({this.separator = ' '});

  /// The separator between groups.
  final String separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (var i = 0; i < digitsOnly.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(separator);
      }
      buffer.write(digitsOnly[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Expiry date formatter (MM/YY).
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (var i = 0; i < digitsOnly.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(digitsOnly[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Currency input formatter.
class CurrencyFormatter extends TextInputFormatter {
  /// Creates a new [CurrencyFormatter].
  CurrencyFormatter({
    this.symbol = '\$',
    this.decimalDigits = 2,
    this.thousandsSeparator = ',',
    this.decimalSeparator = '.',
  });

  /// Currency symbol.
  final String symbol;

  /// Number of decimal digits.
  final int decimalDigits;

  /// Thousands separator.
  final String thousandsSeparator;

  /// Decimal separator.
  final String decimalSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = int.parse(digitsOnly);
    final formatted = _formatCurrency(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(int cents) {
    final dollars = cents ~/ 100;
    final remaining = cents % 100;

    final dollarsStr = dollars.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}$thousandsSeparator',
        );

    final centsStr = remaining.toString().padLeft(decimalDigits, '0');

    return '$symbol$dollarsStr$decimalSeparator$centsStr';
  }
}

/// Uppercase input formatter.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Lowercase input formatter.
class LowerCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

/// Digits only input formatter.
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

/// Alpha only input formatter.
class AlphaOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final alphaOnly = newValue.text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return TextEditingValue(
      text: alphaOnly,
      selection: TextSelection.collapsed(offset: alphaOnly.length),
    );
  }
}

/// Mask input formatter.
class MaskFormatter extends TextInputFormatter {
  /// Creates a new [MaskFormatter].
  MaskFormatter({
    required this.mask,
    this.placeholder = '#',
    this.filter,
  });

  /// The mask pattern.
  final String mask;

  /// Placeholder character for input.
  final String placeholder;

  /// Custom filter for characters.
  final Map<String, RegExp>? filter;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    var textIndex = 0;

    for (var i = 0; i < mask.length && textIndex < text.length; i++) {
      final maskChar = mask[i];

      if (maskChar == placeholder) {
        final inputChar = text[textIndex];
        final filterRegex = filter?[maskChar];

        if (filterRegex == null || filterRegex.hasMatch(inputChar)) {
          buffer.write(inputChar);
          textIndex++;
        } else {
          textIndex++;
          i--;
        }
      } else {
        buffer.write(maskChar);
        if (text[textIndex] == maskChar) {
          textIndex++;
        }
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Data formatting utilities.
class DataFormatters {
  DataFormatters._();

  /// Formats a file size.
  static String fileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final i = (bytes == 0) ? 0 : (log(bytes.toDouble()) / log(1024)).floor();
    final size = bytes / pow(1024, i);

    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Formats a duration.
  static String duration(Duration duration, {bool short = false}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (short) {
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    }

    final parts = <String>[];
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    if (seconds > 0) parts.add('$seconds second${seconds > 1 ? 's' : ''}');

    return parts.isEmpty ? '0 seconds' : parts.join(', ');
  }

  /// Formats a number with K/M/B suffix.
  static String compact(num value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  /// Formats a percentage.
  static String percentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Masks sensitive data.
  static String mask(String value, {int visibleChars = 4, String maskChar = '*'}) {
    if (value.length <= visibleChars) return value;

    final masked = maskChar * (value.length - visibleChars);
    return masked + value.substring(value.length - visibleChars);
  }

  /// Masks email address.
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final local = parts[0];
    final domain = parts[1];

    final maskedLocal = local.length > 2
        ? '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}'
        : local;

    return '$maskedLocal@$domain';
  }
}

/// Simple math utilities.
double log(double x) {
  const ln10 = 2.302585092994046;
  return _ln(x) / ln10 * ln10;
}

double _ln(double x) {
  if (x <= 0) return double.nan;
  var result = 0.0;
  var term = (x - 1) / (x + 1);
  var termSq = term * term;
  var currentTerm = term;
  for (var i = 1; i < 100; i += 2) {
    result += currentTerm / i;
    currentTerm *= termSq;
  }
  return 2 * result;
}

double pow(double x, int n) {
  if (n == 0) return 1;
  var result = 1.0;
  for (var i = 0; i < n; i++) {
    result *= x;
  }
  return result;
}
