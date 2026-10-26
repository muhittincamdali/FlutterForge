/// A JSON-over-HTTP client for Flutter and Dart apps: interceptors, retries
/// with backoff, a response cache with revalidation, bearer tokens with a
/// shared refresh, time limits, cancellation, a response size limit and safe
/// redirects.
///
/// Start with [ForgeClient]:
///
/// ```dart
/// final client = ForgeClient(baseUrl: 'https://api.example.com/v1');
/// final todos = await client.getJson('/todos', decode: Todo.listFromJson);
/// ```
///
/// The `forge` command, installed with the package, creates Flutter apps that
/// use this client; see the "Building an app with forge" guide.
///
/// {@category calling-an-api}
/// {@category creating-an-app}
/// {@category security-model}
library;

import 'src/network/forge_client.dart';

export 'src/network/api_exception.dart';
export 'src/network/auth.dart';
export 'src/network/cache.dart';
export 'src/network/cache_policy.dart';
export 'src/network/cancel_token.dart';
export 'src/network/forge_client.dart';
export 'src/network/forge_request.dart';
export 'src/network/forge_response.dart';
export 'src/network/interceptor.dart';
export 'src/network/retry.dart';
