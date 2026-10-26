/// A JSON-over-HTTP client for Flutter and Dart apps: interceptors, retries
/// with backoff, time limits, cancellation, a response size limit and safe
/// redirects.
///
/// Start with [ForgeClient]:
///
/// ```dart
/// final client = ForgeClient(baseUrl: 'https://api.example.com/v1');
/// final todos = await client.getJson('/todos', decode: Todo.listFromJson);
/// ```
library;

import 'src/network/forge_client.dart';

export 'src/network/api_exception.dart';
export 'src/network/cache_policy.dart';
export 'src/network/cancel_token.dart';
export 'src/network/forge_client.dart';
export 'src/network/forge_request.dart';
export 'src/network/forge_response.dart';
export 'src/network/interceptor.dart';
export 'src/network/retry.dart';
