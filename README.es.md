<!-- i18n-source: README.md@bd6de8e9a9d78d66fc0db6a6e9edbb03acfd83f6 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="Última versión: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

FlutterForge son dos herramientas para desarrolladores de Flutter en un solo paquete de Dart. `ForgeClient` es un cliente JSON-over-HTTP construido sobre [`package:http`](https://pub.dev/packages/http) que reintenta peticiones, guarda respuestas en caché, renueva bearer tokens, limita el tiempo y el tamaño de la respuesta, y rechaza las redirecciones inseguras. `forge` es un comando que crea una app de Flutter —o añade una funcionalidad a una existente— con una estructura feature-first, Riverpod, go_router, ese cliente y pruebas para cada capa, de modo que un proyecto nuevo empieza con código que ya pasa `flutter analyze` y `flutter test`. Puedes usar el cliente sin el comando, y la app generada es código Flutter normal que puedes modificar.

## Lo más destacado

- **Un solo tipo de error que manejar** — todo fallo es un `ApiException` sellado (sealed), así que un `switch` sobre él lo comprueba el compilador, y su `toString` nombra solo el método y el host, nunca la ruta, la query, las cabeceras ni el cuerpo.
- **Reintentos que se pueden repetir sin riesgo** — las peticiones idempotentes se reintentan tras errores de conexión, timeouts y `408`/`429`/`5xx`, con backoff con jitter y respetando `Retry-After`; `POST` y `PATCH` no se reintentan salvo que lo pidas.
- **Caché pensada para trabajar sin conexión** — `networkFirst` recurre a la última respuesta cuando el dispositivo está sin conexión; `cacheFirst` revalida con `ETag` y `Last-Modified`. La caché en memoria está acotada por número de entradas y por bytes.
- **Tokens que se quedan donde deben** — el bearer token va solo al origin de la API, las respuestas `401` simultáneas comparten una única renovación y las redirecciones a otro origin descartan `Authorization` y `Cookie` (salvo en la web, donde es el navegador quien sigue las redirecciones).
- **Con límites por defecto** — un límite de 30 s por intento, un límite de respuesta de 16 MiB que también detiene los cuerpos interminables, una cancelación que cierra la conexión y valores de cabecera que no pueden inyectar una línea de cabecera nueva.
- **Un generador cuya salida está probada** — la [app de ejemplo](example) es exactamente la salida de `forge create`; la CI la analiza y la prueba, y un test falla si se aleja de las plantillas.

## Inicio rápido

**1. Instala el comando `forge`**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

Necesitas [Flutter](https://docs.flutter.dev/install) 3.44 o posterior, que incluye Dart. Si después el terminal dice `forge: command not found`, añade a tu `PATH` la carpeta que mostró Dart (`$HOME/.pub-cache/bin` en macOS y Linux, `%LOCALAPPDATA%\Pub\Cache\bin` en Windows) y abre un terminal nuevo.

**2. Crea una app**

```sh
forge create my_app
```

Esto ejecuta `flutter create` para las carpetas de Android e iOS, escribe la app, sus tests y un workflow de GitHub Actions que los comprueba, y ejecuta `flutter pub get`. Añade `--org com.yourcompany` para definir el id de la app, o `--platforms ios,android,web,macos` para más plataformas.

**3. Ejecútala**

```sh
cd my_app
flutter run
```

La app se abre en una página de inicio con una entrada **Todos**; púlsala para cargar una lista desde `jsonplaceholder.typicode.com`. Ejecuta `flutter test` para ver cómo pasan los tests generados, y `forge feature orders` para añadir una segunda pantalla con sus propios tests.

## Instalación

Para usar solo el cliente HTTP en un proyecto de Flutter o Dart existente, añade el paquete a `pubspec.yaml`:

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

Después ejecuta `flutter pub get` (o `dart pub get`) e impórtalo:

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

El paquete depende solo de `http`, `http_parser`, `args` y `path`, y funciona en Android, iOS, macOS, Windows, Linux, la web y la VM de Dart. Se instala desde Git porque el nombre `flutter_forge` en pub.dev pertenece a otro paquete, ya discontinuado.

La versión 2.0.0 es una reescritura: el código de la 1.0.0 no compilaba y ya no queda nada de su API. [CHANGELOG.md](CHANGELOG.md) tiene los detalles.

## Uso

Todos los ejemplos siguientes están también en [test/readme_test.dart](test/readme_test.dart), que los ejecuta contra un servidor simulado.

### Llamar a una API

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

Las rutas relativas se añaden a la URL base. Cualquier cosa que lance `decode` se convierte en una `DecodingException`.

### Gestionar los fallos

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

`HttpStatusException.response` conserva el cuerpo que el servidor envió junto con el error.

### Conservar la última respuesta para usarla sin conexión

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

Usa `CachePolicy.cacheFirst` para omitir la petición mientras la respuesta guardada siga vigente, y llama a `cache.clear()` cuando cambie el usuario con sesión iniciada.

### Enviar un bearer token

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` guarda el nuevo token y lo devuelve, o devuelve `null` cuando el usuario tiene que iniciar sesión de nuevo.

### Probar sin un servidor

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

`MockClient` viene de `package:http/testing.dart`.

### Añadir una funcionalidad a una app generada

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

Cada comando escribe `lib/features/<name>/{domain,data,presentation}` y dos archivos de test, añade la ruta a `lib/app/router.dart`, añade la pantalla a la página de inicio y da formato a lo que cambió. Los nombres que no compilarían, como una funcionalidad cuya entidad se llamaría `Text`, se rechazan antes de escribir nada.

## Capturas de pantalla

La app de ejemplo en un simulador de iPhone 18 Pro (iOS 27), con datos reales de `jsonplaceholder.typicode.com`:

| Inicio | Todos | Todos, oscuro | Sin conexión |
| --- | --- | --- | --- |
| ![Página de inicio con la pantalla Todos](docs/screenshots/home.png) | ![Lista de tareas cargada desde la API](docs/screenshots/todos.png) | ![Lista de tareas en apariencia oscura](docs/screenshots/todos-dark.png) | ![Mensaje sin conexión con un botón para reintentar](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) compila el ejemplo y hace estas capturas. Para ejecutar el ejemplo tú mismo:

```sh
cd example
flutter run
```

## Documentación

- [Referencia de la API y guías](https://muhittincamdali.github.io/FlutterForge/) — generada con `dart doc` y publicada en GitHub Pages desde `main`.
- Para generarla en local, ejecuta `dart doc --output build/doc` y abre `build/doc/index.html`.
- `forge --help`, `forge create --help` y `forge feature --help` listan todas las opciones.

## Guías

- [Llamar a una API con ForgeClient](doc/guides/calling-an-api.md) — peticiones tipadas, errores, reintentos, caché, tokens, cancelación, interceptors y tests.
- [Crear una app con forge](doc/guides/creating-an-app.md) — crear una app, entender su estructura, añadir una funcionalidad, apuntarla a tu API y añadir un campo.
- [De qué protege el cliente](doc/guides/security-model.md) — redirecciones, inyección de cabeceras, límites de memoria, números hostiles y lo que queda de tu parte.

## Requisitos

| Herramientas | Versión mínima |
| --- | --- |
| Dart (biblioteca y `forge`) | 3.12 |
| Flutter (apps generadas) | 3.44 |

Las apps generadas usan Riverpod 3.4, go_router 18.1 y `http` 1.6. El paquete se desarrolla y se prueba con Flutter 3.47 y Dart 3.13; la CI usa la última versión estable de Flutter.

## Arquitectura

- `lib/src/network/` — `ForgeClient` construye una cadena de interceptors alrededor de un transporte: tus interceptors, luego `CacheInterceptor`, `RetryInterceptor` y `BearerAuthInterceptor`. El transporte envía una petición a través de `package:http` con las redirecciones desactivadas, sigue las redirecciones por su cuenta, aplica el límite de tiempo con peticiones `Abortable` y lee el cuerpo con un límite de bytes. Las peticiones y las respuestas son valores inmutables.
- `lib/src/cli/` — `forge` es un `CommandRunner` de `package:args`. Las plantillas son constantes de cadena de Dart que se renderizan con un reemplazador estricto de `{{key}}` que falla si falta un valor; los nombres se validan antes de tocar ningún archivo y los archivos solo se escriben dentro del proyecto.
- `example/` — la salida de `forge create`, que depende de este checkout mediante `path: ..`.
- `test/` — tests unitarios del cliente (con un `http.Client` simulado que admite abortar y cuerpos en streaming), de la CLI (con un process runner simulado en una carpeta temporal), de los ejemplos del README, y un test que regenera el ejemplo y lo compara archivo por archivo.

Ejecuta las comprobaciones en local:

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## Hoja de ruta

- Progreso de subida y descarga para cuerpos grandes.
- Una `ResponseCache` persistente (archivos o SQLite) junto a `MemoryResponseCache`.
- Más plantillas de `forge`: localización y build flavors para la app nueva.

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
