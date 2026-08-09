import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../../data/models/liturgical_explanation.dart';
import '../app_controller.dart';
import '../app_copy.dart';
import '../app_shell.dart';
import '../widgets/design_primitives.dart';

typedef LiturgicalExplanationLoader =
    Future<LiturgicalExplanation> Function(DateTime date);

/// Explains how the API resolved a liturgical day and its readings.
///
/// The screen is deliberately a page rather than another nested sheet: the
/// explanation is long enough to deserve uninterrupted reading space.
class LiturgicalExplanationScreen extends StatefulWidget {
  const LiturgicalExplanationScreen({
    required this.controller,
    required this.date,
    this.loader,
    super.key,
  });

  final AppController controller;
  final DateTime date;
  final LiturgicalExplanationLoader? loader;

  @override
  State<LiturgicalExplanationScreen> createState() =>
      _LiturgicalExplanationScreenState();
}

class _LiturgicalExplanationScreenState
    extends State<LiturgicalExplanationScreen> {
  LiturgicalExplanation? _explanation;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final explanation = widget.loader != null
          ? await widget.loader!(widget.date)
          : await widget.controller.fetchLiturgicalExplanation(widget.date);
      if (!mounted) return;
      setState(() {
        _explanation = explanation;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = copyFor(widget.controller);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _ExplanationHeader(copy: copy),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildBody(context, copy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppCopy copy) {
    if (_isLoading) return _ExplanationLoadingState(copy: copy);

    if (_hasError || _explanation == null) {
      return _ExplanationErrorState(copy: copy, onRetry: _load);
    }

    return _ExplanationContent(
      explanation: _explanation!,
      copy: copy,
      onRefresh: _load,
    );
  }
}

class _ExplanationHeader extends StatelessWidget {
  const _ExplanationHeader({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 4),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('liturgical-explanation-back'),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: copy.close,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.inkSoft,
          ),
          Expanded(
            child: Text(
              copy.liturgicalExplanationTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(size: 27, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationContent extends StatelessWidget {
  const _ExplanationContent({
    required this.explanation,
    required this.copy,
    required this.onRefresh,
  });

  final LiturgicalExplanation explanation;
  final AppCopy copy;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final accent = liturgicalColor(explanation.color.value);
    final sharedMetadata = _sharedReadingMetadata(explanation.readings);
    final sharedReason = _sharedReadingReason(explanation.readings);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accent,
      child: ListView(
        key: const ValueKey('liturgical-explanation-content'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ExplanationHero(
                    explanation: explanation,
                    copy: copy,
                    accent: accent,
                  ),
                  if (explanation.completeness.isPartial) ...[
                    const SizedBox(height: 14),
                    _PartialNotice(
                      completeness: explanation.completeness,
                      copy: copy,
                    ),
                  ],
                  const SizedBox(height: 26),
                  _ExplanationSectionLabel(
                    number: '01',
                    title: copy.liturgicalExplanationCalendarSection,
                  ),
                  const SizedBox(height: 11),
                  _CalendarExplanationCard(
                    calendar: explanation.calendar,
                    copy: copy,
                    accent: accent,
                  ),
                  const SizedBox(height: 26),
                  _ExplanationSectionLabel(
                    number: '02',
                    title: copy.liturgicalExplanationCelebrationSection,
                  ),
                  const SizedBox(height: 11),
                  _CelebrationExplanationCard(
                    celebration: explanation.celebration,
                    copy: copy,
                    accent: accent,
                  ),
                  const SizedBox(height: 26),
                  _ExplanationSectionLabel(
                    number: '03',
                    title: copy.liturgicalExplanationColorSection,
                  ),
                  const SizedBox(height: 11),
                  _ColorExplanationCard(
                    color: explanation.color,
                    copy: copy,
                    accent: accent,
                  ),
                  const SizedBox(height: 26),
                  _ExplanationSectionLabel(
                    number: '04',
                    title: copy.liturgicalExplanationTransfersSection,
                  ),
                  const SizedBox(height: 11),
                  _TransfersExplanationCard(
                    transfers: explanation.transfers,
                    copy: copy,
                    accent: accent,
                  ),
                  const SizedBox(height: 26),
                  _ExplanationSectionLabel(
                    number: '05',
                    title: copy.liturgicalExplanationReadingsSection,
                  ),
                  const SizedBox(height: 11),
                  _ReadingGuideExplanationCard(
                    guide: explanation.readingGuide,
                    accent: accent,
                    copy: copy,
                  ),
                  const SizedBox(height: 12),
                  ...explanation.readings.map(
                    (reading) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReadingExplanationCard(
                        reading: reading,
                        accent: accent,
                        copy: copy,
                        showMetadata: sharedMetadata == null,
                        showReason: sharedReason == null,
                      ),
                    ),
                  ),
                  if (explanation.readings.isEmpty)
                    _EmptyReadingsCard(copy: copy, accent: accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationHero extends StatelessWidget {
  const _ExplanationHero({
    required this.explanation,
    required this.copy,
    required this.accent,
  });

  final LiturgicalExplanation explanation;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final calendar = explanation.calendar;
    return Semantics(
      container: true,
      header: true,
      child: _ExplanationCard(
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    copy.dateLong(explanation.date),
                    style: AppTypography.ui(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              explanation.presentation.title,
              style: AppTypography.display(size: 29, height: 1.05),
            ),
            if (explanation.presentation.summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                explanation.presentation.summary,
                style: AppTypography.ui(
                  size: 15,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 17),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _ExplanationFact(
                  label: copy.liturgicalExplanationSeason,
                  value: calendar.season,
                ),
                if (calendar.cycle.isNotEmpty)
                  _ExplanationFact(
                    label: copy.liturgicalExplanationCycle,
                    value: calendar.cycle,
                  ),
                _ExplanationFact(
                  label: copy.liturgicalExplanationWeek,
                  value: calendar.week.toString(),
                ),
                if (calendar.proper != null)
                  _ExplanationFact(
                    label: copy.liturgicalExplanationProper,
                    value: calendar.proper.toString(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationFact extends StatelessWidget {
  const _ExplanationFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paperDeep.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line.withValues(alpha: .7)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label  ',
                style: AppTypography.eyebrow(color: AppColors.muted, size: 9.5),
              ),
              TextSpan(
                text: value,
                style: AppTypography.ui(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplanationSectionLabel extends StatelessWidget {
  const _ExplanationSectionLabel({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Text(number, style: AppTypography.eyebrow(size: 10)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTypography.display(size: 24, height: 1.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.child, this.padding, this.accent});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: padding ?? const EdgeInsets.all(18),
      child: accent == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child,
              ],
            ),
    );
  }
}

class _CalendarExplanationCard extends StatelessWidget {
  const _CalendarExplanationCard({
    required this.calendar,
    required this.copy,
    required this.accent,
  });

  final LiturgicalCalendarExplanation calendar;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final range = calendar.seasonRange;
    final totalDays = range.endDate.difference(range.startDate).inDays;
    final elapsedDays = totalDays - range.daysRemaining;
    final progress = totalDays <= 0
        ? 1.0
        : (elapsedDays / totalDays).clamp(0.0, 1.0);
    final format = DateFormat.MMMd(copy.language.locale.toLanguageTag());

    return _ExplanationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleAndSummary(presentation: range.presentation),
          const SizedBox(height: 21),
          Row(
            children: [
              Text(
                format.format(range.startDate),
                style: AppTypography.ui(size: 12.5, color: AppColors.muted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: accent,
                    backgroundColor: accent.withValues(alpha: .14),
                    semanticsLabel: copy.liturgicalExplanationSeasonProgress,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                format.format(range.endDate),
                style: AppTypography.ui(size: 12.5, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CelebrationExplanationCard extends StatelessWidget {
  const _CelebrationExplanationCard({
    required this.celebration,
    required this.copy,
    required this.accent,
  });

  final LiturgicalCelebrationExplanation celebration;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _ExplanationCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleAndSummary(presentation: celebration.presentation),
                if (celebration.selected case final selected?) ...[
                  const SizedBox(height: 15),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withValues(alpha: .2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: accent),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selected.name,
                                  style: AppTypography.ui(
                                    size: 16,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                if (selected.typeLabel?.isNotEmpty == true)
                                  Text(
                                    selected.typeLabel!,
                                    style: AppTypography.ui(
                                      size: 12.5,
                                      color: AppColors.muted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (celebration.candidates.length > 1) ...[
            Divider(height: 1, color: AppColors.line),
            ExpansionTile(
              key: const ValueKey('liturgical-explanation-candidates'),
              tilePadding: const EdgeInsets.symmetric(horizontal: 18),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              iconColor: accent,
              collapsedIconColor: AppColors.muted,
              title: Text(
                copy.liturgicalExplanationCandidates(
                  celebration.candidates.length,
                ),
                style: AppTypography.ui(size: 15, weight: FontWeight.w700),
              ),
              children: celebration.candidates
                  .map(
                    (candidate) => _CandidateRow(
                      candidate: candidate,
                      accent: accent,
                      copy: copy,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.candidate,
    required this.accent,
    required this.copy,
  });

  final LiturgicalCelebrationCandidate candidate;
  final Color accent;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final foreground =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? AppColors.white
        : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: candidate.selected
                  ? accent
                  : AppColors.paperDeep.withValues(alpha: .75),
            ),
            child: Icon(
              candidate.selected ? Icons.check_rounded : Icons.close_rounded,
              size: 14,
              color: candidate.selected ? foreground : AppColors.muted,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: AppTypography.ui(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  candidate.selected
                      ? copy.liturgicalExplanationSelected
                      : candidate.discardedReason?.message ?? '',
                  style: AppTypography.ui(
                    size: 12.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorExplanationCard extends StatelessWidget {
  const _ColorExplanationCard({
    required this.color,
    required this.copy,
    required this.accent,
  });

  final LiturgicalColorExplanation color;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final meaning = color.meaning;
    final explanationText = meaning == null
        ? color.presentation.summary
        : color.reason.message;
    final contrast =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? AppColors.white
        : AppColors.ink;

    return _ExplanationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cream, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: .3),
                      blurRadius: 13,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.water_drop_outlined,
                  color: contrast,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (color.presentation.title.isNotEmpty)
                      Text(
                        color.presentation.title,
                        style: AppTypography.ui(
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                    if (explanationText.isNotEmpty) ...[
                      if (color.presentation.title.isNotEmpty)
                        const SizedBox(height: 6),
                      Text(
                        explanationText,
                        style: AppTypography.ui(
                          size: 14,
                          color: AppColors.muted,
                          height: 1.42,
                        ),
                      ),
                    ],
                    if (color.sourceLabel?.isNotEmpty == true) ...[
                      const SizedBox(height: 11),
                      _MetadataChip(
                        label: copy.liturgicalExplanationSource,
                        value: color.sourceLabel!,
                        accent: accent,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (meaning != null && meaning.message.isNotEmpty) ...[
            const SizedBox(height: 15),
            Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 12),
            Text(
              copy.liturgicalExplanationColorMeaning,
              style: AppTypography.ui(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              meaning.message,
              style: AppTypography.ui(
                size: 14,
                color: AppColors.muted,
                height: 1.42,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransfersExplanationCard extends StatelessWidget {
  const _TransfersExplanationCard({
    required this.transfers,
    required this.copy,
    required this.accent,
  });

  final List<LiturgicalTransferExplanation> transfers;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return _ExplanationCard(
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.event_available_outlined, color: accent),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                copy.liturgicalExplanationNoTransfers,
                style: AppTypography.ui(size: 14, color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    return _ExplanationCard(
      child: Column(
        children: transfers
            .map(
              (transfer) =>
                  _TransferRow(transfer: transfer, copy: copy, accent: accent),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.transfer,
    required this.copy,
    required this.accent,
  });

  final LiturgicalTransferExplanation transfer;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.circle, size: 9, color: accent),
            Container(
              width: 2,
              height: 34,
              color: accent.withValues(alpha: .24),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: accent),
          ],
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleAndSummary(presentation: transfer.presentation),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _MetadataChip(
                    label: copy.liturgicalExplanationFrom,
                    value: transfer.from,
                    accent: accent,
                  ),
                  _MetadataChip(
                    label: copy.liturgicalExplanationTo,
                    value: transfer.to,
                    accent: accent,
                  ),
                ],
              ),
              if (transfer.reason.message.isNotEmpty) ...[
                const SizedBox(height: 9),
                Text(
                  transfer.reason.message,
                  style: AppTypography.ui(
                    size: 13.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingGuideExplanationCard extends StatelessWidget {
  const _ReadingGuideExplanationCard({
    required this.guide,
    required this.copy,
    required this.accent,
  });

  final LiturgicalReadingGuide guide;
  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _ExplanationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined, color: accent),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  copy.liturgicalExplanationHowReadingsChosen,
                  style: AppTypography.ui(size: 15, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ...guide.items.asMap().entries.map((entry) {
            final item = entry.value;
            final last = entry.key == guide.items.length - 1;
            return Container(
              padding: EdgeInsets.only(top: 13, bottom: last ? 0 : 13),
              decoration: BoxDecoration(
                border: last
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleAndSummary(presentation: item.presentation),
                        if (item.sourceLabel?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          _MetadataChip(
                            label: copy.liturgicalExplanationSource,
                            value: item.sourceLabel!,
                            accent: accent,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReadingExplanationCard extends StatelessWidget {
  const _ReadingExplanationCard({
    required this.reading,
    required this.copy,
    required this.accent,
    required this.showMetadata,
    required this.showReason,
  });

  final LiturgicalReadingExplanation reading;
  final AppCopy copy;
  final Color accent;
  final bool showMetadata;
  final bool showReason;

  @override
  Widget build(BuildContext context) {
    final metadata = _readingMetadata(copy, reading);
    return _ExplanationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: accent,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.presentation.title,
                      style: AppTypography.ui(
                        size: 15.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reading.reference,
                      style: AppTypography.display(
                        size: 21,
                        weight: FontWeight.w600,
                        color: accent,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showReason && reading.reason.message.isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              reading.reason.message,
              style: AppTypography.ui(
                size: 13.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ],
          if (reading.alternatives.isNotEmpty) ...[
            const SizedBox(height: 13),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.paperDeep.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.liturgicalExplanationAlternatives,
                      style: AppTypography.eyebrow(
                        color: AppColors.muted,
                        size: 9.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...reading.alternatives.map(
                      (alternative) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          alternative,
                          style: AppTypography.ui(size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (showMetadata && metadata.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: metadata
                  .map(
                    (item) => _MetadataChip(
                      label: item.$1,
                      value: item.$2,
                      accent: accent,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: accent.withValues(alpha: .17)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: AppTypography.ui(size: 11.5, color: AppColors.muted),
              ),
              TextSpan(
                text: value,
                style: AppTypography.ui(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleAndSummary extends StatelessWidget {
  const _TitleAndSummary({required this.presentation});

  final ExplanationPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (presentation.title.isNotEmpty)
          Text(
            presentation.title,
            style: AppTypography.ui(size: 15.5, weight: FontWeight.w700),
          ),
        if (presentation.summary.isNotEmpty) ...[
          if (presentation.title.isNotEmpty) const SizedBox(height: 5),
          Text(
            presentation.summary,
            style: AppTypography.ui(
              size: 13.5,
              color: AppColors.muted,
              height: 1.42,
            ),
          ),
        ],
      ],
    );
  }
}

class _PartialNotice extends StatelessWidget {
  const _PartialNotice({required this.completeness, required this.copy});

  final LiturgicalExplanationCompleteness completeness;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.copperWash.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.copper.withValues(alpha: .3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.copperDark),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.liturgicalExplanationPartialTitle,
                    style: AppTypography.ui(size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    copy.liturgicalExplanationPartialMessage,
                    style: AppTypography.ui(
                      size: 13,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  if (completeness.missing.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      '${copy.liturgicalExplanationMissing}: '
                      '${completeness.missing.join(', ')}',
                      style: AppTypography.ui(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.copperDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReadingsCard extends StatelessWidget {
  const _EmptyReadingsCard({required this.copy, required this.accent});

  final AppCopy copy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _ExplanationCard(
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, color: accent),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              copy.liturgicalExplanationNoReadings,
              style: AppTypography.ui(size: 14, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationErrorState extends StatelessWidget {
  const _ExplanationErrorState({required this.copy, required this.onRetry});

  final AppCopy copy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _ExplanationCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: AppColors.copperDark,
                ),
                const SizedBox(height: 12),
                Text(
                  copy.liturgicalExplanationError,
                  style: AppTypography.display(size: 24, height: 1.08),
                ),
                const SizedBox(height: 17),
                FilledButton.icon(
                  key: const ValueKey('liturgical-explanation-retry'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(copy.retry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pine,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTypography.ui(
                      size: 14,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExplanationLoadingState extends StatelessWidget {
  const _ExplanationLoadingState({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('liturgical-explanation-loading'),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 130,
                        height: 12,
                        radius: 6,
                        color: AppColors.paperDeep,
                      ),
                      const SizedBox(height: 18),
                      SkeletonBox(
                        width: 230,
                        height: 28,
                        radius: 8,
                        color: AppColors.paperDeep,
                      ),
                      const SizedBox(height: 10),
                      SkeletonBox(
                        width: double.infinity,
                        height: 15,
                        radius: 7,
                        color: AppColors.paperDeep,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          3,
                          (index) => SkeletonBox(
                            width: 78 + index * 13,
                            height: 30,
                            radius: 10,
                            color: AppColors.paperDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  copy.liturgicalExplanationLoading,
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(size: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 13),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: index == 2 ? 0 : 15),
                        child: SkeletonBox(
                          width: double.infinity,
                          height: 16,
                          radius: 7,
                          color: AppColors.paperDeep,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

LiturgicalReadingExplanation? _sharedReadingMetadata(
  List<LiturgicalReadingExplanation> readings,
) {
  if (readings.length < 2) return null;

  final first = readings.first;
  final hasVisibleMetadata =
      first.sourceLabel?.isNotEmpty == true ||
      first.trackLabel?.isNotEmpty == true ||
      first.cycle != null ||
      first.serviceTypeLabel?.isNotEmpty == true ||
      first.fallbackLabel?.isNotEmpty == true;
  if (!hasVisibleMetadata) return null;

  final allEqual = readings
      .skip(1)
      .every(
        (reading) =>
            reading.source == first.source &&
            reading.sourceLabel == first.sourceLabel &&
            reading.track == first.track &&
            reading.trackLabel == first.trackLabel &&
            reading.cycle == first.cycle &&
            reading.cycleLabel == first.cycleLabel &&
            reading.serviceType == first.serviceType &&
            reading.serviceTypeLabel == first.serviceTypeLabel &&
            reading.fallback == first.fallback &&
            reading.fallbackLabel == first.fallbackLabel,
      );

  return allEqual ? first : null;
}

String? _sharedReadingReason(List<LiturgicalReadingExplanation> readings) {
  if (readings.length < 2) return null;

  final firstReason = readings.first.reason.message;
  if (firstReason.isEmpty) return null;

  return readings
          .skip(1)
          .every((reading) => reading.reason.message == firstReason)
      ? firstReason
      : null;
}

List<(String, String)> _readingMetadata(
  AppCopy copy,
  LiturgicalReadingExplanation reading,
) {
  return [
    if (reading.sourceLabel?.isNotEmpty == true)
      (copy.liturgicalExplanationSource, reading.sourceLabel!),
    if (reading.trackLabel?.isNotEmpty == true)
      (copy.liturgicalExplanationTrack, reading.trackLabel!),
    if (reading.cycle != null)
      (copy.liturgicalExplanationCycle, reading.cycleLabel ?? reading.cycle!),
    if (reading.serviceTypeLabel?.isNotEmpty == true)
      (copy.liturgicalExplanationServiceType, reading.serviceTypeLabel!),
    if (reading.fallbackLabel?.isNotEmpty == true)
      (copy.liturgicalExplanationFallback, reading.fallbackLabel!),
  ];
}
