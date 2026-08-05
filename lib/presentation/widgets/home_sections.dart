import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_copy.dart';
import 'copy_button.dart';
import 'design_primitives.dart';

/// The card at the top of the home screen: which day the lectionary is showing.
///
/// It stays the same height while the day loads so the layout never jumps.
class DailyHero extends StatelessWidget {
  const DailyHero({
    required this.day,
    required this.activeDate,
    required this.copy,
    required this.isLoading,
    this.onToday,
    this.onTap,
    this.actionLabel,
    super.key,
  });

  final LectionaryDay? day;
  final DateTime activeDate;
  final AppCopy copy;
  final bool isLoading;

  /// Shown as a small action when [activeDate] is not today.
  final VoidCallback? onToday;

  /// Makes the whole card tappable — used on phones to open today's readings.
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final accent = liturgicalColor(day?.color);
    final hasLiturgicalColor = day?.color?.trim().isNotEmpty == true;
    final surface = hasLiturgicalColor
        ? Color.lerp(accent, AppColors.pineDeep, .62)!
        : AppColors.pineDeep;
    final isToday = _sameDay(activeDate, DateTime.now());
    final title = _dayTitle(day);
    final meta = _dayMeta(day, copy);
    final showAction = onTap != null && actionLabel != null;

    return Material(
      color: surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            _eyebrow(isToday, isLoading ? null : day, copy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.eyebrow(
                              color: AppColors.copperWash,
                              size: 10,
                            ),
                          ),
                        ),
                        if (!isToday && onToday != null) ...[
                          const SizedBox(width: 10),
                          _BackToToday(label: copy.backToToday, onTap: onToday!),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    copy.dateLong(activeDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.ui(
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: .72),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 56,
                    child: isLoading
                        ? const _HeroTitleSkeleton()
                        : Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.display(
                                size: 27,
                                weight: FontWeight.w600,
                                color: AppColors.white,
                                height: 1.04,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 18,
                    child: isLoading
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: SkeletonBox(
                              width: 96,
                              height: 10,
                              radius: 5,
                              color: AppColors.white.withValues(alpha: .12),
                            ),
                          )
                        : Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.ui(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.copperWash.withValues(alpha: .9),
                              letterSpacing: .2,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (showAction)
              Container(
                padding: const EdgeInsets.fromLTRB(18, 11, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: .07),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.white.withValues(alpha: .12),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        actionLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.ui(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.copperWash,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.copperWash,
                    ),
                  ],
                ),
              ),
            Container(height: 3, color: accent),
          ],
        ),
      ),
    );
  }
}

String _eyebrow(bool isToday, LectionaryDay? day, AppCopy copy) {
  final label = isToday ? copy.today.toUpperCase() : copy.selected;
  final season = day?.season?.trim();
  if (season == null || season.isEmpty) return label;
  return '$label · $season';
}

String? _dayTitle(LectionaryDay? day) {
  for (final value in [
    day?.celebration?.name,
    day?.sundayName,
    day?.weekName,
    day?.season,
  ]) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

String _dayMeta(LectionaryDay? day, AppCopy copy) {
  final parts = <String>[
    if (day?.liturgicalYear case final year? when year.trim().isNotEmpty)
      '${copy.yearLabel} $year',
    if (day?.color case final color? when color.trim().isNotEmpty)
      copy.colorLabel(color),
  ];
  return parts.join(' · ');
}

class _HeroTitleSkeleton extends StatelessWidget {
  const _HeroTitleSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.white.withValues(alpha: .13);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 226, height: 18, radius: 7, color: color),
        const SizedBox(height: 10),
        SkeletonBox(width: 148, height: 18, radius: 7, color: color),
      ],
    );
  }
}

class _BackToToday extends StatelessWidget {
  const _BackToToday({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.today_outlined,
              size: 14,
              color: AppColors.copperWash,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.ui(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.copperWash,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The month grid. The Sunday column is wider so Sundays can carry their name,
/// which is how the lectionary is actually navigated.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.month,
    required this.selectedDate,
    required this.copy,
    required this.monthDays,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
    this.isLoading = false,
    this.fillHeight = false,
    super.key,
  });

  final DateTime month;
  final DateTime selectedDate;
  final AppCopy copy;
  final List<CalendarDay> monthDays;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLoading;

  /// When true the grid stretches to the height it is given instead of
  /// using a fixed row height, so the whole month fits without scrolling.
  final bool fillHeight;

  static const _sundayFlex = 190;
  static const _weekdayFlex = 100;
  static const _cellGap = 4.0;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month);
    final leadingBlanks = firstOfMonth.weekday % 7;
    final totalDays = DateUtils.getDaysInMonth(month.year, month.month);
    final weeks = ((leadingBlanks + totalDays) / 7).ceil();
    final byDate = {for (final day in monthDays) _key(day.date): day};
    final today = DateTime.now();

    final rows = <Widget>[];
    for (var week = 0; week < weeks; week++) {
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(7, (column) {
          final dayNumber = week * 7 + column - leadingBlanks + 1;
          final date = dayNumber < 1 || dayNumber > totalDays
              ? null
              : DateTime(month.year, month.month, dayNumber);
          return Expanded(
            flex: column == 0 ? _sundayFlex : _weekdayFlex,
            child: Padding(
              padding: EdgeInsets.only(right: column == 6 ? 0 : _cellGap),
              child: date == null
                  ? const SizedBox.shrink()
                  : _DayCell(
                      key: ValueKey('month-day-${_key(date)}'),
                      date: date,
                      data: byDate[_key(date)],
                      isSunday: column == 0,
                      isSelected: _sameDay(date, selectedDate),
                      isToday: _sameDay(date, today),
                      isLoading: isLoading,
                      onTap: () => onSelect(date),
                    ),
            ),
          );
        }),
      );
      if (week > 0) rows.add(const SizedBox(height: _cellGap));
      rows.add(fillHeight ? Expanded(child: row) : SizedBox(height: 62, child: row));
    }

    final grid = Column(
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      children: rows,
    );

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _CalendarArrow(
                key: const ValueKey('calendar-previous-month'),
                icon: Icons.chevron_left_rounded,
                onTap: onPrevious,
                semanticLabel: copy.monthYear(
                  DateTime(month.year, month.month - 1),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    copy.monthYear(month),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display(size: 24, height: 1),
                  ),
                ),
              ),
              _CalendarArrow(
                key: const ValueKey('calendar-next-month'),
                icon: Icons.chevron_right_rounded,
                onTap: onNext,
                semanticLabel: copy.monthYear(
                  DateTime(month.year, month.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(7, (column) {
              // Any week works here: only the weekday name is read from it.
              final reference = DateTime(2024, 1, 7 + column);
              return Expanded(
                flex: column == 0 ? _sundayFlex : _weekdayFlex,
                child: Padding(
                  padding: EdgeInsets.only(right: column == 6 ? 0 : _cellGap),
                  child: Text(
                    copy.weekdayShort(reference),
                    textAlign: column == 0 ? TextAlign.left : TextAlign.center,
                    maxLines: 1,
                    style: AppTypography.ui(
                      size: 9.5,
                      weight: FontWeight.w700,
                      color: column == 0
                          ? AppColors.copperDark
                          : AppColors.muted,
                      letterSpacing: .6,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 7),
          if (fillHeight) Expanded(child: grid) else grid,
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.data,
    required this.isSunday,
    required this.isSelected,
    required this.isToday,
    required this.isLoading,
    required this.onTap,
    super.key,
  });

  final DateTime date;
  final CalendarDay? data;
  final bool isSunday;
  final bool isSelected;
  final bool isToday;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = liturgicalColor(data?.color);
    final label = _cellLabel(data, isSunday);
    final background = isSelected
        ? AppColors.pine
        : isToday
        ? AppColors.copperWash
        : AppColors.paper.withValues(alpha: .5);
    final border = isSelected
        ? AppColors.pine
        : isToday
        ? AppColors.copper
        : AppColors.line.withValues(alpha: .6);
    final numberColor = isSelected ? AppColors.white : AppColors.ink;

    return Semantics(
      button: true,
      selected: isSelected,
      label: ['${date.day}', ?label].join(', '),
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: onTap,
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final number = Text(
                  '${date.day}',
                  style: AppTypography.ui(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: numberColor,
                  ),
                );

                // Very short rows — a landscape phone or a small window — only
                // have room for the date itself.
                if (constraints.maxHeight < 32) {
                  return Center(
                    child: FittedBox(fit: BoxFit.scaleDown, child: number),
                  );
                }

                final roomy = constraints.maxHeight >= 46;
                final showLabel =
                    label != null &&
                    !isLoading &&
                    roomy &&
                    constraints.maxWidth >= 54;
                return Padding(
                  padding: roomy
                      ? const EdgeInsets.fromLTRB(6, 5, 6, 6)
                      : const EdgeInsets.fromLTRB(5, 3, 5, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      number,
                      if (showLabel)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              label,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(
                                size: 9,
                                weight: FontWeight.w600,
                                height: 1.12,
                                color: isSelected
                                    ? AppColors.copperWash
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          // Narrow cells cannot carry a name, so a feast is
                          // marked with a dot the tap reveals in full.
                          child: data?.celebrationName == null
                              ? const SizedBox.shrink()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.copperWash
                                          : AppColors.copper,
                                    ),
                                  ),
                                ),
                        ),
                      SizedBox(height: roomy ? 4 : 2),
                      isLoading
                          ? SkeletonBox(height: roomy ? 3 : 2.5, radius: 3)
                          : Container(
                              height: roomy ? 3 : 2.5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.copperWash.withValues(alpha: .8)
                                    : color.withValues(alpha: .85),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String? _cellLabel(CalendarDay? data, bool isSunday) {
  final candidates = <String?>[
    data?.celebrationName,
    if (isSunday) data?.sundayName,
    if (isSunday) data?.weekName,
  ];
  for (final value in candidates) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      tooltip: semanticLabel,
      color: AppColors.inkSoft,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.paperDeep.withValues(alpha: .55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ReadingsCard extends StatelessWidget {
  const ReadingsCard({
    required this.day,
    required this.copy,
    required this.onOpen,
    this.title,
    this.isLoading = false,
    super.key,
  });

  final LectionaryDay? day;
  final AppCopy copy;
  final ValueChanged<Reading> onOpen;
  final String? title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final readings = (day?.readings ?? const <Reading>[])
        .where((reading) => reading.reference.trim().isNotEmpty)
        .toList();
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34,
            child: Row(
              children: [
                Expanded(child: Eyebrow(title ?? copy.readings)),
                if (readings.isNotEmpty && !isLoading)
                  CopyButton(
                    key: const ValueKey('copy-readings'),
                    copy: copy,
                    text: readingsAsText(readings, copy),
                  ),
              ],
            ),
          ),
          if (isLoading)
            ...List.generate(3, (index) => const _ReadingSkeletonRow())
          else if (readings.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                '—',
                style: AppTypography.display(
                  size: 26,
                  color: AppColors.mutedLight,
                ),
              ),
            )
          else
            ...readings.map(
              (reading) => _ReadingRow(
                reading: reading,
                label: copy.readingLabel(reading.kind),
                isFirst: reading == readings.first,
                onTap: () => onOpen(reading),
              ),
            ),
        ],
      ),
    );
  }
}

String readingsAsText(List<Reading> readings, AppCopy copy) {
  return readings
      .map((reading) => '${copy.readingLabel(reading.kind)}: ${reading.reference}')
      .join('\n');
}

class _ReadingSkeletonRow extends StatelessWidget {
  const _ReadingSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 86, height: 9, radius: 5),
          SizedBox(height: 8),
          SkeletonBox(width: 152, height: 15, radius: 6),
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({
    required this.reading,
    required this.label,
    required this.isFirst,
    required this.onTap,
  });

  final Reading reading;
  final String label;
  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst)
          Divider(height: 1, color: AppColors.line.withValues(alpha: .6)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.ui(
                          size: 11,
                          weight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        reading.reference,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 20,
                          weight: FontWeight.w600,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.mutedLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CollectCard extends StatelessWidget {
  const CollectCard({
    required this.day,
    required this.copy,
    this.isLoading = false,
    super.key,
  });

  final LectionaryDay? day;
  final AppCopy copy;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SurfaceCard(
        key: const ValueKey('collect-skeleton'),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 34, child: Eyebrow(copy.collect)),
            const SkeletonBox(width: 210, height: 14, radius: 7),
            const SizedBox(height: 9),
            const SkeletonBox(width: 180, height: 14, radius: 7),
            const SizedBox(height: 9),
            const SkeletonBox(width: 125, height: 14, radius: 7),
          ],
        ),
      );
    }

    final collect = day?.collects.firstOrNull;
    if (collect == null || collect.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34,
            child: Row(
              children: [
                Expanded(child: Eyebrow(copy.collect)),
                CopyButton(
                  key: const ValueKey('copy-collect'),
                  copy: copy,
                  text: collect.text,
                ),
              ],
            ),
          ),
          Text(
            collect.text,
            style: AppTypography.display(
              size: 20,
              weight: FontWeight.w500,
              color: AppColors.inkSoft,
              height: 1.24,
              style: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// The note the API publishes about the day, when there is one.
class DayDescription extends StatelessWidget {
  const DayDescription({required this.day, super.key});

  final LectionaryDay? day;

  @override
  Widget build(BuildContext context) {
    final text = day?.description?.firstOrNull ?? day?.celebration?.description;
    if (text == null || text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
      child: Text(
        text.trim(),
        style: AppTypography.display(
          size: 18,
          weight: FontWeight.w400,
          color: AppColors.inkSoft,
          height: 1.3,
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
