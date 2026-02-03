/// Tests for utility functions.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/src/utils/extensions.dart';
import 'package:flutter_forge/src/utils/validators.dart';

void main() {
  group('String Extensions', () {
    test('capitalize works correctly', () {
      expect('hello'.capitalize, equals('Hello'));
      expect('HELLO'.capitalize, equals('HELLO'));
      expect(''.capitalize, equals(''));
    });

    test('titleCase works correctly', () {
      expect('hello world'.titleCase, equals('Hello World'));
      expect('flutter forge'.titleCase, equals('Flutter Forge'));
    });

    test('isValidEmail works correctly', () {
      expect('test@example.com'.isValidEmail, isTrue);
      expect('user.name@domain.org'.isValidEmail, isTrue);
      expect('invalid'.isValidEmail, isFalse);
      expect('@domain.com'.isValidEmail, isFalse);
      expect('test@'.isValidEmail, isFalse);
    });

    test('isNumeric works correctly', () {
      expect('12345'.isNumeric, isTrue);
      expect('123.45'.isNumeric, isFalse);
      expect('abc'.isNumeric, isFalse);
    });

    test('truncate works correctly', () {
      expect('Hello World'.truncate(8), equals('Hello...'));
      expect('Short'.truncate(10), equals('Short'));
    });

    test('toSnakeCase works correctly', () {
      expect('HelloWorld'.toSnakeCase, equals('hello_world'));
      expect('helloWorld'.toSnakeCase, equals('hello_world'));
    });

    test('toCamelCase works correctly', () {
      expect('hello_world'.toCamelCase, equals('helloWorld'));
      expect('hello-world'.toCamelCase, equals('helloWorld'));
    });

    test('toPascalCase works correctly', () {
      expect('hello_world'.toPascalCase, equals('HelloWorld'));
      expect('hello-world'.toPascalCase, equals('HelloWorld'));
    });

    test('nullIfEmpty works correctly', () {
      expect(''.nullIfEmpty, isNull);
      expect('text'.nullIfEmpty, equals('text'));
    });
  });

  group('Nullable String Extensions', () {
    test('isNullOrEmpty works correctly', () {
      expect((null as String?).isNullOrEmpty, isTrue);
      expect(''.isNullOrEmpty, isTrue);
      expect('text'.isNullOrEmpty, isFalse);
    });

    test('orDefault works correctly', () {
      expect((null as String?).orDefault('default'), equals('default'));
      expect('text'.orDefault('default'), equals('text'));
    });
  });

  group('List Extensions', () {
    test('getOrNull works correctly', () {
      final list = [1, 2, 3];
      expect(list.getOrNull(0), equals(1));
      expect(list.getOrNull(5), isNull);
      expect(list.getOrNull(-1), isNull);
    });

    test('firstOrNull works correctly', () {
      expect([1, 2, 3].firstOrNull, equals(1));
      expect(<int>[].firstOrNull, isNull);
    });

    test('lastOrNull works correctly', () {
      expect([1, 2, 3].lastOrNull, equals(3));
      expect(<int>[].lastOrNull, isNull);
    });

    test('separatedBy works correctly', () {
      expect([1, 2, 3].separatedBy(0), equals([1, 0, 2, 0, 3]));
      expect([1].separatedBy(0), equals([1]));
    });

    test('chunked works correctly', () {
      expect([1, 2, 3, 4, 5].chunked(2), equals([[1, 2], [3, 4], [5]]));
      expect([1, 2, 3].chunked(5), equals([[1, 2, 3]]));
    });
  });

  group('Iterable Extensions', () {
    test('mapIndexed works correctly', () {
      final result = ['a', 'b', 'c']
          .mapIndexed((index, element) => '$index:$element')
          .toList();
      expect(result, equals(['0:a', '1:b', '2:c']));
    });

    test('whereIndexed works correctly', () {
      final result = [1, 2, 3, 4, 5]
          .whereIndexed((index, element) => index.isEven)
          .toList();
      expect(result, equals([1, 3, 5]));
    });

    test('groupBy works correctly', () {
      final result = ['one', 'two', 'three']
          .groupBy((s) => s.length);
      expect(result[3], equals(['one', 'two']));
      expect(result[5], equals(['three']));
    });

    test('distinct works correctly', () {
      expect([1, 2, 2, 3, 3, 3].distinct(), equals([1, 2, 3]));
    });
  });

  group('Map Extensions', () {
    test('getOrDefault works correctly', () {
      final map = {'a': 1, 'b': 2};
      expect(map.getOrDefault('a', 0), equals(1));
      expect(map.getOrDefault('c', 0), equals(0));
    });

    test('mapValues works correctly', () {
      final map = {'a': 1, 'b': 2};
      final result = map.mapValues((v) => v * 2);
      expect(result, equals({'a': 2, 'b': 4}));
    });
  });

  group('DateTime Extensions', () {
    test('isSameDay works correctly', () {
      final date1 = DateTime(2024, 6, 15, 10, 30);
      final date2 = DateTime(2024, 6, 15, 18, 45);
      final date3 = DateTime(2024, 6, 16, 10, 30);

      expect(date1.isSameDay(date2), isTrue);
      expect(date1.isSameDay(date3), isFalse);
    });

    test('startOfDay works correctly', () {
      final date = DateTime(2024, 6, 15, 14, 30, 45);
      final start = date.startOfDay;

      expect(start.hour, equals(0));
      expect(start.minute, equals(0));
      expect(start.second, equals(0));
    });

    test('endOfDay works correctly', () {
      final date = DateTime(2024, 6, 15, 14, 30, 45);
      final end = date.endOfDay;

      expect(end.hour, equals(23));
      expect(end.minute, equals(59));
      expect(end.second, equals(59));
    });

    test('daysInMonth works correctly', () {
      expect(DateTime(2024, 2).daysInMonth, equals(29)); // Leap year
      expect(DateTime(2023, 2).daysInMonth, equals(28));
      expect(DateTime(2024, 1).daysInMonth, equals(31));
    });
  });

  group('Duration Extensions', () {
    test('formatted works correctly', () {
      const duration = Duration(hours: 2, minutes: 30, seconds: 45);
      expect(duration.formatted, equals('02:30:45'));
    });

    test('humanReadable works correctly', () {
      expect(const Duration(days: 2).humanReadable, equals('2 days'));
      expect(const Duration(hours: 3).humanReadable, equals('3 hours'));
      expect(const Duration(minutes: 45).humanReadable, equals('45 minutes'));
    });
  });

  group('Validators', () {
    test('required validator works', () {
      final validator = Validators.required();
      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('value'), isNull);
    });

    test('email validator works', () {
      final validator = Validators.email();
      expect(validator('test@example.com'), isNull);
      expect(validator('invalid'), isNotNull);
    });

    test('minLength validator works', () {
      final validator = Validators.minLength(5);
      expect(validator('abc'), isNotNull);
      expect(validator('abcdef'), isNull);
    });

    test('maxLength validator works', () {
      final validator = Validators.maxLength(5);
      expect(validator('abc'), isNull);
      expect(validator('abcdefgh'), isNotNull);
    });

    test('numeric validator works', () {
      final validator = Validators.numeric();
      expect(validator('123'), isNull);
      expect(validator('12.34'), isNull);
      expect(validator('abc'), isNotNull);
    });

    test('minValue validator works', () {
      final validator = Validators.minValue(10);
      expect(validator('5'), isNotNull);
      expect(validator('15'), isNull);
    });

    test('maxValue validator works', () {
      final validator = Validators.maxValue(10);
      expect(validator('5'), isNull);
      expect(validator('15'), isNotNull);
    });

    test('range validator works', () {
      final validator = Validators.range(5, 10);
      expect(validator('3'), isNotNull);
      expect(validator('7'), isNull);
      expect(validator('15'), isNotNull);
    });

    test('password validator works', () {
      final validator = Validators.password();
      expect(validator('weak'), isNotNull);
      expect(validator('StrongPass1'), isNull);
    });

    test('match validator works', () {
      var original = 'password123';
      final validator = Validators.match(() => original);
      expect(validator('password123'), isNull);
      expect(validator('different'), isNotNull);
    });

    test('compose validator works', () {
      final validator = Validators.compose([
        Validators.required(),
        Validators.minLength(5),
        Validators.email(),
      ]);

      expect(validator(''), isNotNull); // Required fails
      expect(validator('ab'), isNotNull); // MinLength fails
      expect(validator('notanemail'), isNotNull); // Email fails
      expect(validator('test@example.com'), isNull); // All pass
    });

    test('ValidatorBuilder fluent API works', () {
      final validator = ValidatorBuilder()
          .required()
          .email()
          .build();

      expect(validator(''), isNotNull);
      expect(validator('invalid'), isNotNull);
      expect(validator('test@example.com'), isNull);
    });
  });
}
