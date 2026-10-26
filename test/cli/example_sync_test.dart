import 'dart:io';

import 'package:flutter_forge/src/cli/forge_cli.dart';
import 'package:flutter_forge/src/cli/generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// The example app is the output of `forge create`, committed so that CI can
/// analyze and test it. This test generates the app again, with the real
/// `dart format`, and compares every generated file with the committed one.
void main() {
  test('example/ is exactly what forge create generates', () async {
    final work = Directory.systemTemp.createTempSync('forge_example_');
    addTearDown(() => work.deleteSync(recursive: true));

    final code = await runForge(
      [
        'create',
        'forge_example',
        '--output-directory',
        p.join(work.path, 'example'),
        '--forge-path',
        Directory.current.path,
        '--org',
        'dev.flutterforge',
        '--description',
        'The FlutterForge example app: a todo list read from a JSON API.',
        '--no-flutter-create',
        '--no-pub',
      ],
      environment: ForgeEnvironment(
        workingDirectory: work.path,
        run: (executable, arguments, {workingDirectory}) =>
            Process.run(executable, arguments, workingDirectory: workingDirectory, runInShell: Platform.isWindows),
        out: StringBuffer(),
        err: stderr,
      ),
    );
    expect(code, ExitCodes.ok);

    final generated = renderApp(appValues(project: 'forge_example', description: 'unused'));
    for (final relative in generated.keys.where((path) => path != 'pubspec.yaml')) {
      final expected = File(p.join(work.path, 'example', relative)).readAsStringSync();
      final committed = File(p.join('example', relative));
      expect(committed.existsSync(), isTrue, reason: 'example/$relative is missing');
      expect(
        committed.readAsStringSync(),
        expected,
        reason: 'example/$relative differs; run scripts/regenerate_example.sh',
      );
    }
    final pubspec = File(p.join('example', 'pubspec.yaml')).readAsStringSync();
    expect(pubspec, contains('  flutter_forge:\n    path: ..\n'));
  });
}
