/// Base classes for entities in Clean Architecture.
///
/// Entities represent the core business objects of the application
/// and contain enterprise-wide business rules.
library;

import 'package:equatable/equatable.dart';

/// Base class for all domain entities.
///
/// Entities are the core business objects that hold business logic
/// and rules. They are independent of any external layer.
///
/// Example:
/// ```dart
/// class UserEntity extends Entity<String> {
///   final String name;
///   final String email;
///
///   const UserEntity({
///     required super.id,
///     required this.name,
///     required this.email,
///   });
///
///   @override
///   List<Object?> get props => [id, name, email];
/// }
/// ```
abstract class Entity<T> extends Equatable {
  /// Creates a new [Entity] with the given [id].
  const Entity({required this.id});

  /// The unique identifier of this entity.
  final T id;

  @override
  List<Object?> get props => [id];
}

/// Base class for entities with audit information.
///
/// Includes created and updated timestamps for tracking changes.
abstract class AuditableEntity<T> extends Entity<T> {
  /// Creates a new [AuditableEntity].
  const AuditableEntity({
    required super.id,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// When the entity was created.
  final DateTime createdAt;

  /// When the entity was last updated.
  final DateTime? updatedAt;

  /// Who created the entity.
  final String? createdBy;

  /// Who last updated the entity.
  final String? updatedBy;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}

/// Base class for entities that can be soft-deleted.
abstract class SoftDeletableEntity<T> extends AuditableEntity<T> {
  /// Creates a new [SoftDeletableEntity].
  const SoftDeletableEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    super.createdBy,
    super.updatedBy,
    this.deletedAt,
    this.deletedBy,
    this.isDeleted = false,
  });

  /// When the entity was deleted.
  final DateTime? deletedAt;

  /// Who deleted the entity.
  final String? deletedBy;

  /// Whether the entity is deleted.
  final bool isDeleted;

  @override
  List<Object?> get props => [
        ...super.props,
        deletedAt,
        deletedBy,
        isDeleted,
      ];
}

/// Base class for entities with version control.
abstract class VersionedEntity<T> extends AuditableEntity<T> {
  /// Creates a new [VersionedEntity].
  const VersionedEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    super.createdBy,
    super.updatedBy,
    this.version = 1,
  });

  /// The version number of this entity.
  final int version;

  @override
  List<Object?> get props => [...super.props, version];
}

/// Base class for value objects.
///
/// Value objects are immutable objects that are defined by their
/// attributes rather than their identity.
///
/// Example:
/// ```dart
/// class EmailAddress extends ValueObject<String> {
///   EmailAddress(super.value) {
///     if (!_isValidEmail(value)) {
///       throw ArgumentError('Invalid email address');
///     }
///   }
///
///   bool _isValidEmail(String email) {
///     return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
///   }
/// }
/// ```
abstract class ValueObject<T> extends Equatable {
  /// Creates a new [ValueObject] with the given [value].
  const ValueObject(this.value);

  /// The value held by this value object.
  final T value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();
}

/// Value object for email addresses.
class EmailAddress extends ValueObject<String> {
  /// Creates a new [EmailAddress].
  ///
  /// Throws [ArgumentError] if the email is invalid.
  EmailAddress(super.value) {
    if (!isValid(value)) {
      throw ArgumentError('Invalid email address: $value');
    }
  }

  /// Validates an email address.
  static bool isValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Creates an email if valid, returns null otherwise.
  static EmailAddress? tryCreate(String value) {
    try {
      return EmailAddress(value);
    } catch (_) {
      return null;
    }
  }
}

/// Value object for phone numbers.
class PhoneNumber extends ValueObject<String> {
  /// Creates a new [PhoneNumber].
  ///
  /// Throws [ArgumentError] if the phone number is invalid.
  PhoneNumber(super.value) {
    if (!isValid(value)) {
      throw ArgumentError('Invalid phone number: $value');
    }
  }

  /// Validates a phone number.
  static bool isValid(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned);
  }

  /// Returns the phone number without formatting.
  String get cleaned => value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
}

/// Value object for URLs.
class UrlAddress extends ValueObject<String> {
  /// Creates a new [UrlAddress].
  ///
  /// Throws [ArgumentError] if the URL is invalid.
  UrlAddress(super.value) {
    if (!isValid(value)) {
      throw ArgumentError('Invalid URL: $value');
    }
  }

  /// Validates a URL.
  static bool isValid(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Returns the URI representation.
  Uri get uri => Uri.parse(value);
}

/// Value object for money/currency values.
class Money extends Equatable {
  /// Creates a new [Money] instance.
  const Money({
    required this.amount,
    required this.currency,
  });

  /// Creates money with zero amount.
  const Money.zero(this.currency) : amount = 0;

  /// The monetary amount in smallest currency unit (e.g., cents).
  final int amount;

  /// The currency code (e.g., 'USD', 'EUR').
  final String currency;

  /// Returns the amount as a decimal value.
  double get decimalAmount => amount / 100;

  /// Adds two money values.
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Subtracts two money values.
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount - other.amount, currency: currency);
  }

  /// Multiplies money by a factor.
  Money operator *(num factor) {
    return Money(amount: (amount * factor).round(), currency: currency);
  }

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot operate on different currencies');
    }
  }

  @override
  List<Object?> get props => [amount, currency];

  @override
  String toString() => '${decimalAmount.toStringAsFixed(2)} $currency';
}

/// Value object for date ranges.
class DateRange extends Equatable {
  /// Creates a new [DateRange].
  const DateRange({
    required this.start,
    required this.end,
  });

  /// The start date of the range.
  final DateTime start;

  /// The end date of the range.
  final DateTime end;

  /// The duration of the range.
  Duration get duration => end.difference(start);

  /// The number of days in the range.
  int get days => duration.inDays;

  /// Checks if a date is within this range.
  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Checks if this range overlaps with another.
  bool overlaps(DateRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  @override
  List<Object?> get props => [start, end];
}

/// Value object for coordinates.
class GeoCoordinates extends Equatable {
  /// Creates a new [GeoCoordinates].
  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
  });

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees.
  final double longitude;

  /// Calculates the distance to another coordinate in kilometers.
  double distanceTo(GeoCoordinates other) {
    // Haversine formula
    const r = 6371.0; // Earth's radius in km
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(latitude)) *
            _cos(_toRadians(other.latitude)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return r * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorCos(x);
  double _sqrt(double x) => _newtonSqrt(x);
  double _atan2(double y, double x) => _taylorAtan2(y, x);

  double _taylorSin(double x) {
    x = x % (2 * 3.141592653589793);
    var result = x;
    var term = x;
    for (var i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _taylorCos(double x) {
    x = x % (2 * 3.141592653589793);
    var result = 1.0;
    var term = 1.0;
    for (var i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _newtonSqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    var guess = x / 2;
    for (var i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _taylorAtan2(double y, double x) {
    if (x > 0) return _taylorAtan(y / x);
    if (x < 0 && y >= 0) return _taylorAtan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _taylorAtan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  double _taylorAtan(double x) {
    if (x.abs() > 1) {
      return 3.141592653589793 / 2 - _taylorAtan(1 / x);
    }
    var result = x;
    var term = x;
    for (var i = 1; i < 50; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => '($latitude, $longitude)';
}
