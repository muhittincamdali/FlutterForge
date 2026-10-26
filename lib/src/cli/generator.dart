import 'dart:io';

import 'package:path/path.dart' as p;

import 'names.dart';
import 'template.dart';
import 'templates/app_templates.dart';
import 'templates/feature_templates.dart';

/// The Git tag of FlutterForge that new apps depend on.
const String forgeGitRef = 'v2.0.0';

/// The repository new apps download FlutterForge from.
const String forgeGitUrl = 'https://github.com/muhittincamdali/FlutterForge.git';

/// The feature every new app starts with.
const String starterFeature = 'todos';

/// The template values of the app [project].
Map<String, String> appValues({required String project, required String description, String? forgePath}) => {
  'project': project,
  'title': titleCase(project),
  'description': description,
  'forgeDependency': forgePath == null
      ? '    git:\n      url: $forgeGitUrl\n      ref: $forgeGitRef'
      : '    path: ${_yamlPath(forgePath)}',
};

/// The template values of [feature] in [project]. [entity] defaults to the
/// singular of [feature] and [apiPath] to `/` plus the feature in kebab case.
Map<String, String> featureValues({required String project, required String feature, String? entity, String? apiPath}) {
  final entityName = checkEntityName(entity ?? singularEntity(feature));
  return {
    'project': project,
    'feature': feature,
    'Feature': pascalCase(feature),
    'featureVar': camelCase(feature),
    'featureTitle': titleCase(feature),
    'entity': entityName,
    'entityVar': entityName[0].toLowerCase() + entityName.substring(1),
    'entityFile': snakeCaseOf(entityName),
    'route': kebabCase(feature),
    'apiPath': checkApiPath(apiPath ?? '/${kebabCase(feature)}'),
  };
}

/// `OrderItem` to `order_item`.
String snakeCaseOf(String pascal) => pascal
    .replaceAllMapped(RegExp(r'(?<=[a-z0-9])([A-Z])|(?<=[A-Z])([A-Z])(?=[a-z])'), (m) => '_${m[0]}')
    .toLowerCase();

/// Renders [templates] with [values] into a map from relative path to
/// content.
Map<String, String> renderAll(List<TemplateFile> templates, Map<String, String> values) => {
  for (final template in templates) render(template.path, values): render(template.content, values).trimLeft(),
};

/// The files of a new app with its starter feature.
Map<String, String> renderApp(Map<String, String> app) => {
  ...renderAll(appTemplates, app),
  ...renderAll(featureTemplates, featureValues(project: app['project']!, feature: starterFeature)),
};

/// Writes [files] under [root].
///
/// Refuses any path that would end up outside [root] and, unless
/// [overwrite] is true, any file that already exists; in both cases nothing
/// is written.
List<String> writeFiles(String root, Map<String, String> files, {bool overwrite = false}) {
  final base = p.normalize(p.absolute(root));
  final targets = <String, String>{};
  for (final MapEntry(key: relative, value: content) in files.entries) {
    final target = p.normalize(p.join(base, relative));
    if (!p.isWithin(base, target)) throw InvalidInput('Refusing to write outside the project: $relative');
    if (!overwrite && File(target).existsSync()) {
      throw InvalidInput('$relative already exists. Nothing was written.');
    }
    targets[target] = content;
  }
  for (final MapEntry(key: target, value: content) in targets.entries) {
    File(target)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }
  return [for (final target in targets.keys) p.relative(target, from: base)];
}

/// Puts [line] above the line whose trimmed text is [marker], with the same
/// indentation. Returns `null` when there is no marker; returns [content]
/// unchanged when the line is already there.
String? insertAboveMarker(String content, String marker, String line) {
  final lines = content.split('\n');
  final index = lines.indexWhere((candidate) => candidate.trim() == marker);
  if (index == -1) return null;
  if (lines.any((candidate) => candidate.trim() == line.trim())) return content;
  final indent = lines[index].substring(0, lines[index].indexOf(marker));
  lines.insert(index, '$indent${line.trim()}');
  return lines.join('\n');
}

/// Puts the import [line] after the last import of [content]. Returns `null`
/// when [content] has no import; returns it unchanged when the import is
/// already there.
String? insertImport(String content, String line) {
  final lines = content.split('\n');
  final last = lines.lastIndexWhere((candidate) => candidate.startsWith('import '));
  if (last == -1) return null;
  if (lines.contains(line)) return content;
  lines.insert(last + 1, line);
  return lines.join('\n');
}

/// Adds the Android `INTERNET` permission, which `flutter create` only puts
/// in the debug and profile manifests, and shows [title] as the app label.
String patchAndroidManifest(String manifest, {required String project, required String title}) {
  var patched = manifest.replaceFirst('android:label="$project"', 'android:label="$title"');
  if (!patched.contains('android.permission.INTERNET')) {
    patched = patched.replaceFirstMapped(
      RegExp(r'<manifest[^>]*>\n'),
      (match) => '${match[0]}    <uses-permission android:name="android.permission.INTERNET" />\n',
    );
  }
  return patched;
}

/// Adds the outgoing network entitlement that a sandboxed macOS app needs to
/// reach its API.
String patchMacosEntitlements(String plist) {
  if (plist.contains('com.apple.security.network.client')) return plist;
  return plist.replaceFirst(
    RegExp(r'</dict>\s*</plist>'),
    '\t<key>com.apple.security.network.client</key>\n\t<true/>\n</dict>\n</plist>',
  );
}

/// Applies [patchAndroidManifest] and [patchMacosEntitlements] to the
/// platform folders `flutter create` wrote in [directory], and returns the
/// files it changed.
List<String> patchPlatformFiles(String directory, {required String project, required String title}) {
  final patches = <String, String Function(String)>{
    'android/app/src/main/AndroidManifest.xml': (text) => patchAndroidManifest(text, project: project, title: title),
    'macos/Runner/DebugProfile.entitlements': patchMacosEntitlements,
    'macos/Runner/Release.entitlements': patchMacosEntitlements,
  };
  final changed = <String>[];
  for (final MapEntry(key: relative, value: patch) in patches.entries) {
    final file = File(p.join(directory, relative));
    if (!file.existsSync()) continue;
    final before = file.readAsStringSync();
    final after = patch(before);
    if (after != before) {
      file.writeAsStringSync(after);
      changed.add(relative);
    }
  }
  return changed;
}

String _yamlPath(String path) {
  final portable = path.replaceAll(r'\', '/');
  return RegExp(r'^[A-Za-z0-9_./-]+$').hasMatch(portable) ? portable : "'${portable.replaceAll("'", "''")}'";
}
