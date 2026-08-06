import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Android half of what a release has to get right, checked where it is
/// cheap to check rather than at the upload, where Play answers with a
/// rejection and a wait.
///
/// tool/verify_android_release.sh covers the same ground for the release
/// script; this is what runs in `flutter test` with everything else.
void main() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  group('the version both stores are built from', () {
    test('is a name and a build number in pubspec.yaml', () {
      final version = RegExp(
        r'^version: (\d+\.\d+\.\d+)\+(\d+)$',
        multiLine: true,
      ).firstMatch(File('pubspec.yaml').readAsStringSync());

      expect(
        version,
        isNotNull,
        reason: 'pubspec.yaml needs `version: <name>+<build>`, the one place '
            'both platforms take their version from. tool/version.sh moves it.',
      );
    });

    test('reaches Android without being copied into the Gradle file', () {
      // A hard-coded number here is how a bundle ends up rejected for not
      // having moved, or shipped under a version nobody meant.
      expect(gradle, contains('versionCode = flutter.versionCode'));
      expect(gradle, contains('versionName = flutter.versionName'));
    });
  });

  group('build configuration', () {
    test('names the application id Play will bind the listing to', () {
      // Play fixes this at the first upload and never lets it change.
      expect(
        gradle,
        contains(
          'applicationId = "br.com.caminhoanglicano.lecionarioanglicano"',
        ),
      );
    });

    test('holds a floor under the API level Play enforces', () {
      final floor = RegExp(
        r'targetSdk = maxOf\(flutter\.targetSdkVersion, (\d+)\)',
      ).firstMatch(gradle);

      expect(
        floor,
        isNotNull,
        reason: 'targetSdk should not be left to whichever Flutter SDK builds '
            'it: Play refuses a release below the level it is enforcing.',
      );
      expect(int.parse(floor!.group(1)!), greaterThanOrEqualTo(35));
    });

    test('can sign the release with a real upload key', () {
      expect(gradle, contains('signingConfigs.getByName("release")'));
      expect(
        File('android/key.properties.example').existsSync(),
        isTrue,
        reason: 'the upload key is described by an example file, since the '
            'real one is never committed',
      );
    });

    test('keeps the upload key out of the repository', () {
      // The real key.properties and the keystore are on the release machine,
      // so this is about the rules that keep them from being committed —
      // not about whether they happen to be on this one.
      final ignored = File('android/.gitignore').readAsStringSync();
      expect(ignored, contains('key.properties'));
      expect(ignored, contains('*.keystore'));
      expect(ignored, contains('*.jks'));
    });

    test('keeps the three languages in every download', () {
      // The reader picks the language in Settings, so a language split would
      // deliver only the one the device is set to.
      expect(gradle, contains('enableSplit = false'));
    });
  });

  group('the manifest', () {
    test('asks for nothing but the network', () {
      final permissions = RegExp(r'android\.permission\.([A-Z_]+)')
          .allMatches(manifest)
          .map((match) => match.group(1))
          .toSet();

      expect(
        permissions,
        {'INTERNET'},
        reason: 'every extra permission is one more thing the Play listing '
            'has to declare and justify',
      );
    });

    test('carries the launcher icon and the app name', () {
      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
      expect(manifest, contains('android:label="Lecionário"'));
    });
  });

  group('launcher icons', () {
    // 48dp for the legacy icon, 108dp for the adaptive icon's foreground.
    const densities = {
      'mdpi': (48, 108),
      'hdpi': (72, 162),
      'xhdpi': (96, 216),
      'xxhdpi': (144, 324),
      'xxxhdpi': (192, 432),
    };

    test('are the app mark, not the Flutter logo a new project ships with', () {
      final background = _launcherBackground();
      for (final density in densities.keys) {
        final icon = File(
          'android/app/src/main/res/mipmap-$density/ic_launcher.png',
        );
        expect(
          _firstPixel(icon),
          background,
          reason: '${icon.path} does not start on the icon background — run '
              './tool/generate_android_assets.py',
        );
      }
    });

    test('are there at every density, at the right size', () {
      densities.forEach((density, sizes) {
        final (launcher, adaptive) = sizes;
        expect(
          _dimensions(
            File('android/app/src/main/res/mipmap-$density/ic_launcher.png'),
          ),
          (launcher, launcher),
        );
        expect(
          _dimensions(
            File(
              'android/app/src/main/res/mipmap-$density/'
              'ic_launcher_foreground.png',
            ),
          ),
          (adaptive, adaptive),
        );
      });
    });

    test('are declared as an adaptive icon from Android 8', () {
      final adaptive = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      );
      expect(adaptive.existsSync(), isTrue);

      final xml = adaptive.readAsStringSync();
      expect(xml, contains('@color/ic_launcher_background'));
      expect(xml, contains('@mipmap/ic_launcher_foreground'));
    });
  });

  test('the Play listing icon is the size and depth the console asks for', () {
    final icon = File('store-assets/play-store/icon.png');
    expect(icon.existsSync(), isTrue);
    expect(_dimensions(icon), (512, 512));
    // The opposite of the App Store, where an alpha channel is what gets the
    // upload rejected: Play asks for 32-bit.
    expect(icon.readAsBytesSync()[25], anyOf(4, 6));
    expect(icon.lengthSync(), lessThanOrEqualTo(1024 * 1024));
  });
}

/// The colour the adaptive icon's background layer is filled with, which is
/// also the colour the mark itself sits on.
(int, int, int) _launcherBackground() {
  final declared = RegExp(
    r'<color name="ic_launcher_background">#([0-9A-Fa-f]{6})</color>',
  ).firstMatch(
    File(
      'android/app/src/main/res/values/ic_launcher_background.xml',
    ).readAsStringSync(),
  );
  expect(declared, isNotNull, reason: 'no ic_launcher_background colour');

  final value = int.parse(declared!.group(1)!, radix: 16);
  return ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
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

/// The top-left pixel, which is all this needs and is cheap to reach: on the
/// first scanline every row filter has nothing above and nothing to the left
/// to subtract, so the first pixel is its own value whichever filter was used.
(int, int, int) _firstPixel(File png) {
  final bytes = png.readAsBytesSync();
  expect(
    bytes[25],
    anyOf(2, 6),
    reason: '${png.path} is not RGB or RGBA, so its first bytes are not a '
        'colour — tool/generate_android_assets.py writes RGBA',
  );

  final data = <int>[];

  var offset = 8;
  while (offset < bytes.length) {
    final length = (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
    final kind = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
    if (kind == 'IDAT') {
      data.addAll(bytes.sublist(offset + 8, offset + 8 + length));
    }
    if (kind == 'IEND') break;
    offset += 12 + length;
  }

  final pixels = ZLibCodec().decode(data);
  return (pixels[1], pixels[2], pixels[3]);
}
