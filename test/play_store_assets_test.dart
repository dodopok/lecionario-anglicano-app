import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Play states its graphics as rules rather than as a list of exact sizes the
/// way App Store Connect does, and the rules are what a rejection quotes back.
/// Checking them here is cheaper than finding out at the upload.
///
/// The checks arm themselves per language: a language folder appears the first
/// time tool/render_store_screenshots.sh writes into it, and from then on that
/// language is held to the full set. That a language is missing altogether is
/// caught by tool/verify_play_store_assets.sh, which the release checklist
/// runs — this file is about what has been committed staying correct.
void main() {
  const languages = ['pt-BR', 'en-US', 'es'];
  const slots = ['phone', 'tablet-7', 'tablet-10'];

  // Every side between 320 and 3840 px, and never more than twice as long as
  // it is wide. Four per slot at 1080 px or more on the long side is what Play
  // wants before it will show the app on its own featured surfaces.
  const minimumSide = 320;
  const maximumSide = 3840;
  const featuredLongSide = 1080;
  const wantedPerSlot = 4;

  for (final language in languages) {
    final folder = Directory('store-assets/play-store/$language');
    if (!folder.existsSync()) continue;

    group(language, () {
      test('has the feature graphic the listing cannot be published without',
          () {
        final graphic = File('${folder.path}/feature-graphic.png');
        expect(graphic.existsSync(), isTrue);
        expect(_dimensions(graphic), (1024, 500));
        // The one graphic Play takes without an alpha channel.
        expect(
          graphic.readAsBytesSync()[25],
          isNot(anyOf(4, 6)),
          reason: 'the feature graphic still carries an alpha channel',
        );
      });

      for (final slot in slots) {
        test('$slot holds screenshots Play accepts', () {
          final images = Directory('${folder.path}/$slot')
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.png'))
              .toList();

          expect(
            images.length,
            greaterThanOrEqualTo(wantedPerSlot),
            reason: 'run tool/render_store_screenshots.sh',
          );

          for (final image in images) {
            final (width, height) = _dimensions(image);
            final short = width < height ? width : height;
            final long = width < height ? height : width;

            expect(short, greaterThanOrEqualTo(minimumSide),
                reason: '${image.path} is too small for Play');
            expect(long, lessThanOrEqualTo(maximumSide),
                reason: '${image.path} is too large for Play');
            expect(long, lessThanOrEqualTo(short * 2),
                reason: '${image.path} is more than twice as long as it is '
                    'wide, which Play rejects');
            expect(long, greaterThanOrEqualTo(featuredLongSide),
                reason: '${image.path} is under the size Play wants before it '
                    'will feature the app');
            expect(image.lengthSync(), lessThanOrEqualTo(8 * 1024 * 1024),
                reason: '${image.path} is over the 8 MB Play accepts');
          }
        });
      }

      test('keeps every screenshot in a slot the console offers', () {
        // A loose image is never uploaded and never size-checked, so it only
        // rots; a folder that is not a slot is a leftover from an older layout.
        expect(
          folder
              .listSync()
              .whereType<File>()
              .map((file) => file.uri.pathSegments.last)
              .where((name) =>
                  name.endsWith('.png') && name != 'feature-graphic.png'),
          isEmpty,
          reason: 'images sit outside a slot folder in $language',
        );
        expect(
          folder
              .listSync()
              .whereType<Directory>()
              .map((entry) =>
                  entry.uri.pathSegments.where((s) => s.isNotEmpty).last)
              .where((name) => !slots.contains(name)),
          isEmpty,
          reason: '$language holds a folder that is not a slot Play offers',
        );
      });
    });
  }
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
