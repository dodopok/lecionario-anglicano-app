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
}

abstract interface class LectionaryDataSource {
  Future<List<PrayerBook>> getPrayerBooks();

  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String prayerBookCode,
  );

  Future<LectionaryDay> getDay(DateTime date, String prayerBookCode);

  void dispose();
}

class LectionaryApi implements LectionaryDataSource {
  LectionaryApi({
    http.Client? client,
    String? baseUrl,
    String? internalIdentifier,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _internalIdentifier = internalIdentifier ?? ApiConfig.internalIdentifier;

  final http.Client _client;
  final String _baseUrl;
  final String _internalIdentifier;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-App-Internal-Id': _internalIdentifier,
  };

  Uri _uri(String path, {String? prayerBookCode, Map<String, String>? extra}) {
    final query = <String, String>{...?extra};
    if (prayerBookCode != null) {
      query['preferences'] = jsonEncode({'prayer_book_code': prayerBookCode});
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
  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String prayerBookCode,
  ) async {
    final response = await _client
        .get(
          _uri(
            '/calendar/${month.year}/${month.month}',
            prayerBookCode: prayerBookCode,
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
  Future<LectionaryDay> getDay(DateTime date, String prayerBookCode) async {
    final response = await _client
        .get(
          _uri(
            '/calendar/${date.year}/${date.month}/${date.day}',
            prayerBookCode: prayerBookCode,
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

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode)';
}
