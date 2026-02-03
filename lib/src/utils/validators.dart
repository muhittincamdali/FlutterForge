/// Form validation utilities.
///
/// Provides reusable validators for form fields
/// with customizable error messages.
library;

/// Type alias for validator functions.
typedef Validator = String? Function(String?);

/// Collection of common validators.
class Validators {
  Validators._();

  /// Creates a required field validator.
  static Validator required([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// Creates an email validator.
  static Validator email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!regex.hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    };
  }

  /// Creates a phone number validator.
  static Validator phone([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      final regex = RegExp(r'^\+?[0-9]{10,15}$');
      if (!regex.hasMatch(cleaned)) {
        return message ?? 'Please enter a valid phone number';
      }
      return null;
    };
  }

  /// Creates a minimum length validator.
  static Validator minLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    };
  }

  /// Creates a maximum length validator.
  static Validator maxLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > length) {
        return message ?? 'Must be at most $length characters';
      }
      return null;
    };
  }

  /// Creates an exact length validator.
  static Validator exactLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length != length) {
        return message ?? 'Must be exactly $length characters';
      }
      return null;
    };
  }

  /// Creates a pattern validator.
  static Validator pattern(RegExp regex, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) {
        return message ?? 'Invalid format';
      }
      return null;
    };
  }

  /// Creates a numeric validator.
  static Validator numeric([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (double.tryParse(value) == null) {
        return message ?? 'Please enter a valid number';
      }
      return null;
    };
  }

  /// Creates an integer validator.
  static Validator integer([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (int.tryParse(value) == null) {
        return message ?? 'Please enter a whole number';
      }
      return null;
    };
  }

  /// Creates a minimum value validator.
  static Validator minValue(num min, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = num.tryParse(value);
      if (number == null || number < min) {
        return message ?? 'Must be at least $min';
      }
      return null;
    };
  }

  /// Creates a maximum value validator.
  static Validator maxValue(num max, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = num.tryParse(value);
      if (number == null || number > max) {
        return message ?? 'Must be at most $max';
      }
      return null;
    };
  }

  /// Creates a range validator.
  static Validator range(num min, num max, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = num.tryParse(value);
      if (number == null || number < min || number > max) {
        return message ?? 'Must be between $min and $max';
      }
      return null;
    };
  }

  /// Creates a URL validator.
  static Validator url([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.hasAbsolutePath) {
        return message ?? 'Please enter a valid URL';
      }
      return null;
    };
  }

  /// Creates a password strength validator.
  static Validator password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecial = false,
    String? message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final errors = <String>[];

      if (value.length < minLength) {
        errors.add('at least $minLength characters');
      }
      if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
        errors.add('an uppercase letter');
      }
      if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
        errors.add('a lowercase letter');
      }
      if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
        errors.add('a number');
      }
      if (requireSpecial && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        errors.add('a special character');
      }

      if (errors.isNotEmpty) {
        return message ?? 'Password must contain ${errors.join(', ')}';
      }
      return null;
    };
  }

  /// Creates a match validator.
  static Validator match(String Function() getValue, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value != getValue()) {
        return message ?? 'Values do not match';
      }
      return null;
    };
  }

  /// Creates a credit card validator.
  static Validator creditCard([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
      if (!_luhnCheck(cleaned)) {
        return message ?? 'Please enter a valid card number';
      }
      return null;
    };
  }

  /// Creates a date validator.
  static Validator date({
    String format = 'yyyy-MM-dd',
    String? message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (DateTime.tryParse(value) == null) {
        return message ?? 'Please enter a valid date';
      }
      return null;
    };
  }

  /// Creates a future date validator.
  static Validator futureDate([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final date = DateTime.tryParse(value);
      if (date == null || date.isBefore(DateTime.now())) {
        return message ?? 'Date must be in the future';
      }
      return null;
    };
  }

  /// Creates a past date validator.
  static Validator pastDate([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final date = DateTime.tryParse(value);
      if (date == null || date.isAfter(DateTime.now())) {
        return message ?? 'Date must be in the past';
      }
      return null;
    };
  }

  /// Combines multiple validators.
  static Validator compose(List<Validator> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Luhn algorithm for credit card validation.
  static bool _luhnCheck(String number) {
    if (!RegExp(r'^[0-9]+$').hasMatch(number)) return false;

    var sum = 0;
    var alternate = false;

    for (var i = number.length - 1; i >= 0; i--) {
      var digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}

/// Validator builder for fluent validation.
class ValidatorBuilder {
  final List<Validator> _validators = [];

  /// Adds required validation.
  ValidatorBuilder required([String? message]) {
    _validators.add(Validators.required(message));
    return this;
  }

  /// Adds email validation.
  ValidatorBuilder email([String? message]) {
    _validators.add(Validators.email(message));
    return this;
  }

  /// Adds min length validation.
  ValidatorBuilder minLength(int length, [String? message]) {
    _validators.add(Validators.minLength(length, message));
    return this;
  }

  /// Adds max length validation.
  ValidatorBuilder maxLength(int length, [String? message]) {
    _validators.add(Validators.maxLength(length, message));
    return this;
  }

  /// Adds pattern validation.
  ValidatorBuilder pattern(RegExp regex, [String? message]) {
    _validators.add(Validators.pattern(regex, message));
    return this;
  }

  /// Adds custom validation.
  ValidatorBuilder custom(Validator validator) {
    _validators.add(validator);
    return this;
  }

  /// Builds the composed validator.
  Validator build() => Validators.compose(_validators);
}
