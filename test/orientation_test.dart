import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/core/orientation.dart';

void main() {
  test('phones stay upright, tablets turn freely', () {
    const portrait = [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ];

    expect(allowedOrientations(const Size(390, 844)), portrait);
    expect(allowedOrientations(const Size(430, 932)), portrait);
    // A phone reporting its size on its side is still a phone.
    expect(allowedOrientations(const Size(844, 390)), portrait);

    expect(
      allowedOrientations(const Size(744, 1133)),
      DeviceOrientation.values,
    );
    expect(
      allowedOrientations(const Size(1194, 834)),
      DeviceOrientation.values,
    );
  });

  test('iOS lets only the iPad turn', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    List<String> orientationsFor(String key) {
      final block = RegExp(
        '<key>$key</key>\\s*<array>(.*?)</array>',
        dotAll: true,
      ).firstMatch(plist);
      expect(block, isNotNull, reason: '$key is missing');
      return RegExp(
        '<string>(.*?)</string>',
      ).allMatches(block!.group(1)!).map((match) => match.group(1)!).toList();
    }

    expect(orientationsFor('UISupportedInterfaceOrientations'), [
      'UIInterfaceOrientationPortrait',
    ]);
    expect(
      orientationsFor('UISupportedInterfaceOrientations~ipad'),
      containsAll([
        'UIInterfaceOrientationLandscapeLeft',
        'UIInterfaceOrientationLandscapeRight',
        'UIInterfaceOrientationPortrait',
      ]),
    );
  });
}
