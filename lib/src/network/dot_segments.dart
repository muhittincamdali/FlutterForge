import 'unicode_folds.dart';

/// Whether [path] holds a `.` or `..` segment, or one made only of dots, as a
/// server or proxy may read it.
///
/// The path is read the way the most lenient of them would: Unicode text is
/// folded (NFKC_Casefold, then Windows best-fit mapping, from the tables in
/// `unicode_folds.dart`) and escapes are decoded, again and again until
/// nothing changes, so that every order of folding and decoding, and decoding
/// twice, is covered. Only then is the path split into segments. A path that
/// still changes after eight rounds counts as holding a dot segment, so the
/// check takes time linear in the length of the path.
bool hasDotSegment(String path) {
  final read = _readAsServers(path);
  return read == null || read.split(_separator).any(_isDotSegment);
}

// `\` is a separator for IIS and for Uri.parse, which turns it into `/`.
final RegExp _separator = RegExp(r'[/\\]');

// Tomcat reads `..;x` as `..` with a parameter, and a server that decodes the
// path before it splits off the query or the fragment ends it at `?` or `#`.
final RegExp _segmentEnd = RegExp('[;?#]');

// NUL ends a C string; servers and proxies strip or split at the other
// control characters, and IIS and Windows trim spaces from the end of a name.
final RegExp _droppedByServers = RegExp(r'[\s\x00-\x1f\x7f]');

final RegExp _onlyDots = RegExp(r'^\.+$');

bool _isDotSegment(String segment) =>
    _onlyDots.hasMatch(segment.split(_segmentEnd).first.replaceAll(_droppedByServers, ''));

// A server that decodes twice takes two rounds to read, and no path in the
// tests needs more than three rounds that change it. Each round takes time
// linear in the path length, but some escapes peel off one level per round:
// `%u0025u0025…u002e` gives one `%` back for each `%u0025`, and `%%%3325`
// gives `%%325` and then `%25`, because a decoded `3` and the `%` before it
// make a new escape. Without a limit such a path took time quadratic in its
// length.
const int _maxRounds = 8;

// Each round decodes every escape and folds what it produced. Null when the
// path still changes after [_maxRounds] rounds, which is read as a refusal.
String? _readAsServers(String path) {
  var read = _fold(path);
  for (var round = 0; round < _maxRounds; round++) {
    final next = _fold(_percentDecode(read));
    if (next == read) return read;
    read = next;
  }
  return null;
}

final Map<int, String> _foldOf = {
  for (final MapEntry(key: text, value: characters) in foldedTo.entries)
    for (final rune in characters.runes) rune: text,
};

final RegExp _notAscii = RegExp(r'[^\x00-\x7f]');

String _fold(String text) {
  if (!_notAscii.hasMatch(text)) return text;
  final folded = StringBuffer();
  for (final rune in text.replaceAll(foldedAway, '').runes) {
    folded.write(_foldOf[rune] ?? String.fromCharCode(rune));
  }
  return folded.toString();
}

// `%` followed by one or more `25` is read as `%` in one step, so that a
// deeply nested `%2525…2e` takes one round, not one per level.
final RegExp _encodedPercent = RegExp('%(?:25)+', caseSensitive: false);

final RegExp _escape = RegExp('%(?:u([0-9a-f]{4})|([0-9a-f]{2}))', caseSensitive: false);

// Decodes `%XX` and the IIS form `%uXXXX`. Runs of `%XX` bytes are read as
// UTF-8, overlong forms of any length included; a byte that starts no such
// sequence is read as Latin-1, as Tomcat and others do by default.
String _percentDecode(String text) {
  final collapsed = text.replaceAll(_encodedPercent, '%');
  final decoded = <int>[];
  final bytes = <int>[];
  var index = 0;
  for (final escape in _escape.allMatches(collapsed)) {
    if (escape.start > index) {
      _decodeBytes(bytes, decoded);
      decoded.addAll(collapsed.substring(index, escape.start).codeUnits);
    }
    if (escape[1] case final unit?) {
      _decodeBytes(bytes, decoded);
      decoded.add(int.parse(unit, radix: 16));
    } else {
      bytes.add(int.parse(escape[2]!, radix: 16));
    }
    index = escape.end;
  }
  _decodeBytes(bytes, decoded);
  decoded.addAll(collapsed.substring(index).codeUnits);
  return String.fromCharCodes(decoded);
}

void _decodeBytes(List<int> bytes, List<int> decoded) {
  var index = 0;
  while (index < bytes.length) {
    final length = _sequenceLength(bytes[index]);
    final rune = length > 1 ? _sequence(bytes, index, length) : null;
    decoded.add(rune ?? bytes[index]);
    index += rune == null ? 1 : length;
  }
  bytes.clear();
}

// The number of leading one bits of a lead byte: 2 to 6, as in the original
// UTF-8 definition that lenient decoders still follow.
int _sequenceLength(int lead) {
  var length = 0;
  while (length < 7 && lead & (0x80 >> length) != 0) {
    length++;
  }
  return length;
}

int? _sequence(List<int> bytes, int start, int length) {
  if (length > 6 || start + length > bytes.length) return null;
  var rune = bytes[start] & (0x7f >> length);
  for (var index = start + 1; index < start + length; index++) {
    if (bytes[index] & 0xc0 != 0x80) return null;
    rune = rune << 6 | bytes[index] & 0x3f;
  }
  return rune > 0x10ffff ? null : rune;
}
