import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/lectionary_models.dart';
import '../../data/services/load_failure.dart';
import '../app_controller.dart';
import '../app_copy.dart';
import 'failure_notice.dart';
import 'home_sections.dart';

class DayDetailSheet extends StatefulWidget {
  const DayDetailSheet({
    required this.controller,
    required this.date,
    required this.copy,
    required this.onOpenReading,
    super.key,
  });

  final AppController controller;
  final DateTime date;
  final AppCopy copy;
  final ValueChanged<Reading> onOpenReading;

  @override
  State<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<DayDetailSheet> {
  LectionaryDay? day;
  LoadFailure? failure;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDay();
  }

  Future<void> _loadDay() async {
    if (!isLoading) setState(() => isLoading = true);
    final result = await widget.controller.fetchDayForDate(widget.date);
    if (!mounted) return;
    setState(() {
      day = result.day;
      failure = result.failure;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isToday = DateUtils.isSameDay(widget.date, DateTime.now());

    // The sheet takes its height up front rather than growing around the day
    // as it arrives, and drags away from anywhere in the content.
    return DraggableScrollableSheet(
      key: const ValueKey('mobile-day-detail-sheet'),
      expand: false,
      initialChildSize: .9,
      minChildSize: .5,
      maxChildSize: .95,
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  key: const ValueKey('mobile-day-detail-close'),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: widget.copy.close,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.muted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              DailyHero(
                key: const ValueKey('mobile-day-detail-hero'),
                day: day,
                activeDate: widget.date,
                copy: widget.copy,
                isLoading: isLoading,
              ),
              if (failure case final failure? when !isLoading) ...[
                const SizedBox(height: 14),
                FailureNotice(
                  failure: failure,
                  copy: widget.copy,
                  onRetry: _loadDay,
                ),
              ] else ...[
                if (!isLoading) DayDescription(day: day),
                const SizedBox(height: 14),
                ReadingsCard(
                  key: const ValueKey('mobile-day-detail-readings'),
                  day: day,
                  copy: widget.copy,
                  title: isToday
                      ? widget.copy.readings
                      : widget.copy.readingsForDay,
                  onOpen: widget.onOpenReading,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 12),
                CollectCard(
                  key: const ValueKey('mobile-day-detail-collect'),
                  day: day,
                  copy: widget.copy,
                  isLoading: isLoading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
