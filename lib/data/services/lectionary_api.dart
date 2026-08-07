import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/lectionary_models.dart';

class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.caminhoanglicano.com.br/api/v1',
  );
  static const internalIdentifier = String.fromEnvironment(
    'APP_INTERNAL_IDENTIFIER',
    defaultValue: 'WxmP9zc51ioDltt41ZRbPzC70fcr0bWa3rhVeIzcFxI=',
  );

  /// Beta-only external API key (X-API-Key), used while a prayer book is
  /// published as `external_only` on the backend and not yet visible through
  /// the normal app-header path. Empty by default on purpose — never commit
  /// a real key here, this repo is public. Pass it at build time:
  ///   flutter build ... --dart-define=API_KEY=estevao_xxxxx
  /// To go back to the normal app-header flow, just stop passing it; no code
  /// change needed on this side.
  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
}

abstract interface class LectionaryDataSource {
  Future<List<PrayerBook>> getPrayerBooks();

  Future<List<ReadingTypeOption>> getReadingTypeOptions(String prayerBookCode);

  Future<List<BibleVersion>> getBibleVersions({String? language});

  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String prayerBookCode, {
    String? readingType,
    String? bibleVersion,
  });

  Future<LectionaryDay> getDay(
    DateTime date,
    String prayerBookCode, {
    String? readingType,
    String? bibleVersion,
  });

  void dispose();
}

class LectionaryApi implements LectionaryDataSource {
  LectionaryApi({
    http.Client? client,
    String? baseUrl,
    String? internalIdentifier,
    String? apiKey,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _internalIdentifier = internalIdentifier ?? ApiConfig.internalIdentifier,
       _apiKey = apiKey ?? ApiConfig.apiKey;

  final http.Client _client;
  final String _baseUrl;
  final String _internalIdentifier;
  final String _apiKey;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-App-Internal-Id': _internalIdentifier,
    if (_apiKey.isNotEmpty) 'X-API-Key': _apiKey,
  };

  Uri _uri(
    String path, {
    String? prayerBookCode,
    String? readingType,
    String? bibleVersion,
    String? language,
  }) {
    final query = <String, String>{};
    if (language != null && language.trim().isNotEmpty) {
      query['language'] = language;
    }
    if (prayerBookCode != null) {
      final preferences = <String, String>{'prayer_book_code': prayerBookCode};
      if (readingType != null && readingType.trim().isNotEmpty) {
        preferences['reading_type'] = readingType;
      }
      if (bibleVersion != null && bibleVersion.trim().isNotEmpty) {
        preferences['bible_version'] = bibleVersion;
      }
      query['preferences'] = jsonEncode(preferences);
    }
    return Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: query.isEmpty ? null : query);
  }

  @override
  Future<List<PrayerBook>> getPrayerBooks() async {
    final response = await _client
        .get(_uri('/prayer_books'), headers: _headers)
        .timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    final json = _decodeJson(response);
    final values = json is Map ? json['data'] : json;
    if (values is! List) return const [];
    return values
        .whereType<Map>()
        .map((value) => PrayerBook.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  @override
  Future<List<ReadingTypeOption>> getReadingTypeOptions(
    String prayerBookCode,
  ) async {
    final response = await _client
        .get(
          _uri('/prayer_books/$prayerBookCode/preferences'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    final json = _decodeJson(response);
    if (json is! Map) return const [];

    final directOptions = json['reading_types'];
    if (directOptions is List) {
      return _parseReadingTypeOptions(directOptions);
    }

    final categories = json['categories'];
    if (categories is! List) return const [];
    for (final category in categories) {
      if (category is! Map) continue;
      final preferences = category['preferences'];
      if (preferences is! List) continue;
      for (final preference in preferences) {
        if (preference is! Map || preference['key'] != 'reading_type') {
          continue;
        }
        final options = preference['options'];
        if (options is! List) return const [];
        final defaultValue = preference['default_value']?.toString();
        return _parseReadingTypeOptions(options, defaultValue: defaultValue);
      }
    }
    return const [];
  }

  @override
  Future<List<BibleVersion>> getBibleVersions({String? language}) async {
    final response = await _client
        .get(_uri('/bible_versions', language: language), headers: _headers)
        .timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    final json = _decodeJson(response);
    final values = json is Map ? json['data'] : json;
    if (values is! List) return const [];
    return values
        .whereType<Map>()
        .map((value) => BibleVersion.fromJson(Map<String, dynamic>.from(value)))
        .where((version) => version.code.isNotEmpty)
        .toList();
  }

  @override
  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String prayerBookCode, {
    String? readingType,
    String? bibleVersion,
  }) async {
    final response = await _client
        .get(
          _uri(
            '/calendar/${month.year}/${month.month}',
            prayerBookCode: prayerBookCode,
            readingType: readingType,
            bibleVersion: bibleVersion,
          ),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    final json = _decodeJson(response);
    final values = json is Map ? json['data'] : json;
    if (values is! List) return const [];
    return values
        .whereType<Map>()
        .map((value) => CalendarDay.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  @override
  Future<LectionaryDay> getDay(
    DateTime date,
    String prayerBookCode, {
    String? readingType,
    String? bibleVersion,
  }) async {
    final response = await _client
        .get(
          _uri(
            '/calendar/${date.year}/${date.month}/${date.day}',
            prayerBookCode: prayerBookCode,
            readingType: readingType,
            bibleVersion: bibleVersion,
          ),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    final json = _decodeJson(response);
    if (json is! Map) {
      throw const FormatException('Resposta inválida para o dia.');
    }
    return LectionaryDay.fromJson(Map<String, dynamic>.from(json));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    debugPrint(
      '[LectionaryApi] ${response.statusCode} ${response.request?.url}',
    );
    throw ApiException(response.statusCode, response.body);
  }

  dynamic _decodeJson(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  @override
  void dispose() => _client.close();
}

List<ReadingTypeOption> _parseReadingTypeOptions(
  List<dynamic> raw, {
  String? defaultValue,
}) {
  return raw
      .map(
        (value) => value is Map
            ? ReadingTypeOption.fromJson(Map<String, dynamic>.from(value))
            : ReadingTypeOption(value: '$value'),
      )
      .where((option) => option.value.trim().isNotEmpty)
      .map(
        (option) => defaultValue == option.value
            ? option.copyWith(isDefault: true)
            : option,
      )
      .toList();
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode)';
}
