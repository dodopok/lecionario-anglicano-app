import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/app_colors.dart';
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

class DemoData {
  DemoData._();

  static const books = <PrayerBook>[
    PrayerBook(
      id: 'demo-loc-2015',
      code: 'loc_2015',
      name: 'LOC 2015',
      fullName: 'Livro de Oração Comum',
      description: 'A liturgia da Igreja Episcopal Anglicana do Brasil.',
      language: 'pt-BR',
      jurisdiction: 'IEAB',
      year: 2015,
      recommended: true,
    ),
    PrayerBook(
      id: 'demo-bcp-1979',
      code: 'bcp_1979',
      name: 'BCP 1979',
      fullName: 'Book of Common Prayer',
      description: 'The Episcopal Church in the United States.',
      language: 'en-US',
      jurisdiction: 'TEC',
      year: 1979,
    ),
    PrayerBook(
      id: 'demo-loc-es',
      code: 'loc_es',
      name: 'LOC 2019',
      fullName: 'Libro de Oración Común',
      description: 'La liturgia anglicana en español.',
      language: 'es-ES',
      jurisdiction: 'IAB',
      year: 2019,
    ),
  ];

  static LectionaryDay day(DateTime date) {
    return LectionaryDay(
      date: date,
      dayOfWeek: '',
      season: 'Tempo depois de Pentecostes',
      color: 'verde',
      liturgicalYear: 'C',
      weekName: '18ª semana do Tempo Comum',
      description: const [
        'Um dia comum também pode ser uma porta de entrada para a presença de Deus.',
      ],
      celebration: const Celebration(
        name: 'A vida diante de Deus',
        type: 'comemoração',
        description: 'Um convite à atenção, à escuta e à esperança.',
      ),
      readings: const [
        Reading(kind: 'first_reading', reference: '1 Reis 19:4–8'),
        Reading(kind: 'psalm', reference: 'Salmo 34:1–8'),
        Reading(kind: 'second_reading', reference: 'Efésios 4:1–7'),
        Reading(kind: 'gospel', reference: 'Lucas 9:28–36'),
      ],
      collects: const [
        Collect(
          text:
              'Deus de toda misericórdia, abre nossos olhos para reconhecer tua presença no caminho e dá-nos coragem para caminhar em tua luz.',
        ),
      ],
    );
  }

  static List<CalendarDay> month(DateTime month) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(days, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final color = switch (index % 8) {
        0 || 3 || 6 => 'verde',
        1 => 'branco',
        2 => 'vermelho',
        4 => 'roxo',
        5 => 'rosa',
        _ => 'azul',
      };
      return CalendarDay(
        date: date,
        color: color,
        celebrationName: index == 4 ? 'A vida diante de Deus' : null,
        weekName: 'Tempo Comum',
      );
    });
  }

  static Color colorFor(String color) {
    return switch (color.toLowerCase()) {
      'branco' || 'white' => AppColors.liturgicalWhite,
      'vermelho' || 'red' => AppColors.liturgicalRed,
      'roxo' || 'violeta' || 'purple' => AppColors.liturgicalPurple,
      'rosa' || 'rose' => AppColors.liturgicalRose,
      'azul' || 'blue' => AppColors.liturgicalBlue,
      _ => AppColors.liturgicalGreen,
    };
  }
}
