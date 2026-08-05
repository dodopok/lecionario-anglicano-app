import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_copy.dart';
import 'design_primitives.dart';
import 'sacred_mark.dart';

class DailyHero extends StatelessWidget {
  const DailyHero({
    required this.day,
    required this.activeDate,
    required this.copy,
    required this.isLoading,
    required this.onToday,
    super.key,
  });

  final LectionaryDay? day;
  final DateTime activeDate;
  final AppCopy copy;
  final bool isLoading;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final accent = liturgicalColor(day?.color);
    final hasLiturgicalColor = day?.color?.trim().isNotEmpty == true;
    final heroStart = hasLiturgicalColor
        ? Color.lerp(accent, Colors.black, .18)!
        : AppColors.pineDeep;
    final heroEnd = hasLiturgicalColor
        ? Color.lerp(accent, Colors.black, .38)!
        : AppColors.pine;
    final isToday = _sameDay(activeDate, DateTime.now());
    final description =
        day?.description?.firstOrNull ?? day?.celebration?.description;
    final season = day?.season;
    final celebration = day?.celebration?.name.trim().isNotEmpty == true
        ? day!.celebration!.name
        : day?.weekName?.trim().isNotEmpty == true
        ? day!.weekName
        : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [heroStart, heroEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: heroEnd.withValues(alpha: .22),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: .06),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            right: 65,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: .055),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            right: 26,
            bottom: 26,
            child: SacredMark(
              size: 62,
              color: accent.withValues(alpha: .72),
              strokeWidth: 1,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 5, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 26, 27, 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isToday ? copy.today : copy.selected,
                                style: AppTypography.eyebrow(
                                  color: AppColors.copperWash,
                                  size: 10,
                                ),
                              ),
                              if (!isToday) ...[
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: onToday,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.today_outlined,
                                          size: 13,
                                          color: AppColors.copperWash,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          copy.backToToday,
                                          style: AppTypography.ui(
                                            size: 11,
                                            weight: FontWeight.w700,
                                            color: AppColors.copperWash,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 11),
                          Text(
                            copy.dateLong(activeDate),
                            style: AppTypography.ui(
                              size: compact ? 14 : 16,
                              color: AppColors.white.withValues(alpha: .74),
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: compact ? 72 : 94,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: isLoading
                                  ? SkeletonBox(
                                      width: compact ? 210 : 300,
                                      height: compact ? 34 : 42,
                                      radius: 9,
                                      color: AppColors.white.withValues(
                                        alpha: .13,
                                      ),
                                    )
                                  : season?.isNotEmpty == true
                                  ? Text(
                                      season!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.display(
                                        size: compact ? 36 : 47,
                                        weight: FontWeight.w600,
                                        color: AppColors.white,
                                        height: .92,
                                        letterSpacing: -.5,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          SizedBox(
                            height: 48,
                            child: celebration == null || isLoading
                                ? null
                                : Padding(
                                    padding: const EdgeInsets.only(top: 13),
                                    child: Text(
                                      celebration,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.ui(
                                        size: 14,
                                        weight: FontWeight.w600,
                                        color: AppColors.copperWash,
                                        letterSpacing: .2,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: compact ? 52 : 78,
                            child: isLoading
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 13),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SkeletonBox(
                                          width: compact ? 190 : 350,
                                          height: 13,
                                          radius: 7,
                                          color: AppColors.white.withValues(
                                            alpha: .10,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SkeletonBox(
                                          width: compact ? 125 : 260,
                                          height: 13,
                                          radius: 7,
                                          color: AppColors.white.withValues(
                                            alpha: .10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : description == null || description.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 13),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 480,
                                      ),
                                      child: Text(
                                        description,
                                        maxLines: compact ? 2 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.display(
                                          size: compact ? 16 : 18,
                                          weight: FontWeight.w400,
                                          color: AppColors.white.withValues(
                                            alpha: .74,
                                          ),
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: compact ? 38 : 34,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: isLoading
                                  ? SkeletonBox(
                                      width: 82,
                                      height: 28,
                                      radius: 20,
                                      color: AppColors.white.withValues(
                                        alpha: .10,
                                      ),
                                    )
                                  : day?.liturgicalYear != null
                                  ? _HeroMeta(
                                      label:
                                          '${copy.yearLabel} ${day!.liturgicalYear}',
                                      color: AppColors.white.withValues(
                                        alpha: .25,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(top: compact ? 4 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${activeDate.day}',
                            style: AppTypography.display(
                              size: compact ? 70 : 114,
                              weight: FontWeight.w300,
                              color: AppColors.white.withValues(alpha: .94),
                              height: .72,
                              letterSpacing: -5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            copy
                                .monthYear(activeDate)
                                .split(' ')
                                .first
                                .toUpperCase(),
                            style: AppTypography.ui(
                              size: compact ? 10 : 12,
                              weight: FontWeight.w700,
                              color: AppColors.copperWash,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: .11)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTypography.ui(
              size: 11,
              weight: FontWeight.w700,
              color: AppColors.white.withValues(alpha: .82),
              letterSpacing: .35,
            ),
          ),
        ],
      ),
    );
  }
}

class ViewTabs extends StatelessWidget {
  const ViewTabs({
    required this.selected,
    required this.copy,
    required this.onChanged,
    super.key,
  });

  final CalendarView selected;
  final AppCopy copy;
  final ValueChanged<CalendarView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ViewTab(
            label: copy.week,
            icon: Icons.view_week_outlined,
            selected: selected == CalendarView.week,
            onTap: () => onChanged(CalendarView.week),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ViewTab(
            label: copy.month,
            icon: Icons.calendar_month_outlined,
            selected: selected == CalendarView.month,
            onTap: () => onChanged(CalendarView.month),
          ),
        ),
      ],
    );
  }
}

class _ViewTab extends StatelessWidget {
  const _ViewTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.pine
              : AppColors.cream.withValues(alpha: .68),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.pine : AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? AppColors.white : AppColors.muted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.ui(
                size: 13,
                weight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.activeDate,
    required this.copy,
    required this.monthDays,
    required this.onSelect,
    this.isLoading = false,
    super.key,
  });

  final DateTime activeDate;
  final AppCopy copy;
  final List<CalendarDay> monthDays;
  final ValueChanged<DateTime> onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final days = _weekDays(activeDate);
    final byDate = {for (final day in monthDays) _key(day.date): day};

    return Row(
      children: days.map((date) {
        final data = byDate[_key(date)];
        final color = liturgicalColor(data?.color);
        final selected = _sameDay(date, activeDate);
        final today = _sameDay(date, DateTime.now());
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: date == days.last ? 0 : 6),
            child: InkWell(
              onTap: () => onSelect(date),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 190),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.copperWash
                      : AppColors.cream.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? AppColors.copper : AppColors.line,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      copy.weekdayShort(date),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: AppTypography.ui(
                        size: 10,
                        weight: FontWeight.w700,
                        color: selected
                            ? AppColors.copperDark
                            : AppColors.muted,
                        letterSpacing: .25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${date.day}',
                      style: AppTypography.display(
                        size: 24,
                        weight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.ink : AppColors.inkSoft,
                        height: .9,
                      ),
                    ),
                    const SizedBox(height: 9),
                    isLoading
                        ? SkeletonBox(
                            width: today ? 14 : 7,
                            height: 4,
                            radius: 4,
                          )
                        : Container(
                            width: today ? 14 : 7,
                            height: 4,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WeekSchedule extends StatelessWidget {
  const WeekSchedule({
    required this.activeDate,
    required this.copy,
    required this.monthDays,
    required this.onSelect,
    this.isLoading = false,
    super.key,
  });

  final DateTime activeDate;
  final AppCopy copy;
  final List<CalendarDay> monthDays;
  final ValueChanged<DateTime> onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final days = _weekDays(activeDate);
    final byDate = {for (final day in monthDays) _key(day.date): day};

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 19, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow('${copy.week} · ${copy.monthYear(activeDate)}'),
              const Spacer(),
              Text(
                '${days.first.day}–${days.last.day}',
                style: AppTypography.ui(size: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...days.map((date) {
            final data = byDate[_key(date)];
            final isActive = _sameDay(date, activeDate);
            final color = liturgicalColor(data?.color);
            return InkWell(
              onTap: () => onSelect(date),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 7,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.weekdayShort(date),
                            style: AppTypography.eyebrow(
                              color: isActive
                                  ? AppColors.copperDark
                                  : AppColors.muted,
                              size: 9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: AppTypography.display(
                              size: 24,
                              weight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              height: .9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 35,
                      color: color.withValues(alpha: .5),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: isLoading
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBox(
                                  width: isActive ? 170 : 130,
                                  height: 13,
                                  radius: 7,
                                ),
                                const SizedBox(height: 7),
                                SkeletonBox(
                                  width: isActive ? 90 : 70,
                                  height: 10,
                                  radius: 6,
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data?.celebrationName case final name?
                                    when name.isNotEmpty)
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.ui(
                                      size: 14,
                                      weight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  )
                                else if (data?.weekName case final name?
                                    when name.isNotEmpty)
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.ui(
                                      size: 14,
                                      weight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                if (data?.color case final color?
                                    when color.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    copy.colorLabel(color),
                                    style: AppTypography.ui(
                                      size: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: isActive ? AppColors.copper : AppColors.mutedLight,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.activeDate,
    required this.copy,
    required this.monthDays,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
    this.isLoading = false,
    super.key,
  });

  final DateTime activeDate;
  final AppCopy copy;
  final List<CalendarDay> monthDays;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final firstDayOffset =
        DateTime(activeDate.year, activeDate.month, 1).weekday % 7;
    final totalDays = DateUtils.getDaysInMonth(
      activeDate.year,
      activeDate.month,
    );
    final cells = firstDayOffset + totalDays;
    final totalCells = cells % 7 == 0 ? cells : cells + (7 - cells % 7);
    final byDate = {for (final day in monthDays) _key(day.date): day};
    final weekdays = List.generate(7, (index) {
      final date = DateTime(2024, 1, 7 + index);
      return copy.weekdayShort(date);
    });

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 18),
      child: Column(
        children: [
          Row(
            children: [
              _CalendarArrow(
                icon: Icons.chevron_left_rounded,
                onTap: onPrevious,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    copy.monthYear(activeDate),
                    style: AppTypography.display(size: 28, height: 1),
                  ),
                ),
              ),
              _CalendarArrow(icon: Icons.chevron_right_rounded, onTap: onNext),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, index) => Center(
              child: Text(
                weekdays[index],
                style: AppTypography.ui(
                  size: 10,
                  weight: FontWeight.w700,
                  color: index == 0 ? AppColors.copperDark : AppColors.muted,
                  letterSpacing: .4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - 30) / 7;
              final cellHeight = cellWidth < 60
                  ? 56.0
                  : cellWidth < 100
                  ? 68.0
                  : 78.0;
              final compactCell = cellWidth < 60;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  mainAxisExtent: cellHeight,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - firstDayOffset + 1;
                  if (dayNumber < 1 || dayNumber > totalDays) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime(
                    activeDate.year,
                    activeDate.month,
                    dayNumber,
                  );
                  final data = byDate[_key(date)];
                  final selected = _sameDay(date, activeDate);
                  final today = _sameDay(date, DateTime.now());
                  final color = liturgicalColor(data?.color);
                  return InkWell(
                    onTap: () => onSelect(date),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.fromLTRB(7, 7, 7, 5),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.pine
                            : (today
                                  ? AppColors.copperWash
                                  : AppColors.paper.withValues(alpha: .42)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.pine
                              : today
                              ? AppColors.copper
                              : AppColors.line.withValues(alpha: .65),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${date.day}',
                                style: AppTypography.ui(
                                  size: compactCell ? 11 : 13,
                                  weight: FontWeight.w700,
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.ink,
                                ),
                              ),
                              if (!compactCell) ...[
                                const Spacer(),
                                isLoading
                                    ? SkeletonBox(
                                        width: 6,
                                        height: 6,
                                        radius: 3,
                                      )
                                    : Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                      ),
                              ],
                            ],
                          ),
                          const Spacer(),
                          if (isLoading) ...[
                            SkeletonBox(
                              width: compactCell ? 15 : 34,
                              height: 5,
                              radius: 4,
                            ),
                            if (!compactCell) ...[
                              const SizedBox(height: 5),
                              SkeletonBox(width: 24, height: 5, radius: 4),
                            ],
                          ] else if (data?.celebrationName != null)
                            Text(
                              data!.celebrationName!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(
                                size: 9,
                                weight: FontWeight.w600,
                                color: selected
                                    ? AppColors.copperWash
                                    : AppColors.muted,
                                height: 1.05,
                              ),
                            )
                          else
                            Container(
                              height: 2,
                              width: 15,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .55),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      color: AppColors.muted,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.paperDeep.withValues(alpha: .65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }
}

class ReadingsCard extends StatelessWidget {
  const ReadingsCard({
    required this.day,
    required this.copy,
    required this.onOpen,
    this.isLoading = false,
    super.key,
  });

  final LectionaryDay? day;
  final AppCopy copy;
  final ValueChanged<Reading> onOpen;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final readings = (day?.readings ?? const <Reading>[])
        .where((reading) => reading.reference.trim().isNotEmpty)
        .toList();
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Eyebrow(copy.readings)),
              const Icon(
                Icons.menu_book_outlined,
                size: 19,
                color: AppColors.copper,
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (isLoading)
            ...List.generate(4, (index) => const _ReadingSkeletonRow())
          else if (readings.isEmpty)
            Text(
              '—',
              style: AppTypography.display(
                size: 28,
                color: AppColors.mutedLight,
              ),
            )
          else
            ...readings.asMap().entries.map(
              (entry) => _ReadingRow(
                number: '${entry.key + 1}'.padLeft(2, '0'),
                reading: entry.value,
                label: copy.readingLabel(entry.value.kind),
                onTap: () => onOpen(entry.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadingSkeletonRow extends StatelessWidget {
  const _ReadingSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SkeletonBox(width: 20, height: 20, radius: 6),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 92, height: 9, radius: 5),
                SizedBox(height: 7),
                SkeletonBox(width: 145, height: 16, radius: 6),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SkeletonBox(
            width: 17,
            height: 17,
            radius: 9,
            color: AppColors.paperDeep.withValues(alpha: .58),
          ),
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({
    required this.number,
    required this.reading,
    required this.label,
    required this.onTap,
  });

  final String number;
  final Reading reading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              number,
              style: AppTypography.display(
                size: 17,
                weight: FontWeight.w500,
                color: AppColors.copper,
              ),
            ),
            const SizedBox(width: 13),
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
                      letterSpacing: .35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reading.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display(
                      size: 19,
                      weight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 17,
              color: AppColors.mutedLight,
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  size: 17,
                  color: AppColors.copper,
                ),
                const SizedBox(width: 9),
                Eyebrow(copy.collect),
              ],
            ),
            const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 17,
                color: AppColors.copper,
              ),
              const SizedBox(width: 9),
              Eyebrow(copy.collect),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            collect.text,
            style: AppTypography.display(
              size: 20,
              weight: FontWeight.w500,
              color: AppColors.inkSoft,
              height: 1.16,
              style: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

List<DateTime> _weekDays(DateTime date) {
  final sunday = DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: date.weekday % 7));
  return List.generate(7, (index) => sunday.add(Duration(days: index)));
}

String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
