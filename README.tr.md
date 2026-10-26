<!-- i18n-source: README.md@bd6de8e9a9d78d66fc0db6a6e9edbb03acfd83f6 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

FlutterForge, Flutter geliştiricileri için tek bir Dart paketinde iki araç sunar. `ForgeClient`, [`package:http`](https://pub.dev/packages/http) üzerine kurulu, JSON-over-HTTP çalışan bir istemcidir: istekleri yeniden dener, yanıtları önbelleğe alır, bearer token'ları yeniler, süreyi ve yanıt boyutunu sınırlar, güvensiz yönlendirmeleri reddeder. `forge` ise bir Flutter uygulaması oluşturan — ya da var olan bir uygulamaya özellik ekleyen — komuttur; çıktısı feature-first bir yapı, Riverpod, go_router, bu istemci ve her katman için testlerden oluşur. Böylece yeni bir proje, `flutter analyze` ve `flutter test` komutlarından zaten geçen bir kodla başlar. İstemciyi komut olmadan da kullanabilirsiniz; üretilen uygulama ise istediğiniz gibi değiştirebileceğiniz sıradan Flutter kodudur.

## Öne çıkanlar

- **Ele alınacak tek bir hata türü** — her hata, mühürlü (sealed) bir `ApiException` olarak gelir; bu yüzden üzerindeki `switch` derleyici tarafından denetlenir. `toString` çıktısı yalnızca metodu ve host'u içerir; path, query, header ya da body asla yer almaz.
- **Tekrarlanması güvenli yeniden denemeler** — idempotent istekler, bağlantı hatalarından, zaman aşımlarından ve `408`/`429`/`5xx` yanıtlarından sonra jitter'lı backoff ve `Retry-After` ile yeniden denenir; `POST` ve `PATCH` siz istemedikçe denenmez.
- **Çevrimdışı kullanıma uygun önbellek** — `networkFirst`, cihaz çevrimdışıyken son yanıta döner; `cacheFirst` ise `ETag` ve `Last-Modified` ile doğrulama yapar. Bellek önbelleği kayıt sayısı ve bayt cinsinden sınırlıdır.
- **Token'lar olması gereken yerde kalır** — bearer token yalnızca API'nin origin'ine gider, eşzamanlı `401` yanıtları tek bir yenilemeyi paylaşır ve başka bir origin'e yönlendirmelerde `Authorization` ile `Cookie` düşürülür (web dışında; web'de yönlendirmeleri tarayıcı izler).
- **Varsayılan olarak sınırlı** — her deneme için 30 sn süre sınırı, sonsuz gövdeleri de durduran 16 MiB yanıt sınırı, bağlantıyı kapatan iptal ve yeni bir header satırı enjekte edemeyen header değerleri.
- **Çıktısı test edilen bir üretici** — [örnek uygulama](example), `forge create` komutunun birebir çıktısıdır; CI onu analiz eder ve test eder, şablonlardan sapması hâlinde bir test başarısız olur.

## Hızlı başlangıç

**1. `forge` komutunu kurun**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

[Flutter](https://docs.flutter.dev/install) 3.44 veya daha yenisi gerekir; Dart onunla birlikte gelir. Terminal ardından `forge: command not found` derse, Dart'ın yazdırdığı klasörü (macOS ve Linux'ta `$HOME/.pub-cache/bin`, Windows'ta `%LOCALAPPDATA%\Pub\Cache\bin`) `PATH`'inize ekleyin ve yeni bir terminal açın.

**2. Bir uygulama oluşturun**

```sh
forge create my_app
```

Bu komut, Android ve iOS klasörleri için `flutter create` çalıştırır; uygulamayı, testlerini ve bunları denetleyen bir GitHub Actions workflow'unu yazar ve `flutter pub get` çalıştırır. Uygulama kimliğini belirlemek için `--org com.yourcompany`, daha fazla platform için `--platforms ios,android,web,macos` ekleyin.

**3. Çalıştırın**

```sh
cd my_app
flutter run
```

Uygulama, içinde **Todos** girişi bulunan bir ana sayfayla açılır; dokunarak `jsonplaceholder.typicode.com` adresinden bir liste yükleyebilirsiniz. Üretilen testlerin geçtiğini görmek için `flutter test`, kendi testlerine sahip ikinci bir ekran eklemek için `forge feature orders` komutunu çalıştırın.

## Kurulum

Yalnızca HTTP istemcisini mevcut bir Flutter ya da Dart projesinde kullanmak için paketi `pubspec.yaml` dosyasına ekleyin:

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

Ardından `flutter pub get` (ya da `dart pub get`) komutunu çalıştırın ve içe aktarın:

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

Paket yalnızca `http`, `http_parser`, `args` ve `path` paketlerine bağımlıdır; Android, iOS, macOS, Windows, Linux, web ve Dart VM üzerinde çalışır. Git üzerinden kurulur, çünkü pub.dev'deki `flutter_forge` adı, geliştirilmesi durdurulmuş başka bir pakete aittir.

2.0.0 sürümü baştan yazılmış bir sürümdür: 1.0.0 kaynakları derlenmiyordu ve API'lerinden hiçbiri artık yok. Ayrıntılar için [CHANGELOG.md](CHANGELOG.md) dosyasına bakın.

## Kullanım

Aşağıdaki her örnek [test/readme_test.dart](test/readme_test.dart) dosyasında da bulunur; bu dosya örnekleri sahte bir sunucuya karşı çalıştırır.

### Bir API'yi çağırın

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

Göreli path'ler base URL'in sonuna eklenir. `decode` içinde fırlatılan her şey bir `DecodingException` olur.

### Hataları ele alın

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

`HttpStatusException.response`, sunucunun hatayla birlikte gönderdiği body'yi saklar.

### Son yanıtı çevrimdışı kullanım için saklayın

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

Saklanan yanıt güncel olduğu sürece isteği atlamak için `CachePolicy.cacheFirst` kullanın; oturum açmış kullanıcı değiştiğinde `cache.clear()` çağırın.

### Bearer token gönderin

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh`, yeni token'ı saklar ve döndürür; kullanıcının yeniden oturum açması gerekiyorsa `null` döndürür.

### Sunucu olmadan test edin

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

`MockClient`, `package:http/testing.dart` içinden gelir.

### Üretilen bir uygulamaya özellik ekleyin

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

Her komut, `lib/features/<name>/{domain,data,presentation}` altına dosyaları ve iki test dosyasını yazar, rotayı `lib/app/router.dart` dosyasına ekler, ekranı ana sayfaya ekler ve değiştirdiği dosyaları biçimlendirir. Derlenmeyecek adlar — örneğin entity'si `Text` olacak bir özellik — hiçbir şey yazılmadan önce reddedilir.

## Ekran görüntüleri

Örnek uygulama, iPhone 18 Pro simülatöründe (iOS 27) ve `jsonplaceholder.typicode.com` adresinden alınan canlı verilerle:

| Ana sayfa | Todos | Todos, koyu | Çevrimdışı |
| --- | --- | --- | --- |
| ![Todos ekranını listeleyen ana sayfa](docs/screenshots/home.png) | ![API'den yüklenen yapılacaklar listesi](docs/screenshots/todos.png) | ![Koyu görünümde yapılacaklar listesi](docs/screenshots/todos-dark.png) | ![Tekrar dene düğmesi olan çevrimdışı mesajı](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) örneği derler ve bu ekran görüntülerini alır. Örneği kendiniz çalıştırmak için:

```sh
cd example
flutter run
```

## Dokümantasyon

- [API referansı ve rehberler](https://muhittincamdali.github.io/FlutterForge/) — `dart doc` ile üretilir ve `main` dalından GitHub Pages'e yayımlanır.
- Yerelde üretmek için `dart doc --output build/doc` komutunu çalıştırın ve `build/doc/index.html` dosyasını açın.
- `forge --help`, `forge create --help` ve `forge feature --help` tüm seçenekleri listeler.

## Rehberler

- [ForgeClient ile bir API çağırma](doc/guides/calling-an-api.md) — tipli istekler, hatalar, yeniden denemeler, önbellek, token'lar, iptal, interceptor'lar ve testler.
- [forge ile uygulama geliştirme](doc/guides/creating-an-app.md) — uygulama oluşturma, yapısını okuma, özellik ekleme, kendi API'nize bağlama ve alan ekleme.
- [İstemcinin nelere karşı koruduğu](doc/guides/security-model.md) — yönlendirmeler, header injection, bellek sınırları, kötü niyetli sayılar ve size kalanlar.

## Gereksinimler

| Araç zinciri | En düşük sürüm |
| --- | --- |
| Dart (kütüphane ve `forge`) | 3.12 |
| Flutter (üretilen uygulamalar) | 3.44 |

Üretilen uygulamalar Riverpod 3.4, go_router 18.1 ve `http` 1.6 kullanır. Paket, Flutter 3.47 ve Dart 3.13 ile geliştirilir ve test edilir; CI en güncel kararlı Flutter sürümünü kullanır.

## Mimari

- `lib/src/network/` — `ForgeClient`, bir taşıma katmanının çevresine bir interceptor zinciri kurar: önce sizin interceptor'larınız, sonra `CacheInterceptor`, `RetryInterceptor` ve `BearerAuthInterceptor`. Taşıma katmanı, yönlendirmeler kapalıyken `package:http` üzerinden tek bir istek gönderir, yönlendirmeleri kendisi izler, süre sınırını `Abortable` isteklerle uygular ve gövdeyi bayt sınırıyla okur. İstekler ve yanıtlar değiştirilemez (immutable) değerlerdir.
- `lib/src/cli/` — `forge`, `package:args` içindeki bir `CommandRunner`'dır. Şablonlar, eksik bir değerde hata veren katı bir `{{key}}` yer değiştiricisiyle işlenen Dart string sabitleridir; adlar herhangi bir dosyaya dokunulmadan önce doğrulanır ve dosyalar yalnızca proje içine yazılır.
- `example/` — `forge create` çıktısıdır ve bu çalışma kopyasına `path: ..` ile bağımlıdır.
- `test/` — istemci için birim testleri (iptali ve akış hâlindeki gövdeleri destekleyen sahte bir `http.Client` ile), CLI için testler (geçici bir klasörde sahte bir process runner ile), README örnekleri ve örneği yeniden üretip dosya dosya karşılaştıran bir test.

Denetimleri yerelde çalıştırın:

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## Yol haritası

- Büyük gövdeler için yükleme ve indirme ilerlemesi.
- `MemoryResponseCache`'in yanında kalıcı bir `ResponseCache` (dosya ya da SQLite).
- Yeni uygulama için daha fazla `forge` şablonu: yerelleştirme ve build flavor'ları.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
