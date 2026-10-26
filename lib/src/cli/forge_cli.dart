import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'generator.dart';
import 'names.dart';
import 'template.dart';
import 'templates/feature_templates.dart';

/// The version printed by `forge --version`.
const String forgeVersion = '2.0.0';

/// Exit codes of the `forge` command (BSD `sysexits.h`).
abstract final class ExitCodes {
  /// Success.
  static const int ok = 0;

  /// A command failed, for example `flutter create`.
  static const int failure = 1;

  /// The command line was wrong.
  static const int usage = 64;

  /// A name or option had an invalid value.
  static const int dataError = 65;

  /// A program `forge` needs, such as `flutter`, is missing.
  static const int unavailable = 69;

  /// The output already exists.
  static const int cannotCreate = 73;
}

/// Runs a program and returns its result.
typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments, {String? workingDirectory});

/// What `forge` reads from and writes to, replaceable in tests.
final class ForgeEnvironment {
  /// Creates an environment.
  ForgeEnvironment({required this.workingDirectory, required this.run, required this.out, required this.err});

  /// The real environment: the current directory, `Process.run`, stdout and
  /// stderr.
  factory ForgeEnvironment.system() => ForgeEnvironment(
    workingDirectory: Directory.current.path,
    run: (executable, arguments, {workingDirectory}) => Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      // flutter and dart are batch files on Windows.
      runInShell: Platform.isWindows,
    ),
    out: stdout,
    err: stderr,
  );

  /// The directory relative paths are resolved against.
  final String workingDirectory;

  /// Runs `flutter` and `dart`.
  final ProcessRunner run;

  /// Normal output.
  final StringSink out;

  /// Error output.
  final StringSink err;
}

final class _Failure implements Exception {
  const _Failure(this.message, this.exitCode);
  final String message;
  final int exitCode;
}

/// Runs `forge` with [arguments] and returns the exit code.
Future<int> runForge(List<String> arguments, {ForgeEnvironment? environment}) async {
  final env = environment ?? ForgeEnvironment.system();
  final runner = CommandRunner<int>('forge', 'Creates Flutter apps and features wired to FlutterForge.')
    ..argParser.addFlag('version', negatable: false, help: 'Print the version.')
    ..addCommand(_CreateCommand(env))
    ..addCommand(_FeatureCommand(env));
  try {
    final parsed = runner.parse(arguments);
    if (parsed['version'] == true) {
      env.out.writeln('forge $forgeVersion');
      return ExitCodes.ok;
    }
    return await runner.runCommand(parsed) ?? ExitCodes.ok;
  } on UsageException catch (error) {
    env.err
      ..writeln(error.message)
      ..writeln()
      ..writeln(error.usage);
    return ExitCodes.usage;
  } on InvalidInput catch (error) {
    env.err.writeln(error.message);
    return ExitCodes.dataError;
  } on _Failure catch (error) {
    env.err.writeln(error.message);
    return error.exitCode;
  }
}

Future<void> _runTool(ForgeEnvironment env, String tool, List<String> arguments, String directory) async {
  final ProcessResult result;
  try {
    result = await env.run(tool, arguments, workingDirectory: directory);
  } on ProcessException {
    throw _Failure(
      '`$tool` was not found. Install Flutter (https://docs.flutter.dev/get-started/install) '
      'and make sure `$tool` is on your PATH.',
      ExitCodes.unavailable,
    );
  }
  if (result.exitCode != 0) {
    throw _Failure(
      '`$tool ${arguments.join(' ')}` failed with exit code ${result.exitCode}.\n${result.stderr}${result.stdout}',
      ExitCodes.failure,
    );
  }
}

const List<String> _platforms = ['android', 'ios', 'web', 'macos', 'windows', 'linux'];

final class _CreateCommand extends Command<int> {
  _CreateCommand(this.env) {
    argParser
      ..addOption('org', defaultsTo: 'com.example', help: 'Reverse domain used for the app id.')
      ..addOption('description', defaultsTo: 'A Flutter app created with FlutterForge.')
      ..addOption(
        'output-directory',
        abbr: 'o',
        help: 'Where to create the app. Defaults to a folder named after the project.',
      )
      ..addMultiOption('platforms', defaultsTo: ['android', 'ios'], allowed: _platforms)
      ..addOption(
        'forge-path',
        help: 'Depend on a local FlutterForge checkout instead of the Git release (for FlutterForge development).',
      )
      ..addFlag('flutter-create', defaultsTo: true, help: 'Run `flutter create` for the platform folders.')
      ..addFlag('format', defaultsTo: true, help: 'Run `dart format` on the new app.')
      ..addFlag('pub', defaultsTo: true, help: 'Run `flutter pub get` afterwards.');
  }

  final ForgeEnvironment env;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a Flutter app with a feature-first layout, Riverpod, go_router and ForgeClient.';

  @override
  String get invocation => 'forge create <project_name>';

  @override
  Future<int> run() async {
    final args = argResults!;
    if (args.rest.length != 1) usageException('Give exactly one project name, such as my_app.');
    final project = checkProjectName(args.rest.single);
    final org = checkOrganization(args.option('org')!);
    final description = checkDescription(args.option('description')!);
    final directory = p.normalize(p.absolute(env.workingDirectory, args.option('output-directory') ?? project));
    // The path is passed to flutter, which runs through cmd.exe on Windows.
    if (RegExp(r'[\x00-\x1F"&|<>^%]').hasMatch(directory)) {
      throw const InvalidInput('The output directory must not contain ", &, |, <, >, ^, % or control characters.');
    }
    final target = Directory(directory);
    if (target.existsSync() && target.listSync().isNotEmpty) {
      throw _Failure('$directory already exists and is not empty.', ExitCodes.cannotCreate);
    }

    final forgePath = args.option('forge-path');
    final relativeForge = forgePath == null
        ? null
        : p.relative(p.normalize(p.absolute(env.workingDirectory, forgePath)), from: directory);

    if (args.flag('flutter-create')) {
      env.out.writeln('Running flutter create…');
      await _runTool(env, 'flutter', [
        'create',
        '--org',
        org,
        '--project-name',
        project,
        '--description',
        description,
        '--platforms',
        args.multiOption('platforms').join(','),
        '--no-pub',
        directory,
      ], env.workingDirectory);
      final starterTest = File(p.join(directory, 'test', 'widget_test.dart'));
      if (starterTest.existsSync()) starterTest.deleteSync();
      patchPlatformFiles(directory, project: project, title: titleCase(project));
    } else {
      target.createSync(recursive: true);
    }

    final files = renderApp(appValues(project: project, description: description, forgePath: relativeForge));
    final written = writeFiles(directory, files, overwrite: true);

    if (args.flag('format')) {
      await _runTool(env, 'dart', ['format', 'lib', 'test'], directory);
    }
    if (args.flag('pub')) {
      env.out.writeln('Running flutter pub get…');
      await _runTool(env, 'flutter', ['pub', 'get'], directory);
    }

    final shown = p.relative(directory, from: env.workingDirectory);
    env.out
      ..writeln('Created $project in $shown (${written.length} files from FlutterForge).')
      ..writeln()
      ..writeln('Next:')
      ..writeln('  cd $shown')
      ..writeln('  flutter run')
      ..writeln('  forge feature orders   # adds lib/features/orders with its tests');
    return ExitCodes.ok;
  }
}

final class _FeatureCommand extends Command<int> {
  _FeatureCommand(this.env) {
    argParser
      ..addOption('entity', help: 'Class name of one item, such as Order. Defaults to the singular of the feature.')
      ..addOption('api-path', help: 'Path of the list endpoint. Defaults to /<feature-name>.')
      ..addOption('project-directory', abbr: 'C', help: 'The app to add the feature to. Defaults to this folder.')
      ..addFlag('format', defaultsTo: true, help: 'Run `dart format` on the changed files.');
  }

  final ForgeEnvironment env;

  @override
  String get name => 'feature';

  @override
  String get description => 'Add a feature with domain, data and presentation layers, tests and a route.';

  @override
  String get invocation => 'forge feature <feature_name>';

  @override
  Future<int> run() async {
    final args = argResults!;
    if (args.rest.length != 1) usageException('Give exactly one feature name, such as orders.');
    final feature = checkFeatureName(args.rest.single);
    final root = p.normalize(p.absolute(env.workingDirectory, args.option('project-directory') ?? '.'));
    final project = _projectName(root);
    final values = featureValues(
      project: project,
      feature: feature,
      entity: args.option('entity'),
      apiPath: args.option('api-path'),
    );
    if (Directory(p.join(root, 'lib', 'features', feature)).existsSync()) {
      throw _Failure('lib/features/$feature already exists.', ExitCodes.cannotCreate);
    }

    final written = writeFiles(root, renderAll(featureTemplates, values));
    final changed = [...written];
    final manual = <String>[];
    for (final MapEntry(key: relative, value: markers) in featureInsertions.entries) {
      final file = File(p.join(root, relative));
      var content = file.existsSync() ? file.readAsStringSync() : null;
      for (final MapEntry(key: marker, value: template) in markers.entries) {
        final line = render(template, values);
        final next = switch (content) {
          null => null,
          _ when marker == afterLastImport => insertImport(content, line),
          _ => insertAboveMarker(content, marker, line),
        };
        if (next == null) {
          manual.add('  $relative: $line');
        } else {
          content = next;
        }
      }
      if (content != null && content != file.readAsStringSync()) {
        file.writeAsStringSync(content);
        changed.add(relative);
      }
    }

    if (args.flag('format')) {
      try {
        await _runTool(env, 'dart', ['format', ...changed], root);
      } on _Failure catch (error) {
        env.err.writeln('The feature was written, but formatting failed: ${error.message}');
      }
    }

    env.out.writeln('Added ${values['featureTitle']} (${written.length} files), route /${values['route']}.');
    env.out.writeln('It reads a list of ${values['entity']} from ${values['apiPath']}.');
    if (manual.isNotEmpty) {
      env.out
        ..writeln('These files have no forge marker, so add the lines yourself:')
        ..writeAll(manual, '\n')
        ..writeln();
    }
    return ExitCodes.ok;
  }

  String _projectName(String root) {
    final pubspec = File(p.join(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw _Failure('$root has no pubspec.yaml. Run forge feature inside an app, or pass -C <app>.', ExitCodes.usage);
    }
    final match = RegExp(r'^name:\s*([a-z][a-z0-9_]*)\s*$', multiLine: true).firstMatch(pubspec.readAsStringSync());
    if (match == null) throw const _Failure('pubspec.yaml has no valid name: line.', ExitCodes.dataError);
    return match.group(1)!;
  }
}
