import 'dart:convert';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_forge/src/network/unicode_folds.dart';
import 'package:test/test.dart';

// Every way these tests write one character in a path: raw, as an IIS `%u`
// escape, as UTF-8 escapes in either case, as an overlong UTF-8 form one byte
// longer than needed, with the `%` itself encoded, and with full-width `％`
// and hex digits, which NFKC turns back into an escape.
final Map<String, String Function(int)> encodings = {
  'raw': String.fromCharCode,
  '%u': (rune) => String.fromCharCode(rune).codeUnits.map((unit) => '%u${_hex(unit, 4)}').join(),
  'UTF-8': (rune) => _escapes(utf8.encode(String.fromCharCode(rune))),
  'UTF-8, upper case': (rune) => _escapes(utf8.encode(String.fromCharCode(rune))).toUpperCase(),
  'overlong UTF-8': (rune) => _escapes(_overlong(rune)),
  'encoded %': (rune) => _escapes(utf8.encode(String.fromCharCode(rune))).replaceAll('%', '%25'),
  'full-width escape': (rune) => _fullWidth(_escapes(utf8.encode(String.fromCharCode(rune)))),
};

String _hex(int value, int width) => value.toRadixString(16).padLeft(width, '0');

String _escapes(List<int> bytes) => bytes.map((byte) => '%${_hex(byte, 2)}').join();

String _fullWidth(String ascii) => String.fromCharCodes(ascii.runes.map((rune) => rune + 0xFEE0));

// The shortest UTF-8 form has one byte for 7 bits, two for 11, three for 16
// and four for 21; one byte more always has room for the value.
List<int> _overlong(int rune) {
  final length = rune < 0x80 ? 2 : (rune < 0x800 ? 3 : (rune < 0x10000 ? 4 : 5));
  final continuation = [for (var i = length - 2; i >= 0; i--) 0x80 | (rune >> (6 * i)) & 0x3F];
  final lead = (0xFF << (8 - length)) & 0xFF | rune >> (6 * (length - 1));
  return [lead, ...continuation];
}

void main() {
  final client = ForgeClient(baseUrl: 'https://api.example.com/v1/');

  bool refused(String path) {
    try {
      client.resolve(path);
      return false;
    } on ArgumentError {
      return true;
    }
  }

  test('refuses the small reverse solidus, which NFKC turns into a backslash', () {
    for (final path in [
      '..﹨admin',
      '/..%ef%b9%a8admin',
      '/..%EF%B9%A8admin',
      '..%ufe68admin',
      '..%25ef%25b9%25a8admin',
    ]) {
      expect(() => client.resolve(path), throwsArgumentError, reason: path);
    }
    expect(client.resolve('/files/a﹨b').path, '/v1/files/a%EF%B9%A8b');
  });

  test('refuses the vertical two-dot leader and ellipsis, which NFKC turns into dots', () {
    for (final path in ['/︰/admin', '/%ef%b8%b0/admin', '/︙/admin', '/%ufe19/admin']) {
      expect(() => client.resolve(path), throwsArgumentError, reason: path);
    }
  });

  test('refuses slashes that Windows best-fit mapping makes of the fraction slash, yen and won signs', () {
    for (final path in ['..⁄admin', '/..%e2%81%84admin', '..¥admin', '/..%c2%a5admin', '..₩admin', '..￥admin']) {
      expect(() => client.resolve(path), throwsArgumentError, reason: path);
    }
    expect(client.resolve('/prices/¥100').path, '/v1/prices/%C2%A5100');
  });

  test('refuses dot segments hidden by any character that NFKC_Casefold removes', () {
    for (final path in [
      '/..%e2%80%8e/admin',
      '/..\u200F/admin',
      '/..\u202A/admin',
      '/.\u034F./admin',
      '/..%ef%b8%8f/admin',
    ]) {
      expect(() => client.resolve(path), throwsArgumentError, reason: path);
    }
  });

  test('refuses overlong UTF-8 forms of any length and escapes written in full-width characters', () {
    for (final path in [
      '..%f0%80%80%afadmin',
      '/%f0%80%80%ae%f0%80%80%ae/admin',
      '..%f8%80%80%80%afadmin',
      '..%fc%80%80%80%80%afadmin',
      '/％２ｅ％２ｅ/admin',
      '..％２Ｆadmin',
    ]) {
      expect(() => client.resolve(path), throwsArgumentError, reason: path);
    }
    expect(client.resolve('/files/%f0%9f%98%80').path, '/v1/files/%F0%9F%98%80');
  });

  group('every character in the Unicode $unicodeFoldsVersion folds', () {
    final folds = {
      for (final MapEntry(key: text, value: characters) in foldedTo.entries)
        for (final rune in characters.runes) rune: text,
    };

    test('splits a segment wherever its fold holds a slash or a backslash', () {
      for (final MapEntry(key: rune, value: text) in folds.entries) {
        if (text != '/' && text != r'\') continue;
        for (final MapEntry(key: name, value: encode) in encodings.entries) {
          expect(refused('..${encode(rune)}admin'), isTrue, reason: 'U+${_hex(rune, 4)} $name');
        }
      }
    });

    test('counts as dots wherever its fold is made only of dots', () {
      for (final MapEntry(key: rune, value: text) in folds.entries) {
        if (!RegExp(r'^\.+$').hasMatch(text)) continue;
        for (final MapEntry(key: name, value: encode) in encodings.entries) {
          expect(refused('/${encode(rune)}/admin'), isTrue, reason: 'U+${_hex(rune, 4)} $name');
        }
      }
    });

    test('is read like its fold in every encoding', () {
      // A segment around the character turns into a dot segment exactly when
      // it does around the text the character folds to.
      const contexts = ['..{}admin', '/{}{}/admin', '/..{}/admin', '/%2{}/admin', '/{}2e{}2e/admin', '/x{}../admin'];
      for (final MapEntry(key: rune, value: text) in folds.entries) {
        for (final context in contexts) {
          final expected = refused(context.replaceAll('{}', text));
          for (final MapEntry(key: name, value: encode) in encodings.entries) {
            final path = context.replaceAll('{}', encode(rune));
            expect(refused(path), expected, reason: 'U+${_hex(rune, 4)} $name in $context');
          }
        }
      }
    });

    test('drops every character that NFKC_Casefold removes', () {
      var removed = 0;
      for (var rune = 0x80; rune <= 0x10FFFF; rune++) {
        if (rune >= 0xD800 && rune <= 0xDFFF) continue;
        if (!foldedAway.hasMatch(String.fromCharCode(rune))) continue;
        removed++;
        for (final MapEntry(key: name, value: encode) in encodings.entries) {
          expect(refused('/..${encode(rune)}/admin'), isTrue, reason: 'U+${_hex(rune, 4)} $name');
        }
      }
      expect(removed, greaterThan(4000));
    });
  });
}
