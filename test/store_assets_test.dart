import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app is universal, so App Store Connect asks for a set of screenshots
/// per slot, in every language the listing is published in. A missing or
/// wrongly sized image is only found out at upload, which is late — and each
/// slot takes its own sizes: a 6.9" image is rejected by a 6.5" slot, which
/// is a rejection worth catching here rather than there.
///
/// tool/render_store_screenshots.sh produces them.
void main() {
  const languages = ['pt-BR', 'en-US', 'es'];

  const accepted = {
    'iphone-6.5': {(1242, 2688), (1284, 2778), (2688, 1242), (2778, 1284)},
    'iphone-6.9': {(1290, 2796), (1320, 2868), (2796, 1290), (2868, 1320)},
    'ipad-13': {(2064, 2752), (2048, 2732), (2752, 2064), (2732, 2048)},
  };

  for (final language in languages) {
    for (final slot in accepted.keys) {
      group('$language/$slot', () {
        final folder = Directory('store-assets/app-store/$language/$slot');
        final images = folder.existsSync()
            ? folder.listSync().whereType<File>().where(
                (file) => file.path.endsWith('.png'),
              )
            : <File>[];

        test('has screenshots', () {
          expect(
            images,
            isNotEmpty,
            reason: 'no $slot screenshots in $language — run '
                'tool/render_store_screenshots.sh',
          );
        });

        test('at a size the slot accepts', () {
          for (final image in images) {
            expect(
              _dimensions(image),
              isIn(accepted[slot]!),
              reason: '${image.path} is not a size the $slot slot accepts',
            );
          }
        });
      });
    }
  }

  test('every screenshot sits in a slot the store offers', () {
    for (final language in languages) {
      final folder = Directory('store-assets/app-store/$language');

      // Loose images are never uploaded and never size-checked, so they only
      // rot; a folder that is not a slot is a leftover from an older layout.
      expect(
        folder.listSync().whereType<File>().where(
          (file) => file.path.endsWith('.png'),
        ),
        isEmpty,
        reason: 'screenshots sit outside a slot folder in $language',
      );
      expect(
        folder
            .listSync()
            .whereType<Directory>()
            .map((entry) => entry.uri.pathSegments.where((s) => s.isNotEmpty).last)
            .where((name) => !accepted.containsKey(name)),
        isEmpty,
        reason: '$language holds a folder that is not a slot the store offers',
      );
    }
  });
}

(int, int) _dimensions(File png) {
  final bytes = png.readAsBytesSync();
  expect(
    bytes.sublist(0, 8),
    [137, 80, 78, 71, 13, 10, 26, 10],
    reason: '${png.path} is not a PNG',
  );
  int at(int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
  return (at(16), at(20));
}
