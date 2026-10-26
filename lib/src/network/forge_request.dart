import 'dart:typed_data';

import 'cache_policy.dart';
import 'cancel_token.dart';

/// Methods that a server must treat as safe to repeat (RFC 9110, section 9.2.2).
///
/// The retry interceptor only repeats these unless told otherwise.
const Set<String> idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE', 'TRACE'};

final RegExp _token = RegExp(r"^[!#$%&'*+\-.^_`|~0-9A-Za-z]+$");

/// One HTTP request as it travels through the interceptors of a
/// `ForgeClient`.
///
/// A request is immutable: an interceptor that needs a different header or
/// URL calls [copyWith] or [withHeaders] and passes the copy on. The body is
/// kept as bytes, so the same request can be sent again by the retry logic.
///
/// Header names are stored in lower case. The constructor rejects a method or
/// header name that is not an HTTP token and a header value that contains a
/// line break or a NUL character, so a value read from user input cannot add
/// a header of its own.
final class ForgeRequest {
  /// Creates a request.
  ///
  /// Throws an [ArgumentError] when [uri] is not an absolute `http` or
  /// `https` URL, when it contains user information (`user:password@`), or
  /// when a method, header name or header value is invalid.
  ForgeRequest({
    required String method,
    required this.uri,
    Map<String, String> headers = const {},
    Uint8List? body,
    this.cachePolicy = CachePolicy.noCache,
    this.cancelToken,
    this.timeout,
  }) : method = _checkedMethod(method),
       headers = Map.unmodifiable(_checkedHeaders(headers)),
       body = body ?? Uint8List(0) {
    if (!(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
      throw ArgumentError.value(uri.scheme, 'uri', 'must be an absolute http or https URL');
    }
    // The message does not repeat the URL: the user information is a secret.
    if (uri.userInfo.isNotEmpty) {
      throw ArgumentError('The URL must not contain user information.', 'uri');
    }
    final limit = timeout;
    if (limit != null && limit <= Duration.zero) {
      throw ArgumentError.value(limit, 'timeout', 'must be positive');
    }
  }

  /// The method in upper case, such as `GET` or `POST`.
  final String method;

  /// The absolute URL.
  final Uri uri;

  /// The headers, with lower-case names.
  final Map<String, String> headers;

  /// The body; empty when the request has none.
  final Uint8List body;

  /// How a cache interceptor may answer this request.
  final CachePolicy cachePolicy;

  /// Cancels the request when its `cancel` method is called.
  final CancelToken? cancelToken;

  /// The time limit for one attempt, or `null` for the client's default.
  final Duration? timeout;

  /// Whether repeating the request is safe according to its method.
  bool get isIdempotent => idempotentMethods.contains(method);

  /// The value of the header [name], compared without regard to case.
  String? header(String name) => headers[name.toLowerCase()];

  /// Returns a copy with the given fields replaced.
  ForgeRequest copyWith({
    String? method,
    Uri? uri,
    Map<String, String>? headers,
    Uint8List? body,
    CachePolicy? cachePolicy,
  }) {
    return ForgeRequest(
      method: method ?? this.method,
      uri: uri ?? this.uri,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      cachePolicy: cachePolicy ?? this.cachePolicy,
      cancelToken: cancelToken,
      timeout: timeout,
    );
  }

  /// Returns a copy with [add] set (replacing headers of the same name) and
  /// every header named in [remove] taken out.
  ForgeRequest withHeaders({Map<String, String> add = const {}, Iterable<String> remove = const []}) {
    final next = Map<String, String>.of(headers);
    for (final name in remove) {
      next.remove(name.toLowerCase());
    }
    for (final MapEntry(:key, :value) in add.entries) {
      next[key.toLowerCase()] = value;
    }
    return copyWith(headers: next);
  }

  /// The method, scheme, host and port, for messages. The path and query are
  /// left out because they can carry identifiers or tokens.
  ///
  /// The host is written only when it is a plain DNS name, an IPv4 address or
  /// an IPv6 address without a zone, nothing in it names a secret, and
  /// nothing in it looks like one.
  ///
  /// A label names a secret when it holds `password`, `token`, `secret`,
  /// `apikey`, `cookie`, `signature` or another long secret name anywhere,
  /// also across a `-` (`db-password`), or when one of its words, split at
  /// `-` and between letters and digits, is a short one such as `pin`,
  /// `key`, `pass`, `auth`, `card`, `otp`, `cvv` or `session`. The value can
  /// sit right next to the name (`pin-4831.example.com`,
  /// `password.hunter2.example`), so such a host is not written, even an
  /// ordinary one such as `auth.example.com`. A short name inside a longer
  /// word (`spin`, `monkey`) names nothing.
  ///
  /// A host looks like a secret when it holds:
  ///
  /// * a card number: 13 or more digits, which may be grouped with `-`;
  /// * an IBAN: two letters, two check digits and 11 to 30 letters and
  ///   digits that pass the mod-97 check;
  /// * a key: 32 or more hexadecimal digits, or 32 or more letters, digits
  ///   and `-` that mix letters and digits, as a base64url token is written
  ///   (a UUID is not counted);
  /// * a JSON Web Token: a label that starts with `eyJ`, followed by a label
  ///   of 4 or more characters.
  ///
  /// `Uri` stores a host in lower case, so the IBAN and the token are found
  /// in either case. Any other host, such as `h.example;password=hunter2`, is
  /// written as `[R]`, followed by nothing: `GET https://[R]`.
  String describe() => '$method ${_describeOrigin(uri)}';

  @override
  String toString() => 'ForgeRequest(${describe()})';
}

final RegExp _dnsLabel = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$');
final RegExp _ipv6 = RegExp(r'^[0-9A-Fa-f:.]+$');
// A card number: 13 or more digits, in groups joined by up to three `-`.
final RegExp _cardNumber = RegExp(r'(?<![A-Za-z0-9])\d(?:-{0,3}\d){12,}(?![A-Za-z0-9])');
// A key: 32 or more hexadecimal digits, or 32 or more base64url characters
// with at least one letter and one digit (`-` counts, `_` cannot occur in a
// label that passed _dnsLabel), as keys are written in a host. A UUID, which
// is hexadecimal with four `-`, is not a key.
final RegExp _longHex = RegExp(r'[0-9A-Fa-f]{32,}');
final RegExp _longToken = RegExp(r'[A-Za-z0-9-]{32,}');
final RegExp _uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
final RegExp _letter = RegExp('[A-Za-z]');
final RegExp _digit = RegExp('[0-9]');
// An IBAN: country code, two check digits and 11 to 30 letters and digits,
// 15 to 34 in all, not joined to other letters or digits. Hosts are lower
// case, so both cases count; the mod-97 check keeps ordinary names out.
final RegExp _iban = RegExp(r'(?<![A-Za-z0-9])[A-Za-z]{2}[0-9]{2}[A-Za-z0-9]{11,30}(?![A-Za-z0-9])');
// A JSON Web Token: `eyJ` and at least one more character, a `.`, and a
// second segment of 4 or more characters. The dots of a token split it into
// host labels, so this runs on the whole host.
final RegExp _jsonWebToken = RegExp(r'(?<![A-Za-z0-9])eyj[A-Za-z0-9-]+\.[A-Za-z0-9-]{4,}', caseSensitive: false);
const int _maxHostLength = 253;
// A host can hold a secret next to the name of one (`pin-4831.example.com`,
// `password.hunter2.example`), so a host that names a secret is not written.
// The secret names of the redaction rules, with `_` and `-` removed: these
// count anywhere in a label, also with its `-` removed (`db-password`) ...
const List<String> _secretNamesAnywhere = [
  'password',
  'passwd',
  'passphrase',
  'passcode',
  'secret',
  'token',
  'apikey',
  'accesskey',
  'authkey',
  'privatekey',
  'secretkey',
  'authorization',
  'credential',
  'cookie',
  'signature',
  'sessionid',
  'sessionkey',
  'sessid',
  'pincode',
  'otpcode',
  'authcode',
  'securitycode',
  'verificationcode',
  'cardnumber',
];
// ... and these short ones only as a whole word, so that `spin` and `monkey`
// are written. Words are split at `-` and between letters and digits.
const Set<String> _secretWords = {
  'pwd',
  'pw',
  'pass',
  'key',
  'pin',
  'otp',
  'cvv',
  'cvc',
  'ssn',
  'iban',
  'card',
  'auth',
  'sid',
  'session',
};
final RegExp _wordBreak = RegExp('-|(?<=[a-z])(?=[0-9])|(?<=[0-9])(?=[a-z])');

// The scheme, host and port of `uri` for a message, with a host that is not
// a plain name or address written as `[R]`; see ForgeRequest.describe.
String _describeOrigin(Uri uri) {
  final host = uri.host;
  final port = uri.hasPort ? ':${uri.port}' : '';
  if (host.contains(':')) {
    return _ipv6.hasMatch(host) ? '${uri.scheme}://[$host]$port' : '${uri.scheme}://[R]';
  }
  final labels = host.split('.');
  final plain =
      host.length <= _maxHostLength &&
      labels.every(_dnsLabel.hasMatch) &&
      !labels.any(_looksLikeSecret) &&
      !labels.any(_namesSecret) &&
      !_jsonWebToken.hasMatch(host);
  return plain ? '${uri.scheme}://$host$port' : '${uri.scheme}://[R]';
}

bool _looksLikeSecret(String label) {
  if (_cardNumber.hasMatch(label) || _longHex.hasMatch(label)) return true;
  if (_iban.allMatches(label).any((match) => _passesMod97(match[0]!))) return true;
  return _longToken
      .allMatches(label)
      .map((match) => match[0]!)
      .any((run) => _letter.hasMatch(run) && _digit.hasMatch(run) && !_uuid.hasMatch(run));
}

bool _namesSecret(String label) {
  final folded = label.replaceAll('-', '');
  return _secretNamesAnywhere.any(folded.contains) || label.split(_wordBreak).any(_secretWords.contains);
}

// ISO 13616: the first four characters move to the end, letters become
// 10 to 35, and the number is 1 modulo 97.
bool _passesMod97(String iban) {
  final rearranged = (iban.substring(4) + iban.substring(0, 4)).toUpperCase();
  var remainder = 0;
  for (final unit in rearranged.codeUnits) {
    final value = unit <= 0x39 ? unit - 0x30 : unit - 0x41 + 10;
    remainder = (remainder * (value < 10 ? 10 : 100) + value) % 97;
  }
  return remainder == 1;
}

String _checkedMethod(String method) {
  if (!_token.hasMatch(method)) {
    throw ArgumentError.value(method, 'method', 'is not an HTTP token');
  }
  return method.toUpperCase();
}

Map<String, String> _checkedHeaders(Map<String, String> headers) {
  final checked = <String, String>{};
  for (final MapEntry(:key, :value) in headers.entries) {
    if (!_token.hasMatch(key)) {
      throw ArgumentError.value(key, 'headers', 'has a name that is not an HTTP token');
    }
    if (value.contains('\r') || value.contains('\n') || value.contains('\u0000')) {
      throw ArgumentError('The value of header "$key" contains a line break or NUL character.', 'headers');
    }
    checked[key.toLowerCase()] = value;
  }
  return checked;
}
