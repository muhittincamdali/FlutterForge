import 'dart:io';

import 'package:flutter_forge/src/cli/generator.dart';
import 'package:flutter_forge/src/cli/names.dart';
import 'package:flutter_forge/src/cli/template.dart';
import 'package:flutter_forge/src/cli/templates/feature_templates.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('render', () {
    test('replaces every placeholder', () {
      expect(render('{{a}}-{{b}}-{{a}}', {'a': '1', 'b': '2'}), '1-2-1');
    });

    test('fails on a placeholder without a value', () {
      expect(() => render('{{missing}}', {}), throwsStateError);
    });

    test('does not expand placeholders inside values', () {
      expect(render('{{a}}', {'a': '{{b}}', 'b': 'x'}), '{{b}}');
    });

    test('leaves Dart interpolation alone', () {
      expect(render(r"'${value.id} $name'", {}), r"'${value.id} $name'");
    });
  });

  group('templates', () {
    final app = appValues(project: 'shop', description: 'A shop.');
    final orders = featureValues(project: 'shop', feature: 'order_items');

    test('every placeholder of the app and feature templates has a value', () {
      expect(() => renderApp(app), returnsNormally);
      expect(() => renderAll(featureTemplates, orders), returnsNormally);
      for (final markers in featureInsertions.values) {
        for (final line in markers.values) {
          expect(() => render(line, orders), returnsNormally);
        }
      }
    });

    test('no rendered file keeps a placeholder', () {
      final files = {...renderApp(app), ...renderAll(featureTemplates, orders)};
      for (final MapEntry(:key, :value) in files.entries) {
        expect(key, isNot(contains('{{')));
        expect(value, isNot(contains('{{')), reason: key);
      }
    });

    test('the feature files follow the domain, data and presentation layout', () {
      expect(renderAll(featureTemplates, orders).keys, [
        'lib/features/order_items/domain/order_item.dart',
        'lib/features/order_items/domain/order_items_repository.dart',
        'lib/features/order_items/data/order_item_json.dart',
        'lib/features/order_items/data/http_order_items_repository.dart',
        'lib/features/order_items/presentation/order_items_controller.dart',
        'lib/features/order_items/presentation/order_items_page.dart',
        'test/features/order_items/data/http_order_items_repository_test.dart',
        'test/features/order_items/presentation/order_items_page_test.dart',
      ]);
    });

    test('the domain layer imports neither Flutter nor HTTP', () {
      final files = renderAll(featureTemplates, orders);
      for (final MapEntry(:key, :value) in files.entries.where((e) => e.key.contains('/domain/'))) {
        expect(value, isNot(contains('package:flutter')), reason: key);
        expect(value, isNot(contains('flutter_forge')), reason: key);
        expect(value, isNot(contains('package:http')), reason: key);
      }
    });

    test('the dependency is the Git release unless a path is given', () {
      expect(renderApp(app)['pubspec.yaml'], contains('ref: $forgeGitRef'));
      final local = renderApp(appValues(project: 'shop', description: 'A shop.', forgePath: '../forge'));
      expect(local['pubspec.yaml'], contains('    path: ../forge\n'));
      final spaced = renderApp(appValues(project: 'shop', description: 'A shop.', forgePath: "C:\\my code\\it's"));
      expect(spaced['pubspec.yaml'], contains("    path: 'C:/my code/it''s'\n"));
    });

    test('featureValues checks the entity and API path it is given', () {
      expect(() => featureValues(project: 'shop', feature: 'texts'), throwsA(isA<InvalidInput>()));
      expect(featureValues(project: 'shop', feature: 'texts', entity: 'Note')['entity'], 'Note');
      expect(() => featureValues(project: 'shop', feature: 'a', apiPath: '/../x'), throwsA(isA<InvalidInput>()));
    });
  });

  group('writeFiles', () {
    late Directory root;
    setUp(() => root = Directory.systemTemp.createTempSync('forge_write_'));
    tearDown(() => root.deleteSync(recursive: true));

    test('creates folders and returns the relative paths', () {
      final written = writeFiles(root.path, {'lib/a/b.dart': 'x', 'c.txt': 'y'});
      expect(written, ['lib/a/b.dart', 'c.txt']);
      expect(File(p.join(root.path, 'lib/a/b.dart')).readAsStringSync(), 'x');
    });

    test('refuses a path outside the project and writes nothing', () {
      expect(() => writeFiles(root.path, {'ok.txt': 'x', '../escape.txt': 'y'}), throwsA(isA<InvalidInput>()));
      expect(root.listSync(), isEmpty);
      expect(File(p.join(root.parent.path, 'escape.txt')).existsSync(), isFalse);
    });

    test('refuses an absolute path', () {
      final outside = p.join(Directory.systemTemp.path, 'forge_absolute.txt');
      expect(() => writeFiles(root.path, {outside: 'x'}), throwsA(isA<InvalidInput>()));
      expect(File(outside).existsSync(), isFalse);
    });

    test('does not overwrite an existing file unless asked', () {
      File(p.join(root.path, 'a.txt')).writeAsStringSync('mine');
      expect(() => writeFiles(root.path, {'a.txt': 'theirs', 'b.txt': 'new'}), throwsA(isA<InvalidInput>()));
      expect(File(p.join(root.path, 'a.txt')).readAsStringSync(), 'mine');
      expect(File(p.join(root.path, 'b.txt')).existsSync(), isFalse);

      writeFiles(root.path, {'a.txt': 'theirs'}, overwrite: true);
      expect(File(p.join(root.path, 'a.txt')).readAsStringSync(), 'theirs');
    });
  });

  group('insertAboveMarker', () {
    const content = 'a\n    // marker\nb';

    test('inserts with the indentation of the marker', () {
      expect(insertAboveMarker(content, '// marker', 'line();'), 'a\n    line();\n    // marker\nb');
    });

    test('is idempotent', () {
      final once = insertAboveMarker(content, '// marker', 'line();')!;
      expect(insertAboveMarker(once, '// marker', 'line();'), once);
    });

    test('returns null without the marker', () {
      expect(insertAboveMarker('a\nb', '// marker', 'line();'), isNull);
    });
  });

  group('insertImport', () {
    test('goes after the last import', () {
      expect(
        insertImport("import 'a.dart';\nimport 'b.dart';\n\nvoid main() {}", "import 'c.dart';"),
        "import 'a.dart';\nimport 'b.dart';\nimport 'c.dart';\n\nvoid main() {}",
      );
    });

    test('is idempotent and returns null without imports', () {
      expect(insertImport("import 'a.dart';", "import 'a.dart';"), "import 'a.dart';");
      expect(insertImport('void main() {}', "import 'a.dart';"), isNull);
    });
  });

  group('platform patches', () {
    const manifest =
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <application\n        android:label="shop"\n';

    test('the Android manifest gets INTERNET and the app title', () {
      final patched = patchAndroidManifest(manifest, project: 'shop', title: 'Shop');
      expect(patched, contains('    <uses-permission android:name="android.permission.INTERNET" />\n    <application'));
      expect(patched, contains('android:label="Shop"'));
      expect(
        patchAndroidManifest(patched, project: 'shop', title: 'Shop'),
        patched,
        reason: 'idempotent',
      );
    });

    test('the macOS entitlements get the network client key once', () {
      const plist =
          '<plist version="1.0">\n<dict>\n\t<key>com.apple.security.app-sandbox</key>\n\t<true/>\n</dict>\n</plist>\n';
      final patched = patchMacosEntitlements(plist);
      expect(patched, contains('<key>com.apple.security.network.client</key>\n\t<true/>\n</dict>'));
      expect(patchMacosEntitlements(patched), patched);
    });

    test('patchPlatformFiles changes only the files that exist', () {
      final root = Directory.systemTemp.createTempSync('forge_patch_');
      addTearDown(() => root.deleteSync(recursive: true));
      File(p.join(root.path, 'android/app/src/main/AndroidManifest.xml'))
        ..createSync(recursive: true)
        ..writeAsStringSync(manifest);
      expect(patchPlatformFiles(root.path, project: 'shop', title: 'Shop'), [
        'android/app/src/main/AndroidManifest.xml',
      ]);
      expect(patchPlatformFiles(root.path, project: 'shop', title: 'Shop'), isEmpty);
    });
  });
}
