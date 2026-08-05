import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/models/lectionary_models.dart';
import 'data/services/lectionary_api.dart';
import 'data/services/local_preferences.dart';
import 'presentation/app_controller.dart';
import 'presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final preferences = await SharedPreferences.getInstance();
  final controller = AppController(
    api: LectionaryApi(),
    localPreferences: LocalPreferences(preferences),
  );
  await controller.initialize();

  runApp(LecionarioApp(controller: controller));
}

class LecionarioApp extends StatelessWidget {
  const LecionarioApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lecionário Anglicano',
          theme: AppTheme.light,
          locale: controller.locale.locale,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppLanguage.values.map(
            (language) => language.locale,
          ),
          home: AppShell(controller: controller),
        );
      },
    );
  }
}
