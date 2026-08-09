/// The localized copy returned by the liturgical explanation endpoint.
///
/// The API remains the source of truth for precedence and selection rules. The
/// app only turns the response into displayable sections.
class ExplanationPresentation {
  const ExplanationPresentation({required this.title, required this.summary});

  final String title;
  final String summary;

  factory ExplanationPresentation.fromJson(Map<String, dynamic>? json) {
    return ExplanationPresentation(
      title: json?['title']?.toString() ?? '',
      summary: json?['summary']?.toString() ?? '',
    );
  }
}

class ExplanationReason {
  const ExplanationReason({required this.code, required this.message});

  final String code;
  final String message;

  factory ExplanationReason.fromJson(Map<String, dynamic>? json) {
    return ExplanationReason(
      code: json?['code']?.toString() ?? '',
      message: json?['message']?.toString() ?? '',
    );
  }
}

class LiturgicalSeasonRange {
  const LiturgicalSeasonRange({
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.presentation,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;
  final ExplanationPresentation presentation;

  factory LiturgicalSeasonRange.fromJson(Map<String, dynamic> json) {
    return LiturgicalSeasonRange(
      startDate: _requiredDate(json['start_date'], 'start_date'),
      endDate: _requiredDate(json['end_date'], 'end_date'),
      daysRemaining: _asInt(json['days_remaining']),
      presentation: ExplanationPresentation.fromJson(
        _asMap(json['presentation']),
      ),
    );
  }
}

class LiturgicalCalendarExplanation {
  const LiturgicalCalendarExplanation({
    required this.season,
    required this.seasonRange,
    required this.cycle,
    required this.week,
    this.proper,
  });

  final String season;
  final LiturgicalSeasonRange seasonRange;
  final String cycle;
  final int week;
  final int? proper;

  factory LiturgicalCalendarExplanation.fromJson(Map<String, dynamic> json) {
    return LiturgicalCalendarExplanation(
      season: json['season']?.toString() ?? '',
      seasonRange: LiturgicalSeasonRange.fromJson(
        _requiredMap(json['season_range'], 'season_range'),
      ),
      cycle: json['cycle']?.toString() ?? '',
      week: _asInt(json['week']),
      proper: json['proper'] == null ? null : _asInt(json['proper']),
    );
  }
}

class LiturgicalCelebrationSelection {
  const LiturgicalCelebrationSelection({
    required this.key,
    required this.name,
    required this.type,
    this.typeLabel,
    required this.date,
  });

  final String key;
  final String name;
  final String type;
  final String? typeLabel;
  final DateTime date;

  factory LiturgicalCelebrationSelection.fromJson(Map<String, dynamic> json) {
    return LiturgicalCelebrationSelection(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString(),
      date: _requiredDate(json['date'], 'celebration.date'),
    );
  }
}

class LiturgicalCelebrationCandidate {
  const LiturgicalCelebrationCandidate({
    required this.key,
    required this.name,
    required this.type,
    this.typeLabel,
    required this.date,
    required this.selected,
    this.discardedReason,
  });

  final String key;
  final String name;
  final String type;
  final String? typeLabel;
  final DateTime date;
  final bool selected;
  final ExplanationReason? discardedReason;

  factory LiturgicalCelebrationCandidate.fromJson(Map<String, dynamic> json) {
    final discardedReasonJson = _asMap(json['discarded_reason']);
    return LiturgicalCelebrationCandidate(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString(),
      date: _requiredDate(json['date'], 'candidate.date'),
      selected: json['selected'] == true,
      discardedReason: discardedReasonJson == null
          ? null
          : ExplanationReason.fromJson(discardedReasonJson),
    );
  }
}

class LiturgicalCelebrationExplanation {
  const LiturgicalCelebrationExplanation({
    required this.selected,
    required this.candidates,
    required this.reason,
    required this.presentation,
  });

  final LiturgicalCelebrationSelection? selected;
  final List<LiturgicalCelebrationCandidate> candidates;
  final ExplanationReason reason;
  final ExplanationPresentation presentation;

  factory LiturgicalCelebrationExplanation.fromJson(Map<String, dynamic> json) {
    final selectedJson = _asMap(json['selected']);
    return LiturgicalCelebrationExplanation(
      selected: selectedJson == null
          ? null
          : LiturgicalCelebrationSelection.fromJson(selectedJson),
      candidates: _asList(json['candidates'])
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(LiturgicalCelebrationCandidate.fromJson)
          .toList(growable: false),
      reason: ExplanationReason.fromJson(_asMap(json['reason'])),
      presentation: ExplanationPresentation.fromJson(
        _asMap(json['presentation']),
      ),
    );
  }
}

class LiturgicalColorExplanation {
  const LiturgicalColorExplanation({
    required this.value,
    required this.source,
    this.sourceLabel,
    required this.reason,
    this.meaning,
    required this.presentation,
  });

  final String value;
  final String source;
  final String? sourceLabel;
  final ExplanationReason reason;
  final ExplanationReason? meaning;
  final ExplanationPresentation presentation;

  factory LiturgicalColorExplanation.fromJson(Map<String, dynamic> json) {
    final meaningJson = _asMap(json['meaning']);
    return LiturgicalColorExplanation(
      value: json['value']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceLabel: json['source_label']?.toString(),
      reason: ExplanationReason.fromJson(_asMap(json['reason'])),
      meaning: meaningJson == null
          ? null
          : ExplanationReason.fromJson(meaningJson),
      presentation: ExplanationPresentation.fromJson(
        _asMap(json['presentation']),
      ),
    );
  }
}

class LiturgicalTransferExplanation {
  const LiturgicalTransferExplanation({
    required this.from,
    required this.to,
    required this.reason,
    required this.presentation,
  });

  final String from;
  final String to;
  final ExplanationReason reason;
  final ExplanationPresentation presentation;

  factory LiturgicalTransferExplanation.fromJson(Map<String, dynamic> json) {
    return LiturgicalTransferExplanation(
      from: _displayValue(json['from'] ?? json['from_date']),
      to: _displayValue(json['to'] ?? json['to_date']),
      reason: ExplanationReason.fromJson(_asMap(json['reason'])),
      presentation: ExplanationPresentation.fromJson(
        _asMap(json['presentation']),
      ),
    );
  }
}

class LiturgicalReadingGuideItem {
  const LiturgicalReadingGuideItem({
    required this.code,
    this.system,
    this.source,
    this.sourceLabel,
    required this.presentation,
  });

  final String code;
  final String? system;
  final String? source;
  final String? sourceLabel;
  final ExplanationPresentation presentation;

  factory LiturgicalReadingGuideItem.fromJson(Map<String, dynamic> json) {
    return LiturgicalReadingGuideItem(
      code: json['code']?.toString() ?? '',
      system: json['system']?.toString(),
      source: json['source']?.toString(),
      sourceLabel: json['source_label']?.toString(),
      presentation: ExplanationPresentation.fromJson(
        _asMap(json['presentation']),
      ),
    );
  }
}

class LiturgicalReadingGuide {
  const LiturgicalReadingGuide({
    required this.cycle,
    this.track,
    required this.method,
  });

  final LiturgicalReadingGuideItem cycle;
  final LiturgicalReadingGuideItem? track;
  final LiturgicalReadingGuideItem method;

  factory LiturgicalReadingGuide.fromJson(Map<String, dynamic> json) {
    final trackJson = _asMap(json['track']);
    return LiturgicalReadingGuide(
      cycle: LiturgicalReadingGuideItem.fromJson(
        _requiredMap(json['cycle'], 'reading_guide.cycle'),
      ),
      track: trackJson == null
          ? null
          : LiturgicalReadingGuideItem.fromJson(trackJson),
      method: LiturgicalReadingGuideItem.fromJson(
        _requiredMap(json['method'], 'reading_guide.method'),
      ),
    );
  }

  List<LiturgicalReadingGuideItem> get items => [cycle, ?track, method];
}

class LiturgicalReadingExplanation {
  const LiturgicalReadingExplanation({
    required this.slot,
    required this.reference,
    required this.alternatives,
    required this.source,
    this.sourceLabel,
    this.track,
    this.trackLabel,
    this.cycle,
    this.cycleLabel,
    required this.serviceType,
    this.serviceTypeLabel,
    this.fallback,
    this.fallbackLabel,
    required this.reason,
    required this.presentation,
  });

  final String slot;
  final String reference;
  final List<String> alternatives;
  final String source;
  final String? sourceLabel;
  final String? track;
  final String? trackLabel;
  final String? cycle;
  final String? cycleLabel;
  final String serviceType;
  final String? serviceTypeLabel;
  final String? fallback;
  final String? fallbackLabel;
  final ExplanationReason reason;
  final ExplanationPresentation presentation;

  factory LiturgicalReadingExplanation.fromJson(Map<String, dynamic> json) {
    return LiturgicalReadingExplanation(
      slot: json['slot']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      alternatives: _asList(
        json['alternatives'],
      ).map((value) => value.toString()).toList(growable: false),
      source: json['source']?.toString() ?? '',
      sourceLabel: json['source_label']?.toString(),
      track: json['track']?.toString(),
      trackLabel: json['track_label']?.toString(),
      cycle: json['cycle']?.toString(),
      cycleLabel: json['cycle_label']?.toString(),
      serviceType: json['service_type']?.toString() ?? '',
      serviceTypeLabel: json['service_type_label']?.toString(),
      fallback: json['fallback'] == null
          ? null
          : _displayValue(json['fallback']),
      fallbackLabel: json['fallback_label']?.toString(),
      reason: ExplanationReason.fromJson(_asMap(json['reason'])),
      presentation: ExplanationPresentation.fromJson(
        _asMap(json['presentation']),
      ),
    );
  }
}

class LiturgicalExplanationCompleteness {
  const LiturgicalExplanationCompleteness({
    required this.isPartial,
    required this.missing,
  });

  final bool isPartial;
  final List<String> missing;

  factory LiturgicalExplanationCompleteness.fromJson(
    Map<String, dynamic>? json,
  ) {
    return LiturgicalExplanationCompleteness(
      isPartial: json?['partial'] == true,
      missing: _asList(
        json?['missing'],
      ).map((value) => value.toString()).toList(growable: false),
    );
  }
}

class LiturgicalExplanation {
  const LiturgicalExplanation({
    required this.date,
    required this.prayerBookCode,
    required this.locale,
    required this.presentation,
    required this.calendar,
    required this.celebration,
    required this.color,
    required this.transfers,
    required this.readingGuide,
    required this.readings,
    required this.completeness,
    required this.requestId,
    required this.contractVersion,
  });

  final DateTime date;
  final String prayerBookCode;
  final String locale;
  final ExplanationPresentation presentation;
  final LiturgicalCalendarExplanation calendar;
  final LiturgicalCelebrationExplanation celebration;
  final LiturgicalColorExplanation color;
  final List<LiturgicalTransferExplanation> transfers;
  final LiturgicalReadingGuide readingGuide;
  final List<LiturgicalReadingExplanation> readings;
  final LiturgicalExplanationCompleteness completeness;
  final String requestId;
  final int contractVersion;

  factory LiturgicalExplanation.fromApiJson(Map<String, dynamic> json) {
    final data = _requiredMap(json['data'], 'data');
    final meta = _asMap(json['meta']) ?? const <String, dynamic>{};

    return LiturgicalExplanation(
      date: _requiredDate(data['date'], 'date'),
      prayerBookCode: data['prayer_book_code']?.toString() ?? '',
      locale: data['locale']?.toString() ?? '',
      presentation: ExplanationPresentation.fromJson(
        _asMap(data['presentation']),
      ),
      calendar: LiturgicalCalendarExplanation.fromJson(
        _requiredMap(data['calendar'], 'calendar'),
      ),
      celebration: LiturgicalCelebrationExplanation.fromJson(
        _requiredMap(data['celebration'], 'celebration'),
      ),
      color: LiturgicalColorExplanation.fromJson(
        _requiredMap(data['color'], 'color'),
      ),
      transfers: _asList(data['transfers'])
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(LiturgicalTransferExplanation.fromJson)
          .toList(growable: false),
      readingGuide: LiturgicalReadingGuide.fromJson(
        _requiredMap(data['reading_guide'], 'reading_guide'),
      ),
      readings: _asList(data['readings'])
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(LiturgicalReadingExplanation.fromJson)
          .toList(growable: false),
      completeness: LiturgicalExplanationCompleteness.fromJson(
        _asMap(data['partial']),
      ),
      requestId: meta['request_id']?.toString() ?? '',
      contractVersion: _asInt(meta['contract_version']),
    );
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : null;
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  final map = _asMap(value);
  if (map == null) throw FormatException('Missing object: $field');
  return map;
}

List<dynamic> _asList(Object? value) => value is List ? value : const [];

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _requiredDate(Object? value, String field) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  if (parsed == null) throw FormatException('Invalid date: $field');
  return DateTime(parsed.year, parsed.month, parsed.day);
}

String _displayValue(Object? value) {
  if (value is Map) {
    return value['date']?.toString() ??
        value['name']?.toString() ??
        value.values.map((item) => item.toString()).join(' · ');
  }
  return value?.toString() ?? '';
}
