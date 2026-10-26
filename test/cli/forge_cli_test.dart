import 'dart:io';

import 'package:flutter_forge/src/cli/forge_cli.dart';
import 'package:flutter_forge/src/cli/generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final class Call {
  Call(this.executable, this.arguments, this.workingDirectory);

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;

  @override
  String toString() => '$executable ${arguments.join(' ')}';
}

/// Records every program `forge` starts and answers with [exitCodeFor].
final class FakeTools {
  FakeTools({this.exitCodeFor, this.missing = const {}});

  final int Function(Call call)? exitCodeFor;
  final Set<String> missing;
  final List<Call> calls = [];

  Future<ProcessResult> run(String executable, List<String> arguments, {String? workingDirectory}) async {
    if (missing.contains(executable)) throw ProcessException(executable, arguments, 'not found', 2);
    final call = Call(executable, arguments, workingDirectory);
    calls.add(call);
    // Like flutter create, leave the starter test behind so forge can delete it.
    if (arguments.firstOrNull == 'create') {
      File(p.join(arguments.last, 'test', 'widget_test.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('starter');
    }
    return ProcessResult(0, exitCodeFor?.call(call) ?? 0, 'out', 'err');
  }
}

void main() {
  late Directory work;
  late FakeTools tools;
  late StringBuffer out;
  late StringBuffer err;

  setUp(() {
    work = Directory.systemTemp.createTempSync('forge_cli_');
    tools = FakeTools();
    out = StringBuffer();
    err = StringBuffer();
  });
  tearDown(() => work.deleteSync(recursive: true));

  Future<int> forge(List<String> arguments, {FakeTools? with_}) => runForge(
    arguments,
    environment: ForgeEnvironment(workingDirectory: work.path, run: (with_ ?? tools).run, out: out, err: err),
  );

  String read(String relative) => File(p.join(work.path, relative)).readAsStringSync();
  bool exists(String relative) => File(p.join(work.path, relative)).existsSync();

  test('--version prints the package version', () async {
    expect(await forge(['--version']), ExitCodes.ok);
    expect(out.toString().trim(), 'forge $forgeVersion');
  });

  test('the version matches pubspec.yaml and the Git ref new apps use', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(RegExp(r'^version: (.+)$', multiLine: true).firstMatch(pubspec)!.group(1), forgeVersion);
    expect(forgeGitRef, 'v$forgeVersion');
  });

  test('an unknown command is a usage error', () async {
    expect(await forge(['deploy']), ExitCodes.usage);
    expect(err.toString(), contains('Could not find a command named "deploy"'));
  });

  group('create', () {
    test('runs flutter create, writes the app, formats it and gets packages', () async {
      final code = await forge(['create', 'shop', '--org', 'com.acme', '--description', 'A shop.']);
      expect(code, ExitCodes.ok, reason: err.toString());

      final target = p.join(work.path, 'shop');
      expect(tools.calls.map((c) => c.toString()), [
        'flutter create --org com.acme --project-name shop --description A shop. --platforms android,ios --no-pub $target',
        'dart format lib test',
        'flutter pub get',
      ]);
      expect(tools.calls[1].workingDirectory, target);
      expect(tools.calls[2].workingDirectory, target);

      expect(exists('shop/test/widget_test.dart'), isFalse, reason: 'the flutter create starter test is removed');
      expect(read('shop/pubspec.yaml'), contains('name: shop\n'));
      expect(read('shop/pubspec.yaml'), contains('description: "A shop."'));
      expect(read('shop/pubspec.yaml'), contains('url: $forgeGitUrl'));
      expect(read('shop/lib/main.dart'), contains("import 'package:shop/app/app.dart';"));
      expect(exists('shop/lib/features/todos/presentation/todos_page.dart'), isTrue);
      expect(exists('shop/test/features/todos/presentation/todos_page_test.dart'), isTrue);
      expect(out.toString(), contains('cd shop'));
    });

    test('passes the chosen platforms and output directory', () async {
      await forge(['create', 'shop', '-o', 'apps/shop', '--platforms', 'ios,web']);
      final create = tools.calls.first.arguments;
      expect(create[create.indexOf('--platforms') + 1], 'ios,web');
      expect(create.last, p.join(work.path, 'apps', 'shop'));
    });

    test('--forge-path writes a path dependency relative to the app', () async {
      Directory(p.join(work.path, 'forge')).createSync();
      await forge(['create', 'shop', '--forge-path', 'forge', '--no-flutter-create', '--no-pub', '--no-format']);
      expect(read('shop/pubspec.yaml'), contains('  flutter_forge:\n    path: ../forge\n'));
      expect(tools.calls, isEmpty);
    });

    test('an invalid name is refused before anything runs', () async {
      for (final name in ['Shop', 'my-shop', 'http', 'class', '../shop']) {
        expect(await forge(['create', name]), ExitCodes.dataError, reason: name);
      }
      expect(tools.calls, isEmpty);
      expect(work.listSync(), isEmpty);
    });

    test('an invalid org or description is refused', () async {
      expect(await forge(['create', 'shop', '--org', 'acme']), ExitCodes.dataError);
      expect(await forge(['create', 'shop', '--description', r'$(rm -rf ~)']), ExitCodes.dataError);
      expect(tools.calls, isEmpty);
    });

    test('an output directory with shell metacharacters is refused', () async {
      expect(await forge(['create', 'shop', '-o', 'a&calc']), ExitCodes.dataError);
      expect(tools.calls, isEmpty);
    });

    test('a folder that is not empty is left alone', () async {
      File(p.join(work.path, 'shop', 'notes.txt'))
        ..createSync(recursive: true)
        ..writeAsStringSync('keep me');
      expect(await forge(['create', 'shop']), ExitCodes.cannotCreate);
      expect(read('shop/notes.txt'), 'keep me');
      expect(tools.calls, isEmpty);
    });

    test('an empty folder is used', () async {
      Directory(p.join(work.path, 'shop')).createSync();
      expect(await forge(['create', 'shop', '--no-flutter-create', '--no-pub']), ExitCodes.ok);
      expect(exists('shop/lib/main.dart'), isTrue);
    });

    test('a missing flutter is reported with install instructions', () async {
      final code = await forge(['create', 'shop'], with_: FakeTools(missing: {'flutter'}));
      expect(code, ExitCodes.unavailable);
      expect(err.toString(), contains('docs.flutter.dev'));
    });

    test('a failing flutter create stops before writing the app', () async {
      final failing = FakeTools(exitCodeFor: (call) => call.arguments.first == 'create' ? 1 : 0);
      expect(await forge(['create', 'shop'], with_: failing), ExitCodes.failure);
      expect(exists('shop/lib/main.dart'), isFalse);
      expect(err.toString(), contains('failed with exit code 1'));
    });

    test('needs exactly one name', () async {
      expect(await forge(['create']), ExitCodes.usage);
      expect(await forge(['create', 'a', 'b']), ExitCodes.usage);
    });
  });

  group('feature', () {
    setUp(() async {
      await forge(['create', 'shop', '--no-flutter-create', '--no-pub', '--no-format']);
      tools.calls.clear();
    });

    Future<int> feature(List<String> arguments) => forge(['feature', ...arguments, '-C', 'shop']);

    test('writes the layers and tests, adds the route and the home entry', () async {
      expect(await feature(['orders']), ExitCodes.ok, reason: err.toString());

      expect(exists('shop/lib/features/orders/domain/order.dart'), isTrue);
      expect(exists('shop/lib/features/orders/data/http_orders_repository.dart'), isTrue);
      expect(exists('shop/test/features/orders/presentation/orders_page_test.dart'), isTrue);

      final router = read('shop/lib/app/router.dart');
      expect(router, contains("import 'package:shop/features/orders/presentation/orders_page.dart';"));
      expect(router, contains("      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),"));
      expect(router.indexOf("'/orders'"), lessThan(router.indexOf('// forge:routes')));
      expect(read('shop/lib/app/destinations.dart'), contains("  Destination(title: 'Orders', path: '/orders'),"));

      expect(tools.calls.single.executable, 'dart');
      expect(tools.calls.single.arguments, containsAll(['format', 'lib/app/router.dart', 'lib/app/destinations.dart']));
      expect(out.toString(), contains('reads a list of Order from /orders'));
    });

    test('--entity and --api-path change the class and endpoint', () async {
      await feature(['news', '--entity', 'Article', '--api-path', '/v2/articles']);
      expect(exists('shop/lib/features/news/domain/article.dart'), isTrue);
      expect(read('shop/lib/features/news/data/http_news_repository.dart'), contains("'/v2/articles'"));
    });

    test('the same feature twice is refused and the first one is kept', () async {
      await feature(['orders']);
      final router = read('shop/lib/app/router.dart');
      expect(await feature(['orders']), ExitCodes.cannotCreate);
      expect(read('shop/lib/app/router.dart'), router);
    });

    test('a file of the feature that already exists stops it before any write', () async {
      File(p.join(work.path, 'shop/test/features/orders/data/http_orders_repository_test.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('mine');
      expect(await feature(['orders']), ExitCodes.dataError);
      expect(exists('shop/lib/features/orders/domain/order.dart'), isFalse);
      expect(read('shop/lib/app/router.dart'), isNot(contains('orders')));
    });

    test('without markers it prints the lines to add by hand', () async {
      File(p.join(work.path, 'shop/lib/app/destinations.dart')).writeAsStringSync('const destinations = [];\n');
      expect(await feature(['orders']), ExitCodes.ok);
      expect(out.toString(), contains("lib/app/destinations.dart: Destination(title: 'Orders', path: '/orders'),"));
      expect(read('shop/lib/app/destinations.dart'), 'const destinations = [];\n');
    });

    test('a failing dart format does not undo the feature', () async {
      final failing = FakeTools(exitCodeFor: (_) => 1);
      final code = await forge(['feature', 'orders', '-C', 'shop'], with_: failing);
      expect(code, ExitCodes.ok);
      expect(err.toString(), contains('formatting failed'));
      expect(exists('shop/lib/features/orders/domain/order.dart'), isTrue);
    });

    test('outside an app it explains what to do', () async {
      expect(await forge(['feature', 'orders']), ExitCodes.usage);
      expect(err.toString(), contains('has no pubspec.yaml'));
    });

    test('invalid names are refused', () async {
      for (final name in ['Orders', 'core', '../orders', 'or ders']) {
        expect(await feature([name]), ExitCodes.dataError, reason: name);
      }
      expect(await feature(['texts']), ExitCodes.dataError, reason: 'Text clashes with the Flutter widget');
      expect(Directory(p.join(work.path, 'shop/lib/features/texts')).existsSync(), isFalse);
    });
  });
}
