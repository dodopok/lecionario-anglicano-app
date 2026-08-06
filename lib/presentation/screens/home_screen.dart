import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_controller.dart';
import '../app_copy.dart';
import '../app_shell.dart';
import '../widgets/day_detail_sheet.dart';
import '../widgets/design_primitives.dart';
import '../widgets/home_sections.dart';
import '../widgets/reading_sheet.dart';
import '../widgets/sacred_mark.dart';
import 'settings_screen.dart';

/// Width from which the calendar and the day content sit side by side.
const _wideBreakpoint = 880.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The day the hero describes. On phones this stays on today: other days
  /// are read in a sheet instead of taking over the screen.
  late DateTime activeDate;

  /// The day the calendar is browsing around; only its month is shown, since
  /// the grid highlights today and nothing else.
  late DateTime calendarDate;

  @override
  void initState() {
    super.initState();
    activeDate = widget.controller.selectedDay?.date ?? DateTime.now();
    calendarDate = activeDate;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final copy = copyFor(widget.controller);
        final month = DateTime(calendarDate.year, calendarDate.month);
        final monthDays = widget.controller.monthDays(month);

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= _wideBreakpoint) {
                    return _WideLayout(
                      copy: copy,
                      controller: widget.controller,
                      activeDate: activeDate,
                      calendarDate: calendarDate,
                      month: month,
                      monthDays: monthDays,
                      onChooseBook: _openPrayerBookSheet,
                      onOpenSettings: _openSettings,
                      onSelectDate: _selectDate,
                      onPreviousMonth: () => _shiftMonth(-1, selectMonth: true),
                      onNextMonth: () => _shiftMonth(1, selectMonth: true),
                      onToday: _goToday,
                      onOpenReading: _openReading,
                    );
                  }
                  return _NarrowLayout(
                    copy: copy,
                    controller: widget.controller,
                    calendarDate: calendarDate,
                    month: month,
                    monthDays: monthDays,
                    onChooseBook: _openPrayerBookSheet,
                    onOpenSettings: _openSettings,
                    onOpenDay: _openDaySheet,
                    onPreviousMonth: () => _shiftMonth(-1),
                    onNextMonth: () => _shiftMonth(1),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(DateTime date) async {
    final selected = DateTime(date.year, date.month, date.day);
    setState(() {
      activeDate = selected;
      calendarDate = selected;
    });
    await widget.controller.selectDate(selected);
  }

  Future<void> _openDaySheet(DateTime date) async {
    final selected = DateTime(date.year, date.month, date.day);
    setState(() => calendarDate = selected);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DayDetailSheet(
        controller: widget.controller,
        date: selected,
        copy: copyFor(widget.controller),
        onOpenReading: _openReading,
      ),
    );
  }

  Future<void> _goToday() async {
    await _selectDate(DateTime.now());
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(controller: widget.controller),
      ),
    );
  }

  /// Moves the calendar by [offset] months.
  ///
  /// Where the day content is always on screen ([selectMonth]) the new month is
  /// also loaded as the active day; on phones the day only changes when one is
  /// opened, so the month is merely fetched for the grid.
  Future<void> _shiftMonth(int offset, {bool selectMonth = false}) async {
    final month = DateTime(calendarDate.year, calendarDate.month + offset, 1);
    if (selectMonth) {
      await _selectDate(month);
      return;
    }
    setState(() => calendarDate = month);
    await widget.controller.loadMonth(month);
  }

  Future<void> _openPrayerBookSheet() async {
    final selected = await showModalBottomSheet<PrayerBook>(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PrayerBookSheet(
        copy: copyFor(widget.controller),
        books: widget.controller.booksForCurrentLanguage,
        selectedCode: widget.controller.selectedPrayerBookCode,
      ),
    );
    if (!mounted ||
        selected == null ||
        selected.code == widget.controller.selectedPrayerBookCode) {
      return;
    }
    await widget.controller.choosePrayerBook(selected);
    if (mounted) {
      final today = DateTime.now();
      setState(() {
        activeDate = today;
        calendarDate = today;
      });
    }
  }

  Future<void> _openReading(Reading reading) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) =>
          ReadingSheet(reading: reading, copy: copyFor(widget.controller)),
    );
  }
}

/// Phone layout: header, today, and the whole month — no scrolling.
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.copy,
    required this.controller,
    required this.calendarDate,
    required this.month,
    required this.monthDays,
    required this.onChooseBook,
    required this.onOpenSettings,
    required this.onOpenDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final AppCopy copy;
  final AppController controller;
  final DateTime calendarDate;
  final DateTime month;
  final List<CalendarDay> monthDays;
  final VoidCallback onChooseBook;
  final VoidCallback onOpenSettings;
  final ValueChanged<DateTime> onOpenDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HomeHeader(
            copy: copy,
            book: controller.selectedPrayerBook,
            onChooseBook: onChooseBook,
            onOpenSettings: onOpenSettings,
          ),
          const SizedBox(height: 12),
          DailyHero(
            day: controller.selectedDay,
            activeDate: today,
            copy: copy,
            isLoading: controller.isLoadingDay,
            onTap: () => onOpenDay(today),
            actionLabel: copy.openTodayReadings,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: MonthCalendar(
              month: month,
              copy: copy,
              monthDays: monthDays,
              onSelect: onOpenDay,
              onPrevious: onPreviousMonth,
              onNext: onNextMonth,
              isLoading: controller.isLoadingMonth,
              fillHeight: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tablet and desktop layout: the calendar and the selected day side by side.
class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.copy,
    required this.controller,
    required this.activeDate,
    required this.calendarDate,
    required this.month,
    required this.monthDays,
    required this.onChooseBook,
    required this.onOpenSettings,
    required this.onSelectDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onOpenReading,
  });

  final AppCopy copy;
  final AppController controller;
  final DateTime activeDate;
  final DateTime calendarDate;
  final DateTime month;
  final List<CalendarDay> monthDays;
  final VoidCallback onChooseBook;
  final VoidCallback onOpenSettings;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<Reading> onOpenReading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HomeHeader(
                copy: copy,
                book: controller.selectedPrayerBook,
                onChooseBook: onChooseBook,
                onOpenSettings: onOpenSettings,
              ),
              const SizedBox(height: 20),
              DailyHero(
                day: controller.selectedDay,
                activeDate: activeDate,
                copy: copy,
                isLoading: controller.isLoadingDay,
                onToday: onToday,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: MonthCalendar(
                      month: month,
                      copy: copy,
                      monthDays: monthDays,
                      onSelect: onSelectDate,
                      onPrevious: onPreviousMonth,
                      onNext: onNextMonth,
                      isLoading: controller.isLoadingMonth,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReadingsCard(
                          day: controller.selectedDay,
                          copy: copy,
                          onOpen: onOpenReading,
                          isLoading: controller.isLoadingDay,
                        ),
                        const SizedBox(height: 12),
                        CollectCard(
                          day: controller.selectedDay,
                          copy: copy,
                          isLoading: controller.isLoadingDay,
                        ),
                        if (!controller.isLoadingDay)
                          DayDescription(day: controller.selectedDay),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.copy,
    required this.book,
    required this.onChooseBook,
    required this.onOpenSettings,
  });

  final AppCopy copy;
  final PrayerBook? book;
  final VoidCallback onChooseBook;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SacredMark(size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                copy.brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.display(size: 25, height: 1),
              ),
              _BookSelector(
                book: book,
                label: copy.chooseLoc,
                onTap: onChooseBook,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onOpenSettings,
          tooltip: copy.settings,
          icon: const Icon(Icons.tune_rounded, size: 21),
          color: AppColors.inkSoft,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        ),
      ],
    );
  }
}

/// The prayer book in use, and the way to change it.
class _BookSelector extends StatelessWidget {
  const _BookSelector({
    required this.book,
    required this.label,
    required this.onTap,
  });

  final PrayerBook? book;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = book == null
        ? label
        : book!.name.isNotEmpty
        ? book!.name
        : book!.code;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book != null) ...[
                BookCover(book: book!, width: 15, height: 19),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.ui(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                size: 17,
                color: AppColors.mutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerBookSheet extends StatelessWidget {
  const _PrayerBookSheet({
    required this.copy,
    required this.books,
    required this.selectedCode,
  });

  final AppCopy copy;
  final List<PrayerBook> books;
  final String? selectedCode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(copy.changeLoc, style: AppTypography.display(size: 29)),
            const SizedBox(height: 5),
            Text(
              copy.chooseSubtitle,
              style: AppTypography.ui(size: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            ...books.map(
              (book) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: InkWell(
                  onTap: () => Navigator.pop(context, book),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: book.code == selectedCode
                          ? AppColors.pineWash
                          : AppColors.cream,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: book.code == selectedCode
                            ? AppColors.pine
                            : AppColors.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        BookCover(book: book, width: 40, height: 54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.name.isNotEmpty ? book.name : book.code,
                                style: AppTypography.display(
                                  size: 22,
                                  height: 1,
                                ),
                              ),
                              if (book.jurisdiction.isNotEmpty ||
                                  book.year != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (book.jurisdiction.isNotEmpty)
                                      book.jurisdiction,
                                    if (book.year != null) '${book.year}',
                                  ].join(' · '),
                                  style: AppTypography.ui(
                                    size: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (book.code == selectedCode)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.pine,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
