import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The App Store rejects an icon that carries an alpha channel, opaque or not:
/// "the large app icon can't be transparent nor contain an alpha channel".
void main() {
  test('no app icon carries an alpha channel', () {
    final icons = Directory(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    ).listSync().whereType<File>().where((file) => file.path.endsWith('.png'));

    expect(icons, isNotEmpty, reason: 'no icons found');

    for (final icon in icons) {
      expect(
        _colourType(icon),
        isNot(anyOf(4, 6)),
        reason: '${icon.uri.pathSegments.last} has an alpha channel',
      );
    }
  });

  test('the marketing icon is the size the store asks for', () {
    final icon = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
      'Icon-App-1024x1024@1x.png',
    );
    expect(icon.existsSync(), isTrue);
    expect(_dimensions(icon), (1024, 1024));
  });
}

/// PNG colour type, from the IHDR chunk: 4 is grey with alpha, 6 is RGBA.
/// Read from the header rather than decoded, since decoding hands back RGBA
/// whatever the file holds.
int _colourType(File png) {
  final bytes = png.readAsBytesSync();
  expect(
    bytes.sublist(0, 8),
    [137, 80, 78, 71, 13, 10, 26, 10],
    reason: '${png.path} is not a PNG',
  );
  return bytes[25];
}

(int, int) _dimensions(File png) {
  final bytes = png.readAsBytesSync();
  int at(int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
  return (at(16), at(20));
}
