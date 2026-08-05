import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../../data/services/lectionary_api.dart';
import 'sacred_mark.dart';

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.label, {this.color = AppColors.copperDark, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.eyebrow(color: color),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding,
    this.margin,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line.withValues(alpha: .72)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .035),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({
    required this.selected,
    required this.onChanged,
    this.compact = false,
    super.key,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line.withValues(alpha: .85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((language) {
          final active = language == selected;
          return Semantics(
            button: true,
            selected: active,
            label: language.shortLabel,
            child: InkWell(
              onTap: () => onChanged(language),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 9 : 13,
                  vertical: compact ? 7 : 9,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.pine : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  language.shortLabel,
                  style: AppTypography.ui(
                    size: compact ? 11 : 12,
                    weight: FontWeight.w700,
                    color: active ? AppColors.white : AppColors.muted,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  const BookCover({
    required this.book,
    this.width = 72,
    this.height = 96,
    super.key,
  });

  final PrayerBook book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = _FallbackBookCover(book: book);
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: book.thumbnailUrl == null
            ? fallback
            : Image.network(
                book.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}

class _FallbackBookCover extends StatelessWidget {
  const _FallbackBookCover({required this.book});

  final PrayerBook book;

  @override
  Widget build(BuildContext context) {
    final isEnglish = book.appLanguage == AppLanguage.en;
    final label = book.name
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .padRight(2, 'L')
        .substring(0, 2)
        .toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEnglish
              ? const [Color(0xFF183A35), Color(0xFF35644F)]
              : const [Color(0xFF4D6A51), Color(0xFF9A714E)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiny = constraints.maxWidth < 34 || constraints.maxHeight < 44;
          if (tiny) {
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTypography.display(
                    size: 20,
                    weight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1,
                  ),
                ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -18,
                right: -14,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: .2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: SacredMark(
                        size: 20,
                        color: AppColors.white.withValues(alpha: .85),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 24,
                          weight: FontWeight.w600,
                          color: AppColors.white,
                          height: .9,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '${book.year}',
                        style: AppTypography.ui(
                          size: 8,
                          weight: FontWeight.w700,
                          color: AppColors.white.withValues(alpha: .74),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Color liturgicalColor(String color) => DemoData.colorFor(color);

Color liturgicalWash(String color) {
  return liturgicalColor(color).withValues(alpha: .11);
}
