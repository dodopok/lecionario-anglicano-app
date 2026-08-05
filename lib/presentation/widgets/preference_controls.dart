import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_controller.dart';
import '../app_copy.dart';

class PreferenceControls extends StatelessWidget {
  const PreferenceControls({
    required this.controller,
    required this.copy,
    required this.onReadingTypeChanged,
    required this.onBibleVersionChanged,
    super.key,
  });

  final AppController controller;
  final AppCopy copy;
  final ValueChanged<String> onReadingTypeChanged;
  final ValueChanged<BibleVersion> onBibleVersionChanged;

  @override
  Widget build(BuildContext context) {
    final readingOptions = controller.readingTypeOptions;
    final bibleVersions = controller.bibleVersions;
    final showReadingType = readingOptions.length > 1;
    final showBibleVersion = bibleVersions.isNotEmpty;

    if (!showReadingType &&
        !showBibleVersion &&
        !controller.isLoadingPreferences) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: .82)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (controller.isLoadingPreferences &&
              !showReadingType &&
              !showBibleVersion) {
            return const SizedBox(
              height: 34,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.7,
                    color: AppColors.copper,
                  ),
                ),
              ),
            );
          }

          final readingMenu = _PreferenceMenu<String>(
            label: copy.readingTrack,
            selectedValue: controller.selectedReadingType,
            options: readingOptions
                .map(
                  (option) => _PreferenceOption(
                    value: option.value,
                    label: option.displayName,
                    description: option.description,
                  ),
                )
                .toList(),
            enabled: !controller.isLoadingDay,
            onSelected: onReadingTypeChanged,
          );
          final bibleMenu = _PreferenceMenu<BibleVersion>(
            label: copy.bibleVersion,
            selectedValue: controller.selectedBibleVersion,
            options: bibleVersions
                .map(
                  (version) => _PreferenceOption(
                    value: version,
                    label: version.displayName,
                    description: _bibleDescription(version),
                  ),
                )
                .toList(),
            enabled: !controller.isLoadingDay,
            onSelected: onBibleVersionChanged,
          );

          if (showReadingType &&
              showBibleVersion &&
              constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [readingMenu, const SizedBox(height: 9), bibleMenu],
            );
          }

          return Row(
            children: [
              if (showReadingType) Expanded(child: readingMenu),
              if (showReadingType && showBibleVersion) const SizedBox(width: 9),
              if (showBibleVersion) Expanded(child: bibleMenu),
            ],
          );
        },
      ),
    );
  }

  String? _bibleDescription(BibleVersion version) {
    final parts = <String>[];
    if (version.fullName?.trim().isNotEmpty == true &&
        version.fullName != version.name) {
      parts.add(version.fullName!);
    }
    if (version.year != null) parts.add('${version.year}');
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _PreferenceOption<T> {
  const _PreferenceOption({
    required this.value,
    required this.label,
    this.description,
  });

  final T value;
  final String label;
  final String? description;
}

class _PreferenceMenu<T> extends StatelessWidget {
  const _PreferenceMenu({
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.enabled,
    required this.onSelected,
  });

  final String label;
  final T? selectedValue;
  final List<_PreferenceOption<T>> options;
  final bool enabled;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedOption = options
        .where((option) => option.value == selectedValue)
        .firstOrNull;
    final valueLabel = selectedOption?.label ?? label;

    return PopupMenuButton<T>(
      enabled: enabled,
      tooltip: label,
      color: AppColors.cream,
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<T>(
              value: option.value,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: AppTypography.ui(
                              size: 13,
                              weight: FontWeight.w700,
                            ),
                          ),
                          if (option.description case final description?
                              when description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(
                                size: 10,
                                color: AppColors.muted,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (option.value == selectedValue)
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: AppColors.copper,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.paper.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line.withValues(alpha: .8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.ui(
                      size: 8,
                      weight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.ui(size: 12, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.unfold_more_rounded,
              size: 17,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
