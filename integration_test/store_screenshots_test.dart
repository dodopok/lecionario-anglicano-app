import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/data/services/lectionary_api.dart';
import 'package:lecionario_anglicano/data/services/local_preferences.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/app_shell.dart';
import 'package:lecionario_anglicano/presentation/screens/settings_screen.dart';
import 'package:lecionario_anglicano/presentation/widgets/home_sections.dart';

import 'package:lecionario_anglicano/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Captures the App Store screenshots from the real app against the real API.
///
/// The device name comes in as --dart-define=DEVICE, and becomes part of the
/// file name so one run per simulator lands in the same folder.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const device = String.fromEnvironment('DEVICE', defaultValue: 'device');

  setUpAll(initializeDateFormatting);

  for (final language in AppLanguage.values) {
    testWidgets('screenshots in ${language.code}', (tester) async {
      SharedPreferences.setMockInitialValues({'app_language': language.code});
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(
        api: LectionaryApi(),
        localPreferences: LocalPreferences(preferences),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      Future<void> shoot(String name) async {
        await tester.pumpAndSettle();
        await binding.takeScreenshot('$device-${language.code}-$name');
      }

      await tester.pumpWidget(
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: controller.locale.locale,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: AppLanguage.values.map((l) => l.locale),
            home: AppShell(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. Choosing a prayer book, with the covers the API returns.
      await shoot('00-choose');

      final enter = find.text(controller.locale == AppLanguage.pt
          ? 'Entrar no lecionário'
          : controller.locale == AppLanguage.en
              ? 'Enter the lectionary'
              : 'Entrar al leccionario');
      expect(enter, findsOneWidget, reason: 'no prayer books came back');
      await tester.tap(enter);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2. Today and the month it belongs to.
      await shoot('01-home');

      // 3. The day's readings and collect.
      await tester.tap(find.byType(DailyHero).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await shoot('02-day');
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // 4. Preferences.
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(SettingsScreen), findsOneWidget);
      await shoot('03-settings');

      stdout.writeln('captured ${language.code} on $device');
    });
  }
}
