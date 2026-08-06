import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Writes the screenshots the integration test hands over.
///
/// Run through tool/capture_store_screenshots.sh rather than directly: it
/// picks the simulators and passes the folder to write into.
Future<void> main() async {
  final directory = Platform.environment['SCREENSHOT_DIR'] ?? 'build/screenshots';

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('$directory/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      stdout.writeln('wrote ${file.path}');
      return true;
    },
  );
}
