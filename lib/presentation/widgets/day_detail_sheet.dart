import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/lectionary_models.dart';
import '../app_controller.dart';
import '../app_copy.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDay();
  }

  Future<void> _loadDay() async {
    final loadedDay = await widget.controller.fetchDayForDate(widget.date);
    if (!mounted) return;
    setState(() {
      day = loadedDay;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * .92;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        key: const ValueKey('mobile-day-detail-sheet'),
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 2, 16, 24 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  key: const ValueKey('mobile-day-detail-close'),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: widget.copy.close,
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.muted,
                ),
              ),
              DailyHero(
                key: const ValueKey('mobile-day-detail-hero'),
                day: day,
                activeDate: widget.date,
                copy: widget.copy,
                isLoading: isLoading,
                onToday: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 14),
              ReadingsCard(
                key: const ValueKey('mobile-day-detail-readings'),
                day: day,
                copy: widget.copy,
                title: widget.copy.readingsForDay,
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
          ),
        ),
      ),
    );
  }
}
