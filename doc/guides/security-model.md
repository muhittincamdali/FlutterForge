# What the client guards against

`ForgeClient` is used with tokens, cookies and data typed by users. This page
lists what it does about the common ways those leak or exhaust an app, and
what it leaves to you. Each rule has a test in `test/network/`; the note
about the web describes browser behaviour.

## Credentials stay with their origin

- `BearerAuth` adds the token only to requests whose scheme, host and port
  match the base URL. An absolute URL to a CDN, another port or plain `http`
  on the same host goes out without it.
- The default `headers` given to `ForgeClient` are not bound to an origin:
  they go with every request, also to an absolute URL on another host. Keep
  an API key such as `x-api-key` out of them when the client also calls other
  origins, and add it per request or in an `Interceptor` that checks
  `request.uri` first.
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

The check reads segments the way the most lenient server or proxy may read
them, and then splits them at `/` and `\` (which `Uri.parse` turns into
`/`). Before the split it decodes escapes: `%2e` and `%2f`, the IIS forms
`%u002e` and `%u002f`, UTF-8, including the overlong forms that lenient
decoders accept (`..%c0%afadmin`, `..%f0%80%80%afadmin`), and `%25`, for
servers that decode a path twice (`%252e%252e/admin`); a byte that starts no
UTF-8 sequence is read as Latin-1. It also folds Unicode text with
NFKC_Casefold and with the best-fit mapping of the Windows code pages,
and repeats decoding and folding until nothing changes, so the order in which
a server does them does not matter (`..％２ｆadmin` is `..%2fadmin`). A path
that still changes after eight rounds is refused: some escapes give back a new
escape each round (`%u0025u0025…u002e`, or `%%%3325`, which decodes to
`%%325` and then to `%25`), and reading such a path to the end took time
quadratic in its length.

The fold tables in `lib/src/network/unicode_folds.dart` are produced by
`tool/generate_unicode_folds.dart` from the Unicode 18.0.0
`DerivedNormalizationProps.txt` and the Windows best-fit tables, not written
by hand. They hold every character that these mappings turn into text with
`/`, `\` or `.` (the full-width `／`, `＼` and `．`, the small `﹨` and `﹒`,
the fraction slash `⁄`, the division slash `∕`, the yen and won signs, which
Japanese and Korean Windows map to `\`, the two-dot leader `‥` and the
ellipsis `…`), every character they turn into the parts of an escape (the
full-width `％` and digits), and every character that NFKC_Casefold removes:
the soft hyphen, zero-width characters and joiners, bidirectional marks,
variation selectors and the byte order mark (`..%c2%ad/admin`,
`..%e2%80%8e/admin`). `test/network/dot_segments_test.dart` checks each of
them raw, as a `%u` escape, as UTF-8 in both cases, as an overlong form, with
an encoded `%` and written with full-width characters. A few characters are
mapped differently by different code pages; where none of those readings is
`/`, `\` or `.`, the table keeps one of them (a character the check drops
before a part of an escape), so a server using the other code page may read
such a character differently.

A segment ends at a `;` parameter, so the Tomcat-style `..;/admin` is
refused, and at `?` and `#`, for a server or proxy that decodes the path
before it splits off the query or the fragment (`..%3f/admin`). NUL and the
other control characters, which C code stops at and servers strip or split
at (`..%00/admin`, `..%0a/admin`), and spaces including the no-break space,
which IIS trims (`.. /admin`, `..%c2%a0/admin`), are dropped. A segment made
only of dots, such as `...`, is refused as well. The same check runs a second
time on the path that is sent: `Uri.parse` decodes escapes of letters and
digits and encodes a `%` that starts no escape, so `%25%32%65` and `%2%65`
both leave as `%252e`, which a server that decodes twice reads as `.`. The joined URL must
also still start with the base path. A path with two leading slashes stays on the base host.

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

- A URL with user information (`https://user:password@host`) is refused by
  `ForgeRequest` and `resolve`, and the error does not repeat it.
- The host is printed only when it is a plain DNS name, an IPv4 address or an
  IPv6 address without a zone, nothing in it names a secret, and nothing in
  it looks like one.

  A host can carry a secret right next to its name, as in
  `pin-4831.example.com`, `token-abc123.example.com` or
  `password.hunter2.example`, so a host is printed as `[R]` when a label
  holds `password`, `token`, `secret`, `apikey`, `cookie`, `signature` or
  another long secret name anywhere, also across a `-` (`db-password`), or
  when one of its words, split at `-` and between letters and digits, ends
  with a short name such as `pin`, `key`, `auth`, `card`, `otp`, `cvv` or
  `bearer` (`userpin`, `mykey`), or is `pass`, `pw`, `sid` or `session`. An
  `s` after a name counts as a plural (`pins-4831`, `cards-4111`). That also
  hides ordinary hosts such as `auth.example.com`, `spin.example.com` and
  `monkey.example.com`. A short name at the start or in the middle of a word
  (`pinto`, `keyboard`, `passage`, `bypass`) names nothing.

  A host looks like a secret when it holds:
  - a card number: 13 or more digits, also when grouped with `-` as in
    `4111-1111-1111-1111`;
  - an IBAN: two letters, two check digits and 11 to 30 letters and digits
    that pass the mod-97 check, as in `GB82WEST12345698765432`;
  - a key: 32 or more hexadecimal digits, or 32 or more letters, digits and
    `-` that mix letters and digits, as a base64url token does
    (`abcd1234-efgh5678-ijkl9012-mnop3456`); a UUID is not counted;
  - a JSON Web Token: a label that starts with `eyJ`, followed by a label of
    4 or more characters, as in `eyJhbGci.eyJzdWIi.example.com`.

  `Uri` stores hosts in lower case, so the IBAN and token rules ignore case;
  a lower-cased value is still readable and is not printed. Every other host
  is printed as `[R]`: a failed call to
  `https://h.example;password=hunter2/db` reads
  `HttpStatusException: GET https://[R] answered 500`. The rules can hide an
  ordinary name that has the same shape, such as a 32-character label with
  letters and digits, which is the safer mistake.

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
