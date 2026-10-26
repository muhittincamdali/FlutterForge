# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-26

Version 2.0.0 is a rewrite. The 1.0.0 sources did not pass `flutter analyze` on any
Flutter release from 3.24 to 3.47, so none of their API could be used; it has been removed
rather than kept for compatibility. The HTTP client merges the useful parts of
[FlutterNetworkKit](https://github.com/muhittincamdali/FlutterNetworkKit), which had the same
problem and is no longer developed.

### Added

- `ForgeClient`, a JSON-over-HTTP client on `package:http` with `getJson`, `postJson`,
  `putJson`, `patchJson`, `delete`, `request` and `send`, base URL joining and query encoding.
- `postForm` for URL-encoded forms and `postMultipart` for `multipart/form-data` uploads
  (`MultipartFile` is re-exported from `package:http`).
- `ForgeRequest` and `ForgeResponse`, immutable values with lower-case headers.
- `ApiException`, a sealed family: `ConnectionException`, `RequestTimeoutException`,
  `RequestCancelledException`, `HttpStatusException`, `DecodingException`,
  `ResponseTooLargeException` and `RedirectException`, each with `isTransient`.
- `Interceptor` and `Interceptor.from` for middleware around every request.
- `RetryPolicy` and `RetryInterceptor`: idempotent methods only by default, jittered
  exponential backoff, `Retry-After` in seconds or as an HTTP date.
- `CachePolicy`, `ResponseCache`, `MemoryResponseCache` and `CacheInterceptor`: `networkFirst`
  with offline fallback and `cacheFirst` with `ETag` / `Last-Modified` revalidation.
- `BearerAuth` and `BearerAuthInterceptor`: tokens for the API origin only, one shared refresh
  for concurrent `401` answers, at most one retry per request.
- `CancelToken`, a per-attempt `timeout` and `maxResponseBytes`, all of which abort the
  connection when the `http` client supports `Abortable` requests. `CancelToken.onCancel`
  adds a callback that can be removed again.
- The `forge` command: `forge create` for a feature-first Flutter app (Riverpod 3,
  go_router 18, `ForgeClient`, tests for every layer, a GitHub Actions workflow and Dependabot
  settings) and `forge feature` to add a feature with its route and tests.
- An example app in `example/` that is the exact output of `forge create`, three guides in
  `doc/guides/`, API documentation on GitHub Pages, and simulator screenshots made by
  `scripts/screenshots.sh`.

### Security

- Header names and methods must be HTTP tokens and header values cannot contain CR, LF or NUL.
- Relative paths with `.` or `..` segments are refused, so user input in a path cannot leave
  the base URL. Segments are split at `/`, `\`, `%2f` and `%5c`, `%2e` counts as `.` and a
  `;` parameter is ignored.
- Redirects are followed by the client: `https` to `http`, other schemes and URLs with user
  information are refused; `Authorization`, `Cookie` and `Proxy-Authorization` are removed when
  the origin changes, and a request body is never resent to another origin.
- Response bodies, the response cache, `Retry-After` and `max-age` values and the retry
  backoff are all bounded, so a hostile or broken server cannot exhaust memory or produce an
  overflowing delay.
- Exception messages name only the method and host.
- `forge` validates every name, organisation, description and path before it runs a program
  or writes a file, and writes only inside the project folder.

### Removed

- Every 1.0.0 library: the architecture base classes, the Dio-based API client, storage,
  routing, theming, localization, FFI and isolate helpers, and the `flutter_forge` executable
  with its `generate` commands. Use `forge feature` instead of `generate`.

## [1.0.0] - 2026-02-03

### Added

- First release of the project template and its CLI.

[Unreleased]: https://github.com/muhittincamdali/FlutterForge/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/FlutterForge/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/FlutterForge/releases/tag/v1.0.0
