import '../template.dart';

/// The files of one feature.
///
/// Keys: `project`, `feature` (`order_items`), `Feature` (`OrderItems`),
/// `featureVar` (`orderItems`), `featureTitle` (`Order items`), `entity`
/// (`OrderItem`), `entityVar` (`orderItem`), `entityFile` (`order_item`),
/// `route` (`order-items`) and `apiPath` (`/order-items`).
const List<TemplateFile> featureTemplates = [
  TemplateFile('lib/features/{{feature}}/domain/{{entityFile}}.dart', r'''
/// One item of the {{featureTitle}} feature.
///
/// Add the fields your API returns, then read them in
/// `data/{{entityFile}}_json.dart`.
final class {{entity}} {
  const {{entity}}({required this.id, required this.title});

  final int id;
  final String title;

  @override
  bool operator ==(Object other) =>
      other is {{entity}} && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);

  @override
  String toString() => '{{entity}}($id, $title)';
}
'''),
  TemplateFile('lib/features/{{feature}}/domain/{{feature}}_repository.dart', r'''
import 'package:{{project}}/features/{{feature}}/domain/{{entityFile}}.dart';

/// Where the {{featureTitle}} feature reads its data from.
///
/// The presentation layer only knows this interface, so tests and previews
/// can pass a fake.
abstract interface class {{Feature}}Repository {
  Future<List<{{entity}}>> fetchAll();
}
'''),
  TemplateFile('lib/features/{{feature}}/data/{{entityFile}}_json.dart', r'''
import 'package:{{project}}/features/{{feature}}/domain/{{entityFile}}.dart';

/// Reads one [{{entity}}] from its JSON object.
///
/// Throws a [FormatException] when a field is missing or has another type;
/// `ForgeClient` turns it into a `DecodingException`.
{{entity}} {{entityVar}}FromJson(Object? json) {
  if (json case {'id': final int id, 'title': final String title}) {
    return {{entity}}(id: id, title: title);
  }
  throw const FormatException('Expected an object with an int id and a title.');
}

/// Reads a JSON array of [{{entity}}] objects.
List<{{entity}}> {{entityVar}}ListFromJson(Object? json) => switch (json) {
  final List<Object?> items => [for (final item in items) {{entityVar}}FromJson(item)],
  _ => throw const FormatException('Expected a JSON array.'),
};
'''),
  TemplateFile('lib/features/{{feature}}/data/http_{{feature}}_repository.dart', r'''
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project}}/core/network.dart';
import 'package:{{project}}/features/{{feature}}/data/{{entityFile}}_json.dart';
import 'package:{{project}}/features/{{feature}}/domain/{{entityFile}}.dart';
import 'package:{{project}}/features/{{feature}}/domain/{{feature}}_repository.dart';

/// Reads {{featureTitle}} from `{{apiPath}}` on the app's API.
final class Http{{Feature}}Repository implements {{Feature}}Repository {
  Http{{Feature}}Repository(this._client);

  final ForgeClient _client;

  @override
  Future<List<{{entity}}>> fetchAll() => _client.getJson(
    '{{apiPath}}',
    query: {'_limit': 20},
    decode: {{entityVar}}ListFromJson,
    // Shows the last list that was loaded when the device is offline.
    cachePolicy: CachePolicy.networkFirst,
  );
}

/// The repository the app uses. Tests replace it with
/// `{{featureVar}}RepositoryProvider.overrideWithValue(...)`.
final {{featureVar}}RepositoryProvider = Provider<{{Feature}}Repository>(
  (ref) => Http{{Feature}}Repository(ref.watch(forgeClientProvider)),
);
'''),
  TemplateFile('lib/features/{{feature}}/presentation/{{feature}}_controller.dart', r'''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project}}/features/{{feature}}/data/http_{{feature}}_repository.dart';
import 'package:{{project}}/features/{{feature}}/domain/{{entityFile}}.dart';

/// Loads the {{featureTitle}} list and reloads it on request.
class {{Feature}}Controller extends AsyncNotifier<List<{{entity}}>> {
  @override
  Future<List<{{entity}}>> build() => ref.watch({{featureVar}}RepositoryProvider).fetchAll();

  /// Loads the list again, keeping the current one on screen meanwhile.
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final {{featureVar}}ControllerProvider =
    AsyncNotifierProvider<{{Feature}}Controller, List<{{entity}}>>({{Feature}}Controller.new);
'''),
  TemplateFile('lib/features/{{feature}}/presentation/{{feature}}_page.dart', r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project}}/core/error_message.dart';
import 'package:{{project}}/core/widgets/error_view.dart';
import 'package:{{project}}/features/{{feature}}/presentation/{{feature}}_controller.dart';

/// Shows the {{featureTitle}} list.
class {{Feature}}Page extends ConsumerWidget {
  const {{Feature}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final {{featureVar}} = ref.watch({{featureVar}}ControllerProvider);
    final controller = ref.read({{featureVar}}ControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('{{featureTitle}}')),
      body: switch ({{featureVar}}) {
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: controller.reload,
          child: value.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Nothing here yet.'),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(child: Text('${value[index].id}')),
                    title: Text(value[index].title),
                  ),
                ),
        ),
        AsyncValue(:final error?) => ErrorView(
          message: errorMessage(error),
          onRetry: controller.reload,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
'''),
  TemplateFile('test/features/{{feature}}/data/http_{{feature}}_repository_test.dart', r'''
import 'dart:convert';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:{{project}}/features/{{feature}}/data/http_{{feature}}_repository.dart';
import 'package:{{project}}/features/{{feature}}/domain/{{entityFile}}.dart';

void main() {
  late List<http.Request> requests;

  Http{{Feature}}Repository repositoryAnswering(int status, Object? body) {
    requests = [];
    final client = ForgeClient(
      baseUrl: 'https://api.example.com',
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(jsonEncode(body), status);
      }),
      retry: RetryPolicy.none,
    );
    return Http{{Feature}}Repository(client);
  }

  test('reads the list from {{apiPath}}', () async {
    final repository = repositoryAnswering(200, [
      {'id': 1, 'title': 'First'},
      {'id': 2, 'title': 'Second'},
    ]);

    expect(await repository.fetchAll(), const [
      {{entity}}(id: 1, title: 'First'),
      {{entity}}(id: 2, title: 'Second'),
    ]);
    expect(requests.single.url.path, '{{apiPath}}');
    expect(requests.single.url.queryParameters, {'_limit': '20'});
  });

  test('a server error becomes an HttpStatusException', () {
    final repository = repositoryAnswering(500, {'error': 'down'});
    expect(repository.fetchAll(), throwsA(isA<HttpStatusException>()));
  });

  test('an item without a title becomes a DecodingException', () {
    final repository = repositoryAnswering(200, [
      {'id': 1},
    ]);
    expect(repository.fetchAll(), throwsA(isA<DecodingException>()));
  });

  test('an object instead of a list becomes a DecodingException', () {
    final repository = repositoryAnswering(200, {'id': 1, 'title': 'x'});
    expect(repository.fetchAll(), throwsA(isA<DecodingException>()));
  });
}
'''),
  TemplateFile('test/features/{{feature}}/presentation/{{feature}}_page_test.dart', r'''
import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project}}/features/{{feature}}/data/http_{{feature}}_repository.dart';
import 'package:{{project}}/features/{{feature}}/domain/{{entityFile}}.dart';
import 'package:{{project}}/features/{{feature}}/domain/{{feature}}_repository.dart';
import 'package:{{project}}/features/{{feature}}/presentation/{{feature}}_page.dart';

/// Answers with the next result in [results] on each call.
final class _Fake{{Feature}}Repository implements {{Feature}}Repository {
  _Fake{{Feature}}Repository(this.results);

  final List<Object> results;
  int calls = 0;

  @override
  Future<List<{{entity}}>> fetchAll() async {
    final result = results[calls++];
    if (result is List<{{entity}}>) return result;
    throw result;
  }
}

Future<void> _show(WidgetTester tester, {{Feature}}Repository repository) {
  return tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [{{featureVar}}RepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: {{Feature}}Page()),
    ),
  );
}

void main() {
  final offline = ConnectionException(
    ForgeRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
  );

  testWidgets('shows the items', (tester) async {
    await _show(
      tester,
      _Fake{{Feature}}Repository([
        const [{{entity}}(id: 1, title: 'First'), {{entity}}(id: 2, title: 'Second')],
      ]),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('says so when the list is empty', (tester) async {
    await _show(tester, _Fake{{Feature}}Repository([const <{{entity}}>[]]));
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet.'), findsOneWidget);
  });

  testWidgets('explains an error and loads again on Try again', (tester) async {
    final repository = _Fake{{Feature}}Repository([
      offline,
      const [{{entity}}(id: 3, title: 'Back online')],
    ]);
    await _show(tester, repository);
    await tester.pumpAndSettle();
    expect(find.textContaining('offline'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Back online'), findsOneWidget);
    expect(repository.calls, 2);
  });
}
'''),
];

/// Marks an import line in [featureInsertions]: it goes after the last
/// import of the file instead of above a marker comment.
const String afterLastImport = 'import';

/// The lines `forge feature` adds to the files that `forge create` wrote, by
/// file and marker comment. Each line goes above its marker, indented like
/// it. Same keys as [featureTemplates].
const Map<String, Map<String, String>> featureInsertions = {
  'lib/app/router.dart': {
    afterLastImport: "import 'package:{{project}}/features/{{feature}}/presentation/{{feature}}_page.dart';",
    '// forge:routes': "GoRoute(path: '/{{route}}', builder: (context, state) => const {{Feature}}Page()),",
  },
  'lib/app/destinations.dart': {'// forge:destinations': "Destination(title: '{{featureTitle}}', path: '/{{route}}'),"},
};
