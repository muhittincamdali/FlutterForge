// Writes lib/src/network/unicode_folds.dart, the table ForgeClient.resolve
// uses to read a path the way a server that folds Unicode text may read it.
//
// Usage, from the package root, with the data files in one folder: Unicode
// 18.0.0 DerivedNormalizationProps.txt from
// https://www.unicode.org/Public/18.0.0/ucd/DerivedNormalizationProps.txt and
// every bestfit<code page>.txt file listed at
// https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WindowsBestFit/
//
//   dart run tool/generate_unicode_folds.dart <folder>
//   dart format lib/src/network/unicode_folds.dart
//
// A character is listed when NFKC_Casefold removes it, or when NFKC_Casefold
// followed by the Windows best-fit mapping of one of the code pages, or that
// mapping alone, turns it into text that holds `/`, `\` or `.`, into text
// that the check drops (control characters and spaces), or into text made
// only of characters that build an escape or end a segment (`%`, hex digits,
// `u`, `;`, `?`, `#`). NFKC_Casefold applies NFKC, so every character whose
// NFKC or NFKD form holds `/`, `\` or `.` is listed; case folding only lowers
// letters. A character with several such readings keeps the one ranked
// highest by [_rank]; code pages that disagree on `/`, `\` or `.` stop the
// generator.
import 'dart:convert';
import 'dart:io';

const _output = 'lib/src/network/unicode_folds.dart';
const _pathCharacters = r'/\.';
const _escapeCharacters = '%0123456789abcdefABCDEFuU;?#';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('usage: dart run tool/generate_unicode_folds.dart <folder with the data files>');
    exit(64);
  }
  final folder = Directory(arguments.single);
  final normalization = File('${folder.path}/DerivedNormalizationProps.txt').readAsLinesSync();
  final version = RegExp(r'DerivedNormalizationProps-([\d.]+)\.txt').firstMatch(normalization.first)!.group(1)!;
  final casefold = _readCasefold(normalization);
  final bestFit = _readBestFit(folder);

  String bestFitted(String text) =>
      String.fromCharCodes(text.runes.expand((rune) => (bestFit[rune] ?? String.fromCharCode(rune)).runes));
  final removed = <int>[];
  final folds = <int, String>{};
  for (final rune in {...casefold.keys, ...bestFit.keys}) {
    if (rune < 0x80) continue;
    final readings = [bestFitted(casefold[rune] ?? String.fromCharCode(rune)), ?bestFit[rune]];
    final folded = readings.reduce((best, reading) => _rank(reading) > _rank(best) ? reading : best);
    if (folded.isEmpty) {
      removed.add(rune);
    } else if (_rank(folded) > 0) {
      folds[rune] = folded;
    }
  }
  _check(folds);
  File(_output).writeAsStringSync(_render(version, removed..sort(), folds));
  stdout.writeln('$_output: Unicode $version, ${removed.length} removed, ${folds.length} folded.');
}

// 3: holds a path character; 2: dropped by the check (removed, or only
// control characters and spaces); 1: only characters of an escape or of a
// segment end; 0: none of these, so the character is not listed.
int _rank(String text) {
  final characters = text.split('');
  if (characters.any(_pathCharacters.contains)) return 3;
  if (characters.every((c) => c.codeUnitAt(0) <= 0x20 || c.codeUnitAt(0) == 0x7f)) return 2;
  if (characters.every(_escapeCharacters.contains)) return 1;
  return 0;
}

// Folding twice must give the same text, or a server that folds once and
// the check, which folds until nothing changes, would read a path apart.
// ForgeClient also reads a path again until it stops changing; that ends
// because every decoded escape removes a `%`, unless it gives one back, and
// then the path is shorter. A fold may therefore make a `%` only on its own.
void _check(Map<int, String> folds) {
  for (final MapEntry(key: rune, value: folded) in folds.entries) {
    final again = folded.runes.map((r) => folds[r] ?? String.fromCharCode(r)).join();
    if (again != folded || (folded.contains('%') && folded != '%')) {
      throw StateError('U+${rune.toRadixString(16)} folds to "$folded", which folds again or holds a %.');
    }
  }
}

// Lines look like `FF0F ; NFKC_CF; 002F # ...`, `00AD ; NFKC_CF; # ...` or
// `E0000..E0FFF ; NFKC_CF; # ...`; an empty mapping removes the character.
Map<int, String> _readCasefold(List<String> lines) {
  final casefold = <int, String>{};
  for (final line in lines) {
    final fields = line.split('#').first.split(';').map((field) => field.trim()).toList();
    if (fields.length < 3 || fields[1] != 'NFKC_CF') continue;
    final range = fields[0].split('..').map((hex) => int.parse(hex, radix: 16)).toList();
    final mapped = fields[2].isEmpty
        ? ''
        : String.fromCharCodes(fields[2].split(' ').map((hex) => int.parse(hex, radix: 16)));
    for (var rune = range.first; rune <= range.last; rune++) {
      casefold[rune] = mapped;
    }
  }
  return casefold;
}

// Only the WCTABLE section maps Unicode to the code page; a target below 0x80
// is the ASCII character itself in every one of these code pages. Where code
// pages disagree, the reading ranked highest is kept, else the first one.
Map<int, String> _readBestFit(Directory folder) {
  final bestFit = <int, String>{};
  final tables =
      folder.listSync().whereType<File>().where((file) => RegExp(r'bestfit\d+\.txt$').hasMatch(file.path)).toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final table in tables) {
    var inUnicodeTable = false;
    for (final line in latin1.decode(table.readAsBytesSync()).split('\n')) {
      final fields = line.split(';').first.trim().split(RegExp(r'\s+'));
      if (fields.first.isEmpty) continue;
      if (RegExp('^[A-Z]').hasMatch(fields.first)) {
        inUnicodeTable = fields.first == 'WCTABLE';
        continue;
      }
      if (!inUnicodeTable || fields.length < 2) continue;
      final rune = int.parse(fields[0]);
      final target = int.parse(fields[1]);
      if (target >= 0x80 || rune == target) continue;
      final previous = bestFit[rune];
      final mapped = String.fromCharCode(target);
      if (previous == null || _rank(mapped) > _rank(previous)) {
        bestFit[rune] = mapped;
      } else if (previous != mapped && _rank(mapped) == 3 && _rank(previous) == 3) {
        throw StateError('U+${rune.toRadixString(16)} best-fits to both "$previous" and "$mapped".');
      }
    }
  }
  return bestFit;
}

String _render(String version, List<int> removed, Map<int, String> folds) {
  final byText = <String, List<int>>{};
  for (final MapEntry(key: rune, value: folded) in folds.entries) {
    byText.putIfAbsent(folded, () => []).add(rune);
  }
  final texts = byText.keys.toList()..sort();
  final out = StringBuffer()
    ..writeln('// Written by tool/generate_unicode_folds.dart from the Unicode $version')
    ..writeln('// DerivedNormalizationProps.txt and the Windows best-fit tables. Do not edit.')
    ..writeln()
    ..writeln('/// The Unicode version that [foldedAway] and [foldedTo] come from.')
    ..writeln("const String unicodeFoldsVersion = '$version';")
    ..writeln()
    ..writeln('/// The characters that NFKC_Casefold removes: the default ignorable code points.')
    ..writeln("final RegExp foldedAway = RegExp(${_literal('[${_ranges(removed)}]')}, unicode: true);")
    ..writeln()
    ..writeln('/// Each text that a server reading a path may make of a character, mapped to the')
    ..writeln('/// characters it makes it of, by NFKC_Casefold and then Windows best-fit mapping.')
    ..writeln('const Map<String, String> foldedTo = {');
  for (final text in texts) {
    final runes = byText[text]!..sort();
    out.writeln("  '${_escape(text.runes)}': ${_literal(_escape(runes))},");
  }
  out.writeln('};');
  return out.toString();
}

String _ranges(List<int> runes) {
  final out = StringBuffer();
  var start = 0;
  while (start < runes.length) {
    var end = start;
    while (end + 1 < runes.length && runes[end + 1] == runes[end] + 1) {
      end++;
    }
    out.write(_escape([runes[start]]));
    if (end > start) out.write('-${_escape([runes[end]])}');
    start = end + 1;
  }
  return out.toString();
}

// Adjacent string literals of at most 96 characters, split between escapes,
// so that the formatter can keep the lines short.
String _literal(String escaped) {
  final pieces = <String>[];
  var piece = '';
  for (final token in RegExp(r'\\u\{[0-9A-F]+\}|.').allMatches(escaped).map((match) => match[0]!)) {
    if (piece.length + token.length > 96) {
      pieces.add(piece);
      piece = '';
    }
    piece += token;
  }
  return [...pieces, piece].map((piece) => "'$piece'").join(' ');
}

// Every character as an escape, so the file is ASCII and shows the code
// points; printable ASCII other than quotes and backslashes stays readable.
String _escape(Iterable<int> runes) => runes.map((rune) {
  if (rune >= 0x20 && rune < 0x7f && !r"'\$".contains(String.fromCharCode(rune))) {
    return String.fromCharCode(rune);
  }
  return '\\u{${rune.toRadixString(16).toUpperCase()}}';
}).join();
