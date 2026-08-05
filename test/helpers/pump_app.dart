import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:lecionario_anglicano/core/theme/app_theme.dart';
import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/app_shell.dart';

Widget testMaterialApp({required Widget home}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    locale: const Locale('pt', 'BR'),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: AppLanguage.values.map((language) => language.locale),
    home: home,
  );
}

Widget testControllerApp(AppController controller) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) =>
        testMaterialApp(home: AppShell(controller: controller)),
  );
}
