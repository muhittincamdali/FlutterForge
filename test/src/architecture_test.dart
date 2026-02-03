/// Tests for architecture components.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/src/architecture/clean_architecture/domain/entity.dart';
import 'package:flutter_forge/src/architecture/clean_architecture/domain/use_case.dart';
import 'package:flutter_forge/src/architecture/clean_architecture/presentation/state.dart';
import 'package:flutter_forge/src/architecture/mvvm/model.dart';

void main() {
  group('Entity Tests', () {
    test('EmailAddress validates correctly', () {
      expect(EmailAddress.isValid('test@example.com'), isTrue);
      expect(EmailAddress.isValid('invalid'), isFalse);
      expect(EmailAddress.isValid('test@'), isFalse);
      expect(EmailAddress.isValid('@example.com'), isFalse);
    });

    test('EmailAddress creates from valid email', () {
      final email = EmailAddress('test@example.com');
      expect(email.value, equals('test@example.com'));
    });

    test('EmailAddress throws on invalid email', () {
      expect(() => EmailAddress('invalid'), throwsArgumentError);
    });

    test('PhoneNumber validates correctly', () {
      expect(PhoneNumber.isValid('+1234567890'), isTrue);
      expect(PhoneNumber.isValid('1234567890'), isTrue);
      expect(PhoneNumber.isValid('123'), isFalse);
    });

    test('Money arithmetic works correctly', () {
      const money1 = Money(amount: 1000, currency: 'USD');
      const money2 = Money(amount: 500, currency: 'USD');

      final sum = money1 + money2;
      expect(sum.amount, equals(1500));

      final diff = money1 - money2;
      expect(diff.amount, equals(500));

      final product = money1 * 2;
      expect(product.amount, equals(2000));
    });

    test('Money throws on different currencies', () {
      const usd = Money(amount: 100, currency: 'USD');
      const eur = Money(amount: 100, currency: 'EUR');

      expect(() => usd + eur, throwsArgumentError);
    });

    test('DateRange contains date correctly', () {
      final range = DateRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
      );

      expect(range.contains(DateTime(2024, 6, 15)), isTrue);
      expect(range.contains(DateTime(2023, 6, 15)), isFalse);
      expect(range.contains(DateTime(2025, 6, 15)), isFalse);
    });

    test('DateRange overlaps detection works', () {
      final range1 = DateRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 6, 30),
      );
      final range2 = DateRange(
        start: DateTime(2024, 4, 1),
        end: DateTime(2024, 12, 31),
      );
      final range3 = DateRange(
        start: DateTime(2024, 7, 1),
        end: DateTime(2024, 12, 31),
      );

      expect(range1.overlaps(range2), isTrue);
      expect(range1.overlaps(range3), isFalse);
    });
  });

  group('UseCase Tests', () {
    test('NoParams equals correctly', () {
      const params1 = NoParams();
      const params2 = NoParams();

      expect(params1, equals(params2));
    });

    test('PaginatedParams calculates offset correctly', () {
      const params = PaginatedParams(page: 3, pageSize: 20);
      expect(params.offset, equals(40));
    });

    test('IdParams equals correctly', () {
      const params1 = IdParams('123');
      const params2 = IdParams('123');
      const params3 = IdParams('456');

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });
  });

  group('State Tests', () {
    test('AsyncValue initial state is correct', () {
      const state = AsyncValue<int>.initial();
      expect(state.isInitial, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
    });

    test('AsyncValue loading state is correct', () {
      const state = AsyncValue<int>.loading();
      expect(state.isLoading, isTrue);
      expect(state.isInitial, isFalse);
    });

    test('AsyncValue success state is correct', () {
      const state = AsyncValue<int>.success(42);
      expect(state.isSuccess, isTrue);
      expect(state.hasData, isTrue);
      expect(state.data, equals(42));
    });

    test('AsyncValue failure state is correct', () {
      final state = AsyncValue<int>.failure(Exception('Test error'));
      expect(state.isFailure, isTrue);
      expect(state.hasError, isTrue);
    });

    test('AsyncValue when handles all cases', () {
      const successState = AsyncValue<int>.success(42);
      final result = successState.when(
        initial: () => 'initial',
        loading: () => 'loading',
        success: (data) => 'success: $data',
        failure: (error, stack) => 'error',
      );
      expect(result, equals('success: 42'));
    });

    test('PaginatedState appendItems works correctly', () {
      const state = PaginatedState<String>(
        items: ['a', 'b'],
        page: 1,
      );
      final newState = state.appendItems(['c', 'd']);

      expect(newState.items, equals(['a', 'b', 'c', 'd']));
      expect(newState.page, equals(2));
    });

    test('FormState tracks dirty state correctly', () {
      const state = FormState<Map<String, String>>(
        data: {'name': 'John'},
        isDirty: false,
      );

      final dirtyState = state.copyWith(isDirty: true);
      expect(dirtyState.isDirty, isTrue);
    });

    test('SelectionState toggle works correctly', () {
      const state = SelectionState<String>(
        items: ['a', 'b', 'c'],
        selectedIds: {'a'},
      );

      final toggled = state.toggleSelection('b');
      expect(toggled.selectedIds, containsAll(['a', 'b']));

      final toggledAgain = toggled.toggleSelection('a');
      expect(toggledAgain.selectedIds, equals({'b'}));
    });
  });

  group('Model Tests', () {
    test('ValidationBuilder required validation', () {
      final result = ValidationBuilder()
          .required(null, 'name')
          .build();

      expect(result.isValid, isFalse);
      expect(result.errors['name'], isNotNull);
    });

    test('ValidationBuilder email validation', () {
      final validResult = ValidationBuilder()
          .email('test@example.com', 'email')
          .build();
      expect(validResult.isValid, isTrue);

      final invalidResult = ValidationBuilder()
          .email('invalid', 'email')
          .build();
      expect(invalidResult.isValid, isFalse);
    });

    test('ValidationBuilder chained validation', () {
      final result = ValidationBuilder()
          .required('test', 'field')
          .minLength('test', 5, 'field')
          .build();

      expect(result.isValid, isFalse);
      expect(result.getError('field'), contains('at least 5'));
    });

    test('ValidationResult merge combines errors', () {
      const result1 = ValidationResult(
        isValid: false,
        errors: {'field1': 'Error 1'},
      );
      const result2 = ValidationResult(
        isValid: false,
        errors: {'field2': 'Error 2'},
      );

      final merged = result1.merge(result2);
      expect(merged.isValid, isFalse);
      expect(merged.errors.length, equals(2));
    });

    test('ModelResult success case', () {
      final result = ModelResult<int>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(42));
    });

    test('ModelResult failure case', () {
      final result = ModelResult<int>.failure(Exception('Error'));
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test('ModelResult map transforms data', () {
      final result = ModelResult<int>.success(10);
      final mapped = result.map((data) => data * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.data, equals(20));
    });

    test('ModelResult fold handles both cases', () {
      final success = ModelResult<int>.success(42);
      final failure = ModelResult<int>.failure(Exception('Error'));

      final successValue = success.fold(
        onSuccess: (data) => data,
        onFailure: (error, stack) => -1,
      );
      expect(successValue, equals(42));

      final failureValue = failure.fold(
        onSuccess: (data) => data,
        onFailure: (error, stack) => -1,
      );
      expect(failureValue, equals(-1));
    });
  });
}
