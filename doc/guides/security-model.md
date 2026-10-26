# What the client guards against

`ForgeClient` is used with tokens, cookies and data typed by users. This page
lists what it does about the common ways those leak or exhaust an app, and
what it leaves to you. Each rule has a test in `test/network/`; the note
about the web describes browser behaviour.

## Credentials stay with their origin

- `BearerAuth` adds the token only to requests whose scheme, host and port
  match the base URL. An absolute URL to a CDN, another port or plain `http`
  on the same host goes out without it.
- The client follows redirects itself (`maxRedirects`, 5 by default). When a
  redirect leaves the origin, `Authorization`, `Cookie` and
  `Proxy-Authorization` are removed, and a request body (a `307`/`308`
  `POST`, for example) is not sent to the new origin at all: the call fails
  with `RedirectException`.
- A redirect from `https` to `http`, to a scheme other than `http`/`https`
  (`javascript:`, `file:`), or to a URL with a user name and password is
  refused.
- On the web, the browser follows redirects before the client sees them and
  applies its own rules (the Fetch standard also drops `Authorization` on a
  cross-origin redirect); the rules above apply on Android, iOS, macOS,
  Windows, Linux and the Dart VM.

## Paths cannot climb out of the base URL

Relative paths are appended to the base path, and a path with a `.` or `..`
segment is refused with an `ArgumentError` before anything is sent. Code such
as `client.getJson('/files/$name', …)` therefore cannot be turned into a
request for `/admin` (with the user's token) by a `name` of `../../admin`.

The check reads segments the way servers may read them: it splits at `/`,
`\` (which `Uri.parse` turns into `/`), `%2f` and `%5c`, treats `%2e` as `.`,
and ignores a `;` parameter, so `..\admin`, `..%2fadmin` and the Tomcat-style
`..;/admin` are refused too. The joined URL must also still start with the
base path. A path with two leading slashes stays on the base host.

## Headers cannot be injected

`ForgeRequest` rejects a method or header name that is not an HTTP token and a
header value containing a carriage return, a line feed or a NUL character.
A value read from user input — a search term placed in a header, a token
pasted from a clipboard — cannot start a second header line.

## Memory stays bounded

- `maxResponseBytes` (16 MiB by default) caps every body. A `Content-Length`
  above it is refused before reading; a body without a length, or one that
  never ends, is cut at the limit and the connection is aborted.
- `MemoryResponseCache` is bounded by entry count and total bytes and evicts
  the least recently used entries. An entry larger than the byte limit is
  never stored.
- Every attempt has a time limit, and `CancelToken` and the time limit both
  abort the connection (with the `dart:io` and browser clients of
  `package:http`).
- A finished request stops listening to its `CancelToken`, so one token can
  be shared by every request of a screen, or of the whole app, without
  keeping those requests and their bodies in memory.

## Numbers from the server cannot break the client

`Retry-After` and `Cache-Control: max-age` are read as at most ten digits; a
longer number, a negative one, `NaN` or `1e3` is ignored instead of
overflowing. Retry backoff is computed with integers and an overflow check,
and `maxAttempts` is clamped to 1–10, so no configuration gives an infinite or
negative wait.

## Errors do not copy secrets into logs

`ApiException.toString()` and `ForgeRequest.toString()` print only the method,
scheme, host and port — never the path, query, headers or body, which can hold
identifiers and tokens. The full request and response remain available on the
exception object for code that needs them.

## What FlutterForge does not do

- **It ships no request logger.** Logging requests safely means masking
  tokens, passwords and personal data in headers, URLs and bodies, which is a
  separate problem from making requests. If you add an `Interceptor` that
  logs, log the method, host and status code, not headers or bodies.
- **It does not pin certificates.** Use the platform clients
  (`cupertino_http`, `cronet_http`) or a `dart:io` `SecurityContext` passed to
  an `IOClient` if you need pinning.
- **The cache is keyed by URL only.** Responses that differ per user are
  shared across users of the same client; call `cache.clear()` on sign-out, or
  use `CachePolicy.noCache` for such requests.
- **A `TokenRefresher` that throws** passes its error to the caller; decide in
  your refresher whether to sign the user out.

## Reporting a problem

See the [security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).
