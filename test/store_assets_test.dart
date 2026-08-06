import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app is universal, so App Store Connect asks for a set of screenshots
/// per device family, in every language the listing is published in. A missing
/// or wrongly sized image is only found out at upload, which is late.
///
/// tool/render_store_screenshots.sh produces them.
void main() {
  const languages = ['pt-BR', 'en-US', 'es'];

  // The slots this app fills: iPhone 6.9"/6.5" and iPad 13"/12.9", either way
  // round.
  const accepted = {
    'iphone': {
      (1290, 2796),
      (1320, 2868),
      (1284, 2778),
      (2796, 1290),
      (2868, 1320),
      (2778, 1284),
    },
    'ipad': {(2064, 2752), (2048, 2732), (2752, 2064), (2732, 2048)},
  };

  for (final language in languages) {
    for (final device in accepted.keys) {
      group('$language/$device', () {
        final folder = Directory('store-assets/app-store/$language/$device');
        final images = folder.existsSync()
            ? folder.listSync().whereType<File>().where(
                (file) => file.path.endsWith('.png'),
              )
            : <File>[];

        test('has screenshots', () {
          expect(
            images,
            isNotEmpty,
            reason: 'no $device screenshots in $language — run '
                'tool/render_store_screenshots.sh',
          );
        });

        test('at a size the store accepts', () {
          for (final image in images) {
            expect(
              _dimensions(image),
              isIn(accepted[device]!),
              reason: '${image.path} is not a size the $device slot accepts',
            );
          }
        });
      });
    }
  }

  test('no screenshots are left over from an older interface', () {
    for (final language in languages) {
      final loose = Directory('store-assets/app-store/$language')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'));
      expect(
        loose,
        isEmpty,
        reason: 'screenshots sitting outside iphone/ and ipad/ in $language '
            'are from a previous interface',
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
