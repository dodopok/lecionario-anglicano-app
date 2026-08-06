import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final body = GoogleFonts.sourceSans3(
      color: AppColors.ink,
      fontSize: 16,
      height: 1.35,
    );
    final display = GoogleFonts.cormorantGaramond(
      color: AppColors.ink,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: const ColorScheme.light(
        primary: AppColors.pine,
        onPrimary: AppColors.white,
        secondary: AppColors.copper,
        onSecondary: AppColors.white,
        surface: AppColors.cream,
        onSurface: AppColors.ink,
        outline: AppColors.line,
        error: AppColors.danger,
      ),
      textTheme: TextTheme(
        displayLarge: display.copyWith(fontSize: 58, height: .92),
        displayMedium: display.copyWith(fontSize: 44, height: .98),
        displaySmall: display.copyWith(fontSize: 34, height: 1.02),
        headlineLarge: display.copyWith(fontSize: 30, height: 1.05),
        headlineMedium: display.copyWith(fontSize: 25, height: 1.08),
        headlineSmall: display.copyWith(fontSize: 21, height: 1.12),
        titleLarge: body.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: body.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
        titleSmall: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: body.copyWith(fontSize: 17),
        bodyMedium: body,
        bodySmall: body.copyWith(fontSize: 13),
        labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        labelSmall: body.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: body.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.cream,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.pine
              : AppColors.paperDeep,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.pine
              : AppColors.line,
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
