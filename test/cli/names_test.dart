import 'dart:math' as math;

import 'package:flutter_forge/src/cli/generator.dart';
import 'package:flutter_forge/src/cli/names.dart';
import 'package:test/test.dart';

void main() {
  group('checkProjectName', () {
    test('accepts Dart package names', () {
      for (final name in ['my_app', 'a', 'app2', 'shop_v2_admin']) {
        expect(checkProjectName(name), name);
      }
    });

    test('rejects names Dart or pub would refuse', () {
      for (final name in [
        '',
        'MyApp',
        'my-app',
        '2app',
        '_app',
        'app_',
        'my__app',
        'my app',
        '../escape',
        'a/b',
        'ünicode',
        'class',
        'import',
        'a' * 65,
      ]) {
        expect(() => checkProjectName(name), throwsA(isA<InvalidInput>()), reason: name);
      }
    });

    test('rejects names of the packages the app depends on', () {
      for (final name in reservedPackageNames) {
        expect(() => checkProjectName(name), throwsA(isA<InvalidInput>()), reason: name);
      }
    });

    test('shows control characters in an invalid name as ?', () {
      try {
        checkProjectName('bad\u001b[31mname');
        fail('expected InvalidInput');
      } on InvalidInput catch (error) {
        expect(error.message, contains('bad?[31mname'));
        expect(error.message, isNot(contains('\u001b')));
      }
    });
  });

  group('checkFeatureName', () {
    test('rejects the folders the app uses itself and Flutter page classes', () {
      for (final name in ['app', 'core', 'home', 'material', 'cupertino']) {
        expect(() => checkFeatureName(name), throwsA(isA<InvalidInput>()), reason: name);
      }
      expect(checkFeatureName('orders'), 'orders');
    });
  });

  group('checkEntityName', () {
    test('accepts PascalCase class names', () {
      expect(checkEntityName('Order'), 'Order');
      expect(checkEntityName('OrderItem2'), 'OrderItem2');
    });

    test('rejects other spellings and types the generated code imports', () {
      for (final name in ['order', 'Order_Item', 'Order-Item', '', 'Text', 'Icon', 'String', 'Provider', 'GoRoute']) {
        expect(() => checkEntityName(name), throwsA(isA<InvalidInput>()), reason: name);
      }
    });
  });

  group('checkOrganization', () {
    test('accepts reverse domain names', () {
      expect(checkOrganization('com.example'), 'com.example');
      expect(checkOrganization('dev.flutter_forge.apps'), 'dev.flutter_forge.apps');
    });

    test('rejects single labels, bad characters and keywords', () {
      for (final org in [
        'example',
        'com.',
        '.com',
        'com..example',
        'com.1example',
        'com.ex-ample',
        'com.new',
        'a.b c',
      ]) {
        expect(() => checkOrganization(org), throwsA(isA<InvalidInput>()), reason: org);
      }
    });
  });

  group('checkDescription', () {
    test('trims and accepts plain sentences', () {
      expect(checkDescription('  A shop app: orders, invoices (beta).  '), 'A shop app: orders, invoices (beta).');
      expect(checkDescription("Ayşe's shop"), "Ayşe's shop");
    });

    test('rejects text that could break YAML or a shell', () {
      for (final text in [
        '',
        '   ',
        'a "quote"',
        r'back\slash',
        r'$HOME',
        '`id`',
        'a & b',
        'a | b',
        'a > b',
        '100%',
        'line\nbreak',
        'x' * 201,
      ]) {
        expect(() => checkDescription(text), throwsA(isA<InvalidInput>()), reason: text);
      }
    });
  });

  group('checkApiPath', () {
    test('accepts lower-case paths', () {
      expect(checkApiPath('/orders'), '/orders');
      expect(checkApiPath('/v2/order-items'), '/v2/order-items');
    });

    test('rejects everything else', () {
      for (final path in ['orders', '/', '/Orders', '/a//b', '/a/', '/a?b=1', '/a/../b', '/a b', "/a'b"]) {
        expect(() => checkApiPath(path), throwsA(isA<InvalidInput>()), reason: path);
      }
    });
  });

  group('case conversions', () {
    test('convert snake case', () {
      expect(pascalCase('order_items'), 'OrderItems');
      expect(camelCase('order_items'), 'orderItems');
      expect(titleCase('order_items'), 'Order items');
      expect(kebabCase('order_items'), 'order-items');
      expect(pascalCase('v2_api'), 'V2Api');
    });

    test('snakeCaseOf reverses PascalCase', () {
      expect(snakeCaseOf('Order'), 'order');
      expect(snakeCaseOf('OrderItem'), 'order_item');
      expect(snakeCaseOf('HTTPRequest'), 'http_request');
      expect(snakeCaseOf('Item2Box'), 'item2_box');
    });

    test('singularEntity handles common plurals and leaves the rest', () {
      expect(singularEntity('todos'), 'Todo');
      expect(singularEntity('order_items'), 'OrderItem');
      expect(singularEntity('categories'), 'Category');
      expect(singularEntity('boxes'), 'Box');
      expect(singularEntity('matches'), 'Match');
      expect(singularEntity('addresses'), 'Address');
      expect(singularEntity('status'), 'Status');
      expect(singularEntity('news'), 'News');
      expect(singularEntity('analysis'), 'Analysis');
      expect(singularEntity('inventory'), 'Inventory');
    });
  });

  test('random input only ever passes or fails with InvalidInput', () {
    final random = math.Random(42);
    const alphabet = 'abcXYZ019_-./\\ \$"\'`&|<>^%\n\r\t\u0000é界🙂:;=';
    for (var i = 0; i < 5000; i++) {
      final text = String.fromCharCodes([
        for (var j = 0; j < random.nextInt(90); j++) alphabet.codeUnitAt(random.nextInt(alphabet.length)),
      ]);
      for (final check in [
        checkProjectName,
        checkFeatureName,
        checkEntityName,
        checkOrganization,
        checkDescription,
        checkApiPath,
      ]) {
        try {
          check(text);
        } on InvalidInput catch (error) {
          expect(error.message, isNot(contains('\u0000')));
        }
      }
    }
  });
}
