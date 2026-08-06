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
    this.compact = false,
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

  /// Tightens the card so the month below it keeps room to name its Sundays.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = liturgicalColor(day?.color);
    final hasLiturgicalColor = day?.color?.trim().isNotEmpty == true;
    final surface = hasLiturgicalColor
        ? Color.lerp(accent, AppColors.pineDeep, .62)!
        : AppColors.pineDeep;
    final isToday = _sameDay(activeDate, DateTime.now());
    final title = _dayTitle(day, activeDate);
    final meta = _dayMeta(day, copy, title);
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
              padding: compact
                  ? const EdgeInsets.fromLTRB(18, 12, 18, 10)
                  : const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: compact ? 21 : 24,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            _eyebrow(isToday, isLoading ? null : day, copy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.eyebrow(
                              color: AppColors.copperWash,
                              size: 11,
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
                      size: 14.5,
                      weight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: .72),
                    ),
                  ),
                  SizedBox(height: compact ? 7 : 10),
                  SizedBox(
                    height: compact ? 48 : 58,
                    child: isLoading
                        ? const _HeroTitleSkeleton()
                        : Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.display(
                                size: compact ? 25 : 28,
                                weight: FontWeight.w600,
                                color: AppColors.white,
                                height: 1.04,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 19,
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
                              size: 13,
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
                padding: compact
                    ? const EdgeInsets.fromLTRB(18, 8, 14, 9)
                    : const EdgeInsets.fromLTRB(18, 11, 14, 12),
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
                          size: 14,
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

/// A Sunday is named by its place in the year first: the feast it may also
/// carry is secondary, and moves to the line below.
String? _dayTitle(LectionaryDay? day, DateTime date) {
  final candidates = date.weekday == DateTime.sunday
      ? [
          day?.sundayName,
          day?.weekName,
          day?.celebration?.name,
          day?.season,
        ]
      : [
          day?.celebration?.name,
          day?.sundayName,
          day?.weekName,
          day?.season,
        ];
  for (final value in candidates) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

/// The line under the day's name: the feast it also carries, and its colour.
///
/// Not the lectionary year: the API reports one for every prayer book, the
/// one-year lectionaries included, so it cannot be shown without being wrong
/// for them.
String _dayMeta(LectionaryDay? day, AppCopy copy, String? title) {
  final celebration = day?.celebration?.name.trim();
  final parts = <String>[
    if (celebration != null && celebration.isNotEmpty && celebration != title)
      celebration,
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
    required this.copy,
    required this.monthDays,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
    this.firstWeekday = DateTime.sunday,
    this.isLoading = false,
    this.fillHeight = false,
    super.key,
  });

  final DateTime month;
  final AppCopy copy;
  final List<CalendarDay> monthDays;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// The weekday the week starts on, as a [DateTime] weekday. Starting on
  /// Thursday puts Sunday in the middle column.
  final int firstWeekday;

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
    final sundayColumn = _column(DateTime.sunday, firstWeekday);
    final leadingBlanks = _column(firstOfMonth.weekday, firstWeekday);
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
            flex: column == sundayColumn ? _sundayFlex : _weekdayFlex,
            child: Padding(
              padding: EdgeInsets.only(right: column == 6 ? 0 : _cellGap),
              child: date == null
                  ? const SizedBox.shrink()
                  : _DayCell(
                      key: ValueKey('month-day-${_key(date)}'),
                      date: date,
                      data: byDate[_key(date)],
                      isSunday: column == sundayColumn,
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
                    style: AppTypography.display(size: 26, height: 1),
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
              final weekday = ((firstWeekday - 1 + column) % 7) + 1;
              return Expanded(
                flex: column == sundayColumn ? _sundayFlex : _weekdayFlex,
                child: Padding(
                  padding: EdgeInsets.only(right: column == 6 ? 0 : _cellGap),
                  child: Text(
                    copy.weekdayShort(_weekdayReference(weekday)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppTypography.ui(
                      size: 11,
                      weight: FontWeight.w700,
                      color: column == sundayColumn
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
    required this.isToday,
    required this.isLoading,
    required this.onTap,
    super.key,
  });

  final DateTime date;
  final CalendarDay? data;
  final bool isSunday;
  final bool isToday;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = liturgicalColor(data?.color);
    final label = _cellLabel(data, isSunday);
    final feast = data?.celebrationName?.trim();
    final background = isToday
        ? AppColors.pine
        : AppColors.paper.withValues(alpha: .5);
    final border = isToday
        ? AppColors.pine
        : AppColors.line.withValues(alpha: .6);
    final numberColor = isToday ? AppColors.white : AppColors.ink;

    return Semantics(
      button: true,
      selected: isToday,
      label: ['${date.day}', ?label, ?(label == feast ? null : feast)].join(', '),
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
                // Never wraps: a two-line date would push the cell out of the
                // row under a wide font or a large text setting.
                final number = FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${date.day}',
                    maxLines: 1,
                    softWrap: false,
                    style: AppTypography.ui(
                      size: 14,
                      weight: FontWeight.w700,
                      color: numberColor,
                    ),
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
                // How many lines of a name the cell can actually hold, once
                // the date, the colour bar and the padding have taken theirs.
                final labelLines =
                    ((constraints.maxHeight - _cellChrome) / _labelLineHeight)
                        .floor()
                        .clamp(0, 3);
                // One clipped line reads worse than the date on its own, so a
                // name waits until two fit.
                final showLabel =
                    label != null &&
                    !isLoading &&
                    labelLines >= 2 &&
                    constraints.maxWidth >= 54;
                // A named Sunday keeps its name and the feast it also carries
                // gets a mark; a cell too narrow to name anything gets one too.
                final showFeastMark =
                    feast != null &&
                    feast.isNotEmpty &&
                    (!showLabel || label != feast);
                final marker = isLoading || !showFeastMark
                    ? null
                    : Container(
                        key: ValueKey('celebration-${_key(date)}'),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? AppColors.copperWash
                              : AppColors.copper,
                        ),
                      );
                return Padding(
                  padding: roomy
                      ? const EdgeInsets.fromLTRB(6, 4, 6, 5)
                      : const EdgeInsets.fromLTRB(5, 3, 5, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showLabel && marker != null)
                        Row(
                          children: [
                            Flexible(child: number),
                            const SizedBox(width: 5),
                            marker,
                          ],
                        )
                      else
                        number,
                      if (showLabel)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              label,
                              maxLines: labelLines,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(
                                size: _labelSize,
                                weight: FontWeight.w600,
                                height: _labelLineHeight / _labelSize,
                                color: isToday
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
                          child: marker == null
                              ? const SizedBox.shrink()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: marker,
                                ),
                        ),
                      SizedBox(height: roomy ? 3 : 2),
                      isLoading
                          ? SkeletonBox(height: roomy ? 3 : 2.5, radius: 3)
                          : Container(
                              height: roomy ? 3 : 2.5,
                              decoration: BoxDecoration(
                                color: isToday
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
  final candidates = isSunday
      ? <String?>[data?.sundayName, data?.weekName, data?.celebrationName]
      : <String?>[data?.celebrationName];
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
            ...List.generate(4, (index) => const _ReadingSkeletonRow())
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
                          size: 12,
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
                          size: 21,
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
            const SkeletonBox(width: 250, height: 15, radius: 7),
            const SizedBox(height: 10),
            const SkeletonBox(width: 220, height: 15, radius: 7),
            const SizedBox(height: 10),
            const SkeletonBox(width: 235, height: 15, radius: 7),
            const SizedBox(height: 10),
            const SkeletonBox(width: 140, height: 15, radius: 7),
          ],
        ),
      );
    }

    final collects = (day?.collects ?? const <Collect>[])
        .where((collect) => collect.text.trim().isNotEmpty)
        .toList();
    if (collects.isEmpty) return const SizedBox.shrink();

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, collect) in collects.indexed) ...[
            if (index > 0) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: AppColors.line.withValues(alpha: .7)),
            ],
            // Each collect carries its own copy action, on its heading line;
            // the first one's heading is the card's.
            SizedBox(
              height: 34,
              child: Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? Eyebrow(
                            collects.length > 1 ? copy.collects : copy.collect,
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              collect.title?.trim() ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(
                                size: 11,
                                weight: FontWeight.w700,
                                color: AppColors.muted,
                                letterSpacing: .4,
                              ),
                            ),
                          ),
                  ),
                  CopyButton(
                    key: ValueKey('copy-collect-$index'),
                    copy: copy,
                    text: collect.text.trim(),
                  ),
                ],
              ),
            ),
            if (index == 0)
              if (collect.title case final title?
                  when title.trim().isNotEmpty) ...[
                Text(
                  title.trim(),
                  style: AppTypography.ui(
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 6),
              ],
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

const _labelSize = 10.0;
const _labelLineHeight = 11.5;

/// Everything in a roomy cell that is not the name: padding, the date and the
/// liturgical colour bar.
const _cellChrome = 32.0;

/// Which column a weekday falls in, for a week starting on [firstWeekday].
int _column(int weekday, int firstWeekday) => (weekday - firstWeekday + 7) % 7;

/// Any week works to read a weekday name from: 2024-01-07 was a Sunday.
DateTime _weekdayReference(int weekday) => DateTime(2024, 1, 7 + (weekday % 7));

String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
