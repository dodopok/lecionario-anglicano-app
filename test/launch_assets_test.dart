import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// The launch image is composited over the launch screen's own background.
/// When the two differ the mark reads as a square patch, so they are checked
/// against each other rather than against a hard-coded colour.
void main() {
  const paper = 0xFFF4F0E7;

  /// Both iOS storyboards: the launch screen, and the view that hosts Flutter
  /// until it draws its first frame. A white one there flashes on every launch.
  for (final storyboard in ['LaunchScreen', 'Main']) {
    test('the iOS $storyboard opens on the app colour', () {
      final contents = File(
        'ios/Runner/Base.lproj/$storyboard.storyboard',
      ).readAsStringSync();

      final background = RegExp(
        r'<color key="backgroundColor" red="([\d.]+)" green="([\d.]+)" '
        r'blue="([\d.]+)"',
      ).firstMatch(contents);
      expect(background, isNotNull, reason: '$storyboard has no background');

      int channel(int group) =>
          (double.parse(background!.group(group)!) * 255).round();
      final colour =
          0xFF000000 | (channel(1) << 16) | (channel(2) << 8) | channel(3);

      expect(colour, paper);
      expect(
        contents,
        isNot(contains('white="1"')),
        reason: '$storyboard still flashes white',
      );
    });
  }

  test('the Android launch window opens on the same colour', () {
    final colours = File(
      'android/app/src/main/res/values/colors.xml',
    ).readAsStringSync();
    final match = RegExp(
      r'<color name="paper">#([0-9A-Fa-f]{8})</color>',
    ).firstMatch(colours);
    expect(match, isNotNull, reason: 'no paper colour declared');
    expect(int.parse(match!.group(1)!, radix: 16), paper);

    for (final path in [
      'android/app/src/main/res/drawable/launch_background.xml',
      'android/app/src/main/res/drawable-v21/launch_background.xml',
      'android/app/src/main/res/values/styles.xml',
      'android/app/src/main/res/values-night/styles.xml',
    ]) {
      final contents = File(path).readAsStringSync();
      expect(
        contents,
        contains('@color/paper'),
        reason: '$path does not open on the app colour',
      );
      expect(
        contents,
        isNot(contains('@android:color/white')),
        reason: '$path still flashes white',
      );
    }
  });

  for (final scale in ['', '@2x', '@3x']) {
    test('the launch mark sits on the launch screen colour ($scale)', () async {
      final bytes = await File(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/'
        'LaunchImage$scale.png',
      ).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      addTearDown(image.dispose);

      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(data, isNotNull);

      int pixelAt(int x, int y) {
        final offset = (y * image.width + x) * 4;
        final r = data!.getUint8(offset);
        final g = data.getUint8(offset + 1);
        final b = data.getUint8(offset + 2);
        final a = data.getUint8(offset + 3);
        return (a << 24) | (r << 16) | (g << 8) | b;
      }

      // Every corner, so a stray edge cannot hide behind a sampled one.
      for (final corner in [
        [0, 0],
        [image.width - 1, 0],
        [0, image.height - 1],
        [image.width - 1, image.height - 1],
      ]) {
        expect(
          pixelAt(corner[0], corner[1]),
          paper,
          reason: 'corner ${corner.join(',')} of LaunchImage$scale.png',
        );
      }
    });
  }
}
