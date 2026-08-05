import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'app_controller.dart';
import 'app_copy.dart';
import 'screens/home_screen.dart';
import 'screens/loc_selection_screen.dart';
import 'widgets/sacred_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isInitializing) return const _LaunchView();
    if (controller.needsPrayerBook) {
      return LocSelectionScreen(controller: controller);
    }
    return HomeScreen(controller: controller);
  }
}

class _LaunchView extends StatelessWidget {
  const _LaunchView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SacredMark(size: 58, color: AppColors.copper),
            SizedBox(height: 20),
            Text('LECIONÁRIO', style: _LaunchTextStyle()),
          ],
        ),
      ),
    );
  }
}

class _LaunchTextStyle extends TextStyle {
  const _LaunchTextStyle()
    : super(
        fontFamily: 'Source Sans 3',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
        color: AppColors.ink,
      );
}

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.paper),
        Positioned(
          top: -190,
          right: -120,
          child: IgnorePointer(
            child: Container(
              width: 430,
              height: 430,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.copper.withValues(alpha: .10),
                    AppColors.copper.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -230,
          left: -180,
          child: IgnorePointer(
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pine.withValues(alpha: .07),
                    AppColors.pine.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

AppCopy copyFor(AppController controller) => AppCopy(controller.locale);
