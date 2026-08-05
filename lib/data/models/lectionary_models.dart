import 'package:flutter/material.dart';

enum AppLanguage { pt, en, es }

extension AppLanguageX on AppLanguage {
  Locale get locale => switch (this) {
    AppLanguage.pt => const Locale('pt', 'BR'),
    AppLanguage.en => const Locale('en', 'US'),
    AppLanguage.es => const Locale('es'),
  };

  String get code => switch (this) {
    AppLanguage.pt => 'pt',
    AppLanguage.en => 'en',
    AppLanguage.es => 'es',
  };

  String get shortLabel => code.toUpperCase();

  static AppLanguage fromLocale(Locale locale) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == locale.languageCode,
      orElse: () => AppLanguage.pt,
    );
  }
}

enum CalendarView { week, month }

class ReadingTypeOption {
  const ReadingTypeOption({
    required this.value,
    this.label,
    this.description,
    this.isDefault = false,
  });

  final String value;
  final String? label;
  final String? description;
  final bool isDefault;

  String get displayName =>
      label == null || label!.trim().isEmpty ? value : label!;

  ReadingTypeOption copyWith({bool? isDefault}) {
    return ReadingTypeOption(
      value: value,
      label: label,
      description: description,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory ReadingTypeOption.fromJson(Map<String, dynamic> json) {
    return ReadingTypeOption(
      value: '${json['value'] ?? json['key'] ?? json['id'] ?? ''}',
      label: json['label'] as String? ?? json['name'] as String?,
      description: json['description'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}

class BibleVersion {
  const BibleVersion({
    required this.id,
    required this.code,
    required this.name,
    this.fullName,
    required this.language,
    this.description,
    this.publisher,
    this.year,
    this.recommended = false,
    this.license,
  });

  final String id;
  final String code;
  final String name;
  final String? fullName;
  final String language;
  final String? description;
  final String? publisher;
  final int? year;
  final bool recommended;
  final String? license;

  String get displayName => name.isNotEmpty ? name : code;

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    final rawCode = json['id'] ?? json['code'] ?? '';
    final code = '$rawCode'.toLowerCase();
    return BibleVersion(
      id: '${json['id'] ?? code}',
      code: code,
      name: '${json['name'] ?? json['full_name'] ?? code}',
      fullName: json['full_name'] as String?,
      language: '${json['language'] ?? ''}',
      description: json['description'] as String?,
      publisher: json['publisher'] as String?,
      year: (json['year'] as num?)?.toInt(),
      recommended: json['is_recommended'] as bool? ?? false,
      license: json['license'] as String?,
    );
  }
}

class PrayerBook {
  const PrayerBook({
    required this.id,
    required this.code,
    required this.name,
    required this.fullName,
    required this.description,
    required this.language,
    required this.jurisdiction,
    required this.year,
    this.recommended = false,
    this.thumbnailUrl,
    this.imageUrl,
    this.readingTypes = const [],
    this.defaultReadingType,
  });

  final String id;
  final String code;
  final String name;
  final String fullName;
  final String? description;
  final String language;
  final String jurisdiction;
  final int? year;
  final bool recommended;
  final String? thumbnailUrl;
  final String? imageUrl;
  final List<ReadingTypeOption> readingTypes;
  final String? defaultReadingType;

  String? get coverUrl {
    for (final value in [thumbnailUrl, imageUrl]) {
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  factory PrayerBook.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final lectionaryFeatures = rawFeatures is Map
        ? rawFeatures['lectionary']
        : null;
    final featureMap = lectionaryFeatures is Map
        ? Map<String, dynamic>.from(lectionaryFeatures)
        : const <String, dynamic>{};
    final rawReadingTypes =
        json['available_reading_types'] ??
        json['reading_types'] ??
        featureMap['reading_types'];
    final readingTypes = _parseReadingTypeOptions(rawReadingTypes);
    final defaultReadingType =
        json['default_reading_type'] ?? featureMap['default_reading_type'];
    return PrayerBook(
      id: '${json['id'] ?? json['code'] ?? ''}',
      code: '${json['code'] ?? json['id'] ?? ''}',
      name: '${json['name'] ?? json['full_name'] ?? ''}',
      fullName: '${json['full_name'] ?? json['name'] ?? ''}',
      description: json['description'] as String?,
      language: '${json['language'] ?? ''}',
      jurisdiction: '${json['jurisdiction'] ?? ''}',
      year: (json['year'] as num?)?.toInt(),
      recommended: json['is_recommended'] as bool? ?? false,
      thumbnailUrl: json['thumbnail_url'] as String?,
      imageUrl: json['image_url'] as String?,
      readingTypes: readingTypes,
      defaultReadingType: defaultReadingType as String?,
    );
  }

  AppLanguage get appLanguage {
    final normalized = language.toLowerCase();
    if (normalized.startsWith('en') || normalized.contains('english')) {
      return AppLanguage.en;
    }
    if (normalized.startsWith('es') || normalized.contains('español')) {
      return AppLanguage.es;
    }
    return AppLanguage.pt;
  }
}

List<ReadingTypeOption> _parseReadingTypeOptions(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (value) => value is Map
            ? ReadingTypeOption.fromJson(Map<String, dynamic>.from(value))
            : ReadingTypeOption(value: '$value'),
      )
      .where((option) => option.value.trim().isNotEmpty)
      .toList();
}

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.color,
    this.celebrationName,
    this.weekName,
  });

  final DateTime date;
  final String? color;
  final String? celebrationName;
  final String? weekName;

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: parseApiDate(json['date']),
      color: (json['color'] ?? json['liturgical_color']) as String?,
      celebrationName:
          json['celebration_name'] as String? ??
          (json['celebration'] is Map
              ? (json['celebration'] as Map)['name'] as String?
              : null),
      weekName: json['week_name'] as String? ?? json['week'] as String?,
    );
  }
}

class Celebration {
  const Celebration({
    required this.name,
    this.type,
    this.description,
    this.transferred = false,
  });

  final String name;
  final String? type;
  final String? description;
  final bool transferred;

  factory Celebration.fromJson(Map<String, dynamic> json) {
    return Celebration(
      name: '${json['name'] ?? json['nome'] ?? ''}',
      type: json['type'] as String? ?? json['tipo_nome'] as String?,
      description: json['description'] as String?,
      transferred: json['transferred'] as bool? ?? false,
    );
  }
}

class Reading {
  const Reading({
    required this.kind,
    required this.reference,
    this.text,
    this.translation,
  });

  final String kind;
  final String reference;
  final String? text;
  final String? translation;

  factory Reading.fromJson(Map<String, dynamic> json, {String? kind}) {
    return Reading(
      kind: kind ?? '${json['type'] ?? json['kind'] ?? ''}',
      reference: '${json['reference'] ?? json['referencia'] ?? ''}',
      text: json['text'] as String? ?? json['texto'] as String?,
      translation: json['translation'] as String? ?? json['versao'] as String?,
    );
  }
}

class Collect {
  const Collect({required this.text, this.title});

  final String text;
  final String? title;

  factory Collect.fromJson(Map<String, dynamic> json) {
    return Collect(
      text: '${json['text'] ?? json['texto'] ?? ''}',
      title: json['title'] as String?,
    );
  }
}

class LectionaryDay {
  const LectionaryDay({
    required this.date,
    required this.dayOfWeek,
    required this.season,
    required this.color,
    this.liturgicalYear,
    this.weekName,
    this.sundayName,
    this.description,
    this.celebration,
    this.collects = const [],
    this.readings = const [],
  });

  final DateTime date;
  final String? dayOfWeek;
  final String? season;
  final String? color;
  final String? liturgicalYear;
  final String? weekName;
  final String? sundayName;
  final List<String>? description;
  final Celebration? celebration;
  final List<Collect> collects;
  final List<Reading> readings;

  factory LectionaryDay.fromJson(Map<String, dynamic> json) {
    final readings = <Reading>[];
    final rawReadings = json['readings'];

    if (rawReadings is Map) {
      const readingKeys = <String, String>{
        'first_reading': 'first_reading',
        'psalm': 'psalm',
        'second_reading': 'second_reading',
        'gospel': 'gospel',
      };
      for (final entry in readingKeys.entries) {
        final value = rawReadings[entry.key];
        if (value is Map<String, dynamic>) {
          readings.add(Reading.fromJson(value, kind: entry.value));
        }
      }
    } else if (rawReadings is List) {
      for (final value in rawReadings) {
        if (value is Map<String, dynamic>) {
          readings.add(Reading.fromJson(value));
        }
      }
    }

    final rawCollect = json['collect'] ?? json['collects'] ?? json['coletas'];
    final collects = <Collect>[];
    if (rawCollect is List) {
      for (final value in rawCollect) {
        if (value is Map<String, dynamic>) {
          collects.add(Collect.fromJson(value));
        } else if (value != null) {
          collects.add(Collect(text: '$value'));
        }
      }
    } else if (rawCollect is Map<String, dynamic>) {
      collects.add(Collect.fromJson(rawCollect));
    } else if (rawCollect != null && '$rawCollect'.isNotEmpty) {
      collects.add(Collect(text: '$rawCollect'));
    }

    final rawDescription = json['description'];
    final description = rawDescription is List
        ? rawDescription.whereType<String>().toList()
        : rawDescription == null
        ? null
        : rawDescription is String
        ? <String>[rawDescription]
        : null;

    final rawCelebration = json['celebration'];
    return LectionaryDay(
      date: parseApiDate(json['date']),
      dayOfWeek: (json['day_of_week'] ?? json['weekDay']) as String?,
      season: (json['liturgical_season'] ?? json['season']) as String?,
      color: (json['liturgical_color'] ?? json['color']) as String?,
      liturgicalYear:
          json['liturgical_year'] as String? ?? json['cycle'] as String?,
      weekName: json['week_name'] as String? ?? json['week'] as String?,
      sundayName: json['sunday_name'] as String?,
      description: description,
      celebration: rawCelebration is Map<String, dynamic>
          ? Celebration.fromJson(rawCelebration)
          : null,
      collects: collects,
      readings: readings,
    );
  }
}

DateTime parseApiDate(Object? raw) {
  if (raw is DateTime) return DateTime(raw.year, raw.month, raw.day);
  final value = '$raw';
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(value);
  if (iso != null) {
    return DateTime(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }
  final br = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(value);
  if (br != null) {
    return DateTime(
      int.parse(br.group(3)!),
      int.parse(br.group(2)!),
      int.parse(br.group(1)!),
    );
  }
  throw const FormatException('Data ausente ou inválida na resposta da API.');
}
