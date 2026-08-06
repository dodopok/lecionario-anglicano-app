import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_controller.dart';
import '../app_copy.dart';
import '../app_shell.dart';
import '../widgets/design_primitives.dart';
import '../widgets/preference_controls.dart';
import '../widgets/sacred_mark.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, this.openUrl, super.key});

  final AppController controller;
  final Future<bool> Function(Uri uri)? openUrl;

  void _openExternal(Uri uri) {
    final customLauncher = openUrl;
    if (customLauncher != null) {
      unawaited(customLauncher(uri));
      return;
    }
    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final copy = copyFor(controller);
        final date = controller.selectedDay?.date ?? DateTime.now();
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SettingsHeader(copy: copy),
                        const SizedBox(height: 30),
                        SurfaceCard(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                copy.languageLabel,
                                style: AppTypography.display(
                                  size: 25,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                copy.languageSubtitle,
                                style: AppTypography.ui(
                                  size: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: LanguageSwitcher(
                                  selected: controller.locale,
                                  onChanged: (language) =>
                                      _changeLanguage(context, language),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                copy.preferences,
                                style: AppTypography.display(
                                  size: 25,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 18),
                              PreferenceControls(
                                controller: controller,
                                copy: copy,
                                onReadingTypeChanged: (value) {
                                  controller.setReadingType(value, date);
                                },
                                onBibleVersionChanged: (version) {
                                  controller.chooseBibleVersion(version, date);
                                },
                              ),
                              const SizedBox(height: 6),
                              _SettingsSwitch(
                                key: const ValueKey('sunday-in-center-switch'),
                                label: copy.sundayInCenter,
                                hint: copy.sundayInCenterHint,
                                value: controller.sundayInCenter,
                                onChanged: controller.setSundayInCenter,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SurfaceCard(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                copy.information,
                                style: AppTypography.display(
                                  size: 25,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                copy.informationSubtitle,
                                style: AppTypography.ui(
                                  size: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _SettingsLinkTile(
                                icon: Icons.privacy_tip_outlined,
                                label: copy.privacyPolicy,
                                onTap: () =>
                                    _openExternal(AppLinks.privacyPolicy),
                              ),
                              const Divider(height: 1),
                              _SettingsLinkTile(
                                icon: Icons.support_agent_outlined,
                                label: copy.support,
                                onTap: () => _openExternal(AppLinks.support),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                            ),
                            label: Text(copy.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    AppLanguage language,
  ) async {
    await controller.setLanguage(language);
    if (!context.mounted || !controller.needsPrayerBook) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.ui(
                        size: 15,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: AppTypography.ui(
                        size: 12.5,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ExcludeSemantics(
                child: Switch(value: value, onChanged: onChanged),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.copperDark, size: 20),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: AppTypography.ui(size: 15, weight: FontWeight.w700),
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.muted,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: copy.close,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 3),
        const SacredMark(size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.settings,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.display(size: 28, height: .9),
              ),
              const SizedBox(height: 5),
              Text(
                copy.settingsSubtitle,
                style: AppTypography.ui(
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
