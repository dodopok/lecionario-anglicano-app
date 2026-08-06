import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app talks to its API over HTTPS and does nothing else with
/// cryptography. HTTPS through the system's own APIs is exempt, so the answer
/// to "does this app use non-exempt encryption" is no — and declaring it here
/// is what stops App Store Connect asking on every single upload.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  test('the app declares it uses no non-exempt encryption', () {
    final declaration = RegExp(
      r'<key>ITSAppUsesNonExemptEncryption</key>\s*<(\w+)\s*/>',
    ).firstMatch(plist);

    expect(
      declaration,
      isNotNull,
      reason: 'ITSAppUsesNonExemptEncryption is missing from Info.plist',
    );
    // A <string>NO</string> would parse as a non-empty string, which is true.
    expect(
      declaration!.group(1),
      'false',
      reason: 'the declaration must be the boolean false',
    );
  });

  test('the app target ships the Info.plist that holds the declaration', () {
    // A target with GENERATE_INFOPLIST_FILE builds its own plist and ignores
    // this one, which would drop the declaration without changing this file.
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();

    final appConfigurations = RegExp(
      r'buildSettings = \{(.*?)\};',
      dotAll: true,
    ).allMatches(project).map((match) => match.group(1)!).where(
      (settings) => settings.contains(
        'PRODUCT_BUNDLE_IDENTIFIER = '
        'br.com.caminhoanglicano.lecionarioanglicano;',
      ),
    );

    expect(
      appConfigurations,
      isNotEmpty,
      reason: 'no build configuration for the app itself',
    );
    for (final settings in appConfigurations) {
      expect(
        settings,
        contains('INFOPLIST_FILE = Runner/Info.plist'),
        reason: 'the app must build from Runner/Info.plist',
      );
      expect(
        settings,
        isNot(contains('GENERATE_INFOPLIST_FILE = YES')),
        reason: 'a generated Info.plist would drop the declaration',
      );
    }
  });
}
