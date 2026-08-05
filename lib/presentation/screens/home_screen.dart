import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_controller.dart';
import '../app_copy.dart';
import '../app_shell.dart';
import '../widgets/design_primitives.dart';
import '../widgets/home_sections.dart';
import '../widgets/sacred_mark.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime activeDate;
  CalendarView view = CalendarView.week;

  @override
  void initState() {
    super.initState();
    activeDate = widget.controller.selectedDay?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final copy = copyFor(widget.controller);
        final book = widget.controller.selectedPrayerBook;
        final month = DateTime(activeDate.year, activeDate.month);
        final monthDays = widget.controller.monthDays(month);

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      constraints.maxWidth >= 900 ? 34 : 17,
                      18,
                      constraints.maxWidth >= 900 ? 34 : 17,
                      34,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HomeHeader(
                              copy: copy,
                              book: book,
                              onChooseBook: _openPrayerBookSheet,
                              onOpenSettings: _openSettings,
                            ),
                            const SizedBox(height: 24),
                            DailyHero(
                              day: widget.controller.selectedDay,
                              activeDate: activeDate,
                              copy: copy,
                              isLoading: widget.controller.isLoadingDay,
                              onToday: _goToday,
                            ),
                            const SizedBox(height: 18),
                            LayoutBuilder(
                              builder: (context, contentConstraints) {
                                final isWide =
                                    contentConstraints.maxWidth >= 880;
                                if (isWide) {
                                  return _WideContent(
                                    copy: copy,
                                    controller: widget.controller,
                                    isLoading: widget.controller.isLoadingDay,
                                    activeDate: activeDate,
                                    month: month,
                                    monthDays: monthDays,
                                    view: view,
                                    onViewChanged: (value) =>
                                        setState(() => view = value),
                                    onSelectDate: _selectDate,
                                    onPreviousMonth: _previousMonth,
                                    onNextMonth: _nextMonth,
                                    onOpenReading: _openReading,
                                  );
                                }
                                return _NarrowContent(
                                  copy: copy,
                                  controller: widget.controller,
                                  isLoading: widget.controller.isLoadingDay,
                                  activeDate: activeDate,
                                  month: month,
                                  monthDays: monthDays,
                                  view: view,
                                  onViewChanged: (value) =>
                                      setState(() => view = value),
                                  onSelectDate: _selectDate,
                                  onPreviousMonth: _previousMonth,
                                  onNextMonth: _nextMonth,
                                  onOpenReading: _openReading,
                                );
                              },
                            ),
                            const SizedBox(height: 34),
                            const _HomeFooter(),
                          ],
                        ),
                      ),
                    ),
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
    setState(() => activeDate = DateTime(date.year, date.month, date.day));
    await widget.controller.selectDate(activeDate);
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

  Future<void> _previousMonth() async {
    final previous = DateTime(activeDate.year, activeDate.month - 1, 1);
    await _selectDate(DateTime(previous.year, previous.month, 1));
    setState(() => view = CalendarView.month);
  }

  Future<void> _nextMonth() async {
    final next = DateTime(activeDate.year, activeDate.month + 1, 1);
    await _selectDate(DateTime(next.year, next.month, 1));
    setState(() => view = CalendarView.month);
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
    if (mounted) setState(() => activeDate = DateTime.now());
  }

  Future<void> _openReading(Reading reading) async {
    final copy = copyFor(widget.controller);
    final verses = reading.content?.verses ?? const <ReadingVerse>[];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          copy.readingLabel(reading.kind),
          style: AppTypography.display(size: 28),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reading.reference,
                style: AppTypography.ui(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.copperDark,
                ),
              ),
              const SizedBox(height: 18),
              if (reading.text case final text? when text.trim().isNotEmpty)
                Text(
                  text,
                  style: AppTypography.display(
                    size: 21,
                    weight: FontWeight.w500,
                    color: AppColors.inkSoft,
                    height: 1.2,
                  ),
                ),
              if (verses.isNotEmpty) ...[
                if (reading.text?.trim().isNotEmpty == true)
                  const SizedBox(height: 16),
                ...verses.map((verse) => _ReadingVerseBlock(verse: verse)),
              ],
              if (reading.translation case final translation?
                  when translation.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  translation,
                  style: AppTypography.ui(size: 12, color: AppColors.muted),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.close),
          ),
        ],
      ),
    );
  }
}

class _ReadingVerseBlock extends StatelessWidget {
  const _ReadingVerseBlock({required this.verse});

  final ReadingVerse verse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Text.rich(
        TextSpan(
          children: [
            if (verse.number != null)
              TextSpan(
                text: '${verse.number} ',
                style: AppTypography.ui(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.copperDark,
                ),
              ),
            TextSpan(
              text: verse.text,
              style: AppTypography.display(
                size: 20,
                weight: FontWeight.w500,
                color: AppColors.inkSoft,
                height: 1.25,
              ),
            ),
          ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 550;
        return Row(
          children: [
            const SacredMark(size: 37),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display(size: 26, height: .85),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    copy.brandSubline,
                    style: AppTypography.ui(
                      size: 9,
                      weight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 2.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onOpenSettings,
              tooltip: copy.settings,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              icon: const Icon(Icons.tune_rounded, size: 20),
            ),
            _BookPill(
              book: book,
              compact: compact,
              onTap: onChooseBook,
              label: copy.chooseLoc,
            ),
          ],
        );
      },
    );
  }
}

class _BookPill extends StatelessWidget {
  const _BookPill({
    required this.book,
    required this.compact,
    required this.onTap,
    required this.label,
  });

  final PrayerBook? book;
  final bool compact;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bookTitle = book == null
        ? label
        : book!.name.isNotEmpty
        ? book!.name
        : book!.code;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.cream.withValues(alpha: .76),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book != null && !compact)
                BookCover(book: book!, width: 30, height: 38),
              if (book != null && !compact) const SizedBox(width: 8),
              if (!compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.ui(
                        size: 8,
                        weight: FontWeight.w700,
                        color: AppColors.muted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bookTitle,
                      style: AppTypography.ui(
                        size: 13,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 78),
                  child: Text(
                    bookTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.ui(size: 12, weight: FontWeight.w700),
                  ),
                ),
              const SizedBox(width: 5),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 17,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideContent extends StatelessWidget {
  const _WideContent({
    required this.copy,
    required this.controller,
    required this.isLoading,
    required this.activeDate,
    required this.month,
    required this.monthDays,
    required this.view,
    required this.onViewChanged,
    required this.onSelectDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onOpenReading,
  });

  final AppCopy copy;
  final AppController controller;
  final bool isLoading;
  final DateTime activeDate;
  final DateTime month;
  final List<CalendarDay> monthDays;
  final CalendarView view;
  final ValueChanged<CalendarView> onViewChanged;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<Reading> onOpenReading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ViewTabs(selected: view, copy: copy, onChanged: onViewChanged),
              const SizedBox(height: 12),
              if (view == CalendarView.week) ...[
                WeekStrip(
                  activeDate: activeDate,
                  copy: copy,
                  monthDays: monthDays,
                  onSelect: onSelectDate,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 12),
                WeekSchedule(
                  activeDate: activeDate,
                  copy: copy,
                  monthDays: monthDays,
                  onSelect: onSelectDate,
                  isLoading: isLoading,
                ),
              ] else
                MonthCalendar(
                  activeDate: activeDate,
                  copy: copy,
                  monthDays: monthDays,
                  onSelect: onSelectDate,
                  onPrevious: onPreviousMonth,
                  onNext: onNextMonth,
                  isLoading: isLoading,
                ),
            ],
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              ReadingsCard(
                day: controller.selectedDay,
                copy: copy,
                onOpen: onOpenReading,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              CollectCard(
                day: controller.selectedDay,
                copy: copy,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NarrowContent extends StatelessWidget {
  const _NarrowContent({
    required this.copy,
    required this.controller,
    required this.isLoading,
    required this.activeDate,
    required this.month,
    required this.monthDays,
    required this.view,
    required this.onViewChanged,
    required this.onSelectDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onOpenReading,
  });

  final AppCopy copy;
  final AppController controller;
  final bool isLoading;
  final DateTime activeDate;
  final DateTime month;
  final List<CalendarDay> monthDays;
  final CalendarView view;
  final ValueChanged<CalendarView> onViewChanged;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<Reading> onOpenReading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewTabs(selected: view, copy: copy, onChanged: onViewChanged),
        const SizedBox(height: 12),
        if (view == CalendarView.week) ...[
          WeekStrip(
            activeDate: activeDate,
            copy: copy,
            monthDays: monthDays,
            onSelect: onSelectDate,
            isLoading: isLoading,
          ),
          const SizedBox(height: 12),
          WeekSchedule(
            activeDate: activeDate,
            copy: copy,
            monthDays: monthDays,
            onSelect: onSelectDate,
            isLoading: isLoading,
          ),
        ] else
          MonthCalendar(
            activeDate: activeDate,
            copy: copy,
            monthDays: monthDays,
            onSelect: onSelectDate,
            onPrevious: onPreviousMonth,
            onNext: onNextMonth,
            isLoading: isLoading,
          ),
        const SizedBox(height: 14),
        ReadingsCard(
          day: controller.selectedDay,
          copy: copy,
          onOpen: onOpenReading,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        CollectCard(
          day: controller.selectedDay,
          copy: copy,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 26, height: 1, color: AppColors.copper),
        const SizedBox(width: 10),
        const Spacer(),
        const Spacer(),
        const Icon(
          Icons.shield_outlined,
          size: 14,
          color: AppColors.mutedLight,
        ),
      ],
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
            Text(copy.changeLoc, style: AppTypography.display(size: 31)),
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
                    padding: const EdgeInsets.all(9),
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
