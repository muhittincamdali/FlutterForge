<!-- i18n-source: README.md@dfd27954e8f8ed0c099ad2f5b125c87183212c58 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="Dernière version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="Version du langage: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

FlutterForge, ce sont deux outils pour les développeurs Flutter dans un seul paquet Dart. `ForgeClient` est un client JSON-over-HTTP construit sur [`package:http`](https://pub.dev/packages/http) : il relance les requêtes, met les réponses en cache, renouvelle les bearer tokens, limite la durée et la taille des réponses, et refuse les redirections dangereuses. `forge` est une commande qui crée une application Flutter — ou y ajoute une fonctionnalité — avec une organisation feature-first, Riverpod, go_router, ce client et des tests pour chaque couche, de sorte qu’un nouveau projet démarre avec du code qui passe déjà `flutter analyze` et `flutter test`. Vous pouvez utiliser le client sans la commande, et l’application générée est du code Flutter ordinaire que vous pouvez modifier.

## Points forts

- **Un seul type d’erreur à gérer** — chaque échec est une `ApiException` scellée (sealed) ; un `switch` dessus est donc vérifié par le compilateur, et son `toString` ne nomme que la méthode et l’hôte, jamais le chemin, la query, les en-têtes ni le corps.
- **Des nouvelles tentatives sans risque** — les requêtes idempotentes sont relancées après des erreurs de connexion, des délais dépassés et les codes `408`/`429`/`5xx`, avec un backoff à jitter et en respectant `Retry-After` ; `POST` et `PATCH` ne le sont pas, sauf si vous le demandez.
- **Un cache adapté au hors ligne** — `networkFirst` retombe sur la dernière réponse lorsque l’appareil est hors ligne ; `cacheFirst` revalide avec `ETag` et `Last-Modified`. Le cache en mémoire est borné en nombre d’entrées et en octets.
- **Des tokens qui restent à leur place** — le bearer token n’est envoyé qu’à l’origin de l’API, les réponses `401` simultanées partagent un seul renouvellement, et les redirections vers un autre origin suppriment `Authorization` et `Cookie` (sauf sur le web, où c’est le navigateur qui suit les redirections).
- **Des limites par défaut** — 30 s maximum par tentative, une limite de réponse de 16 MiB qui arrête aussi les corps sans fin, une annulation qui ferme la connexion, et des valeurs d’en-tête qui ne peuvent pas injecter une nouvelle ligne d’en-tête.
- **Un générateur dont la sortie est testée** — l’[application d’exemple](example) est exactement la sortie de `forge create` ; la CI l’analyse et la teste, et un test échoue si elle s’écarte des modèles.

## Démarrage rapide

**1. Installer la commande `forge`**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

Il vous faut [Flutter](https://docs.flutter.dev/install) 3.44 ou plus récent, qui inclut Dart. Si votre terminal affiche ensuite `forge: command not found`, ajoutez à votre `PATH` le dossier indiqué par Dart (`$HOME/.pub-cache/bin` sous macOS et Linux, `%LOCALAPPDATA%\Pub\Cache\bin` sous Windows) et ouvrez un nouveau terminal.

**2. Créer une application**

```sh
forge create my_app
```

Cela exécute `flutter create` pour les dossiers Android et iOS, écrit l’application, ses tests et un workflow GitHub Actions qui les vérifie, puis exécute `flutter pub get`. Ajoutez `--org com.yourcompany` pour définir l’identifiant de l’application, ou `--platforms ios,android,web,macos` pour plus de plateformes.

**3. La lancer**

```sh
cd my_app
flutter run
```

L’application s’ouvre sur une page d’accueil avec une entrée **Todos** ; touchez-la pour charger une liste depuis `jsonplaceholder.typicode.com`. Exécutez `flutter test` pour voir passer les tests générés, et `forge feature orders` pour ajouter un deuxième écran avec ses propres tests.

## Installation

Pour n’utiliser que le client HTTP dans un projet Flutter ou Dart existant, ajoutez le paquet à `pubspec.yaml` :

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

Exécutez ensuite `flutter pub get` (ou `dart pub get`) et importez-le :

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

Le paquet ne dépend que de `http`, `http_parser`, `args` et `path`, et fonctionne sur Android, iOS, macOS, Windows, Linux, le web et la VM Dart. Il s’installe depuis Git, car le nom `flutter_forge` sur pub.dev appartient à un autre paquet, abandonné.

La version 2.0.0 est une réécriture : les sources de la 1.0.0 ne compilaient pas, et plus rien de leur API n’existe. [CHANGELOG.md](CHANGELOG.md) donne les détails.

## Utilisation

Chaque exemple ci-dessous figure aussi dans [test/readme_test.dart](test/readme_test.dart), qui l’exécute face à un faux serveur.

### Appeler une API

```dart
final class Todo {
  const Todo({required this.id, required this.title});

  final int id;
  final String title;

  static Todo fromJson(Object? json) => switch (json) {
    {'id': final int id, 'title': final String title} => Todo(id: id, title: title),
    _ => throw const FormatException('Not a todo'),
  };

  static List<Todo> listFromJson(Object? json) => [for (final item in json! as List<Object?>) fromJson(item)];
}

final client = ForgeClient(baseUrl: 'https://jsonplaceholder.typicode.com');
final todo = await client.getJson('/todos/1', decode: Todo.fromJson);
print(todo.title); // delectus aut autem

final created = await client.postJson('/todos', json: {'title': 'Ship it'}, decode: (json) => json);
```

Les chemins relatifs sont ajoutés à l’URL de base. Tout ce que `decode` lève devient une `DecodingException`.

### Gérer les échecs

```dart
String messageFor(Object error) => switch (error) {
  ConnectionException() => 'You appear to be offline.',
  RequestTimeoutException() => 'The server took too long to answer.',
  HttpStatusException(statusCode: 404) => 'Not found.',
  HttpStatusException(:final statusCode) => 'The server answered $statusCode.',
  ApiException() => 'Something went wrong.',
  _ => 'Unexpected error: $error',
};

try {
  await client.getJson('/todos/999', decode: Todo.fromJson);
} on ApiException catch (error) {
  print(messageFor(error)); // Not found.
}
```

`HttpStatusException.response` conserve le corps que le serveur a envoyé avec l’erreur.

### Garder la dernière réponse pour un usage hors ligne

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

Utilisez `CachePolicy.cacheFirst` pour éviter la requête tant que la réponse stockée est fraîche, et appelez `cache.clear()` lorsque l’utilisateur connecté change.

### Envoyer un bearer token

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` enregistre le nouveau token et le renvoie, ou renvoie `null` lorsque l’utilisateur doit se reconnecter.

### Tester sans serveur

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  retry: RetryPolicy.none,
  httpClient: MockClient((request) async {
    expect(request.url.path, '/todos');
    return http.Response(jsonEncode([
      {'id': 1, 'title': 'Test'},
    ]), 200);
  }),
);

expect(await client.getJson('/todos', decode: Todo.listFromJson), hasLength(1));
```

`MockClient` provient de `package:http/testing.dart`.

### Ajouter une fonctionnalité à une application générée

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

Chaque commande écrit `lib/features/<name>/{domain,data,presentation}` et deux fichiers de test, ajoute la route à `lib/app/router.dart`, ajoute l’écran à la page d’accueil et formate ce qu’elle a modifié. Les noms qui ne compileraient pas, comme une fonctionnalité dont l’entité s’appellerait `Text`, sont refusés avant que quoi que ce soit ne soit écrit.

## Captures d’écran

L’application d’exemple sur un simulateur d’iPhone 18 Pro (iOS 27), avec des données réelles provenant de `jsonplaceholder.typicode.com` :

| Accueil | Todos | Todos, sombre | Hors ligne |
| --- | --- | --- | --- |
| ![Page d’accueil listant l’écran Todos](docs/screenshots/home.png) | ![Liste de tâches chargée depuis l’API](docs/screenshots/todos.png) | ![Liste de tâches en apparence sombre](docs/screenshots/todos-dark.png) | ![Message hors ligne avec un bouton pour réessayer](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) compile l’exemple et prend ces captures d’écran. Pour exécuter l’exemple vous-même :

```sh
cd example
flutter run
```

## Documentation

- [Référence de l’API et guides](https://muhittincamdali.github.io/FlutterForge/) — générés avec `dart doc` et publiés sur GitHub Pages depuis `main`.
- Pour les générer en local, exécutez `dart doc --output build/doc` et ouvrez `build/doc/index.html`.
- `forge --help`, `forge create --help` et `forge feature --help` listent toutes les options.

## Guides

- [Appeler une API avec ForgeClient](doc/guides/calling-an-api.md) — requêtes typées, erreurs, nouvelles tentatives, cache, tokens, annulation, interceptors et tests.
- [Créer une application avec forge](doc/guides/creating-an-app.md) — créer une application, comprendre son organisation, ajouter une fonctionnalité, la brancher sur votre API et ajouter un champ.
- [Ce contre quoi le client protège](doc/guides/security-model.md) — redirections, injection d’en-têtes, limites de mémoire, nombres hostiles, et ce qui reste à votre charge.

## Prérequis

| Chaîne d’outils | Version minimale |
| --- | --- |
| Dart (bibliothèque et `forge`) | 3.12 |
| Flutter (applications générées) | 3.44 |

Les applications générées utilisent Riverpod 3.4, go_router 18.1 et `http` 1.6. Le paquet est développé et testé avec Flutter 3.47 et Dart 3.13 ; la CI utilise la dernière version stable de Flutter.

## Architecture

- `lib/src/network/` — `ForgeClient` construit une chaîne d’interceptors autour d’un transport : vos interceptors, puis `CacheInterceptor`, `RetryInterceptor` et `BearerAuthInterceptor`. Le transport envoie une requête via `package:http` avec les redirections désactivées, suit lui-même les redirections, applique la limite de temps avec des requêtes `Abortable` et lit le corps avec une limite en octets. Les requêtes et les réponses sont des valeurs immuables.
- `lib/src/cli/` — `forge` est un `CommandRunner` de `package:args`. Les modèles sont des constantes de chaîne Dart rendues par un remplaçant `{{key}}` strict, qui échoue si une valeur manque ; les noms sont validés avant de toucher un fichier, et les fichiers ne sont écrits qu’à l’intérieur du projet.
- `example/` — la sortie de `forge create`, qui dépend de ce checkout via `path: ..`.
- `test/` — des tests unitaires pour le client (avec un faux `http.Client` qui gère l’abandon et les corps en streaming), pour la CLI (avec un faux process runner dans un dossier temporaire), pour les exemples du README, et un test qui régénère l’exemple et le compare fichier par fichier.

Lancez les vérifications en local :

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## Feuille de route

- Progression de l’envoi et du téléchargement pour les gros corps.
- Un `ResponseCache` persistant (fichiers ou SQLite) à côté de `MemoryResponseCache`.
- Davantage de modèles `forge` : localisation et build flavors pour la nouvelle application.

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
