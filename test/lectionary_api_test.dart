import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lecionario_anglicano/data/services/lectionary_api.dart';

void main() {
  test('fetches prayer books with the internal app header', () async {
    http.BaseRequest? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'data': [
            {
              'id': 'loc-test',
              'code': 'loc_test',
              'name': 'LOC Teste',
              'full_name': 'Livro de Teste',
              'language': 'pt-BR',
              'jurisdiction': 'TEST',
              'year': 2026,
              'thumbnail_url': 'https://example.test/loc.png',
              'features': {
                'lectionary': {
                  'reading_types': ['semicontinuous', 'complementary'],
                  'default_reading_type': 'semicontinuous',
                },
              },
            },
          ],
        }),
        200,
      );
    });
    final api = LectionaryApi(
      client: client,
      baseUrl: 'https://api.test/api/v1',
      internalIdentifier: 'test-internal-id',
    );
    addTearDown(api.dispose);

    final books = await api.getPrayerBooks();

    expect(books.single.code, 'loc_test');
    expect(books.single.coverUrl, 'https://example.test/loc.png');
    expect(books.single.readingTypes.map((option) => option.value), [
      'semicontinuous',
      'complementary',
    ]);
    expect(capturedRequest?.method, 'GET');
    expect(
      capturedRequest?.url.toString(),
      'https://api.test/api/v1/prayer_books',
    );
    expect(capturedRequest?.headers['X-App-Internal-Id'], 'test-internal-id');
    expect(capturedRequest?.headers['Content-Type'], 'application/json');
  });

  test('does not send X-API-Key when no key is configured', () async {
    http.BaseRequest? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(jsonEncode({'data': []}), 200);
    });
    final api = LectionaryApi(
      client: client,
      baseUrl: 'https://api.test/api/v1',
      internalIdentifier: 'test-internal-id',
    );
    addTearDown(api.dispose);

    await api.getPrayerBooks();

    expect(capturedRequest?.headers.containsKey('X-API-Key'), isFalse);
  });

  test('sends X-API-Key alongside the app header when configured', () async {
    http.BaseRequest? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(jsonEncode({'data': []}), 200);
    });
    final api = LectionaryApi(
      client: client,
      baseUrl: 'https://api.test/api/v1',
      internalIdentifier: 'test-internal-id',
      apiKey: 'estevao_beta_key',
    );
    addTearDown(api.dispose);

    await api.getPrayerBooks();

    expect(capturedRequest?.headers['X-API-Key'], 'estevao_beta_key');
    expect(capturedRequest?.headers['X-App-Internal-Id'], 'test-internal-id');
  });

  test(
    'reads reading type options and labels from the prayer book API',
    () async {
      http.BaseRequest? capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'categories': [
                {
                  'key': 'lectionary',
                  'preferences': [
                    {
                      'key': 'reading_type',
                      'default_value': 'semicontinuous',
                      'options': [
                        {
                          'value': 'semicontinuous',
                          'label': 'Leituras Semi-Contínuas',
                        },
                        {
                          'value': 'complementary',
                          'label': 'Leituras Complementares',
                        },
                      ],
                    },
                  ],
                },
              ],
            }),
          ),
          200,
        );
      });
      final api = LectionaryApi(
        client: client,
        baseUrl: 'https://api.test/api/v1',
        internalIdentifier: 'test-id',
      );
      addTearDown(api.dispose);

      final options = await api.getReadingTypeOptions('loc_2015');

      expect(
        capturedRequest?.url.path,
        '/api/v1/prayer_books/loc_2015/preferences',
      );
      expect(options.map((option) => option.value), [
        'semicontinuous',
        'complementary',
      ]);
      expect(options.first.label, 'Leituras Semi-Contínuas');
      expect(options.first.isDefault, isTrue);
    },
  );

  test(
    'fetches Bible versions with the app header and language filter',
    () async {
      http.BaseRequest? capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'data': [
                {
                  'id': 'nvi',
                  'code': 'NVI',
                  'name': 'NVI',
                  'full_name': 'Nova Versão Internacional',
                  'language': 'pt-BR',
                  'year': 2011,
                  'is_recommended': true,
                },
              ],
            }),
          ),
          200,
        );
      });
      final api = LectionaryApi(
        client: client,
        baseUrl: 'https://api.test/api/v1',
        internalIdentifier: 'test-id',
      );
      addTearDown(api.dispose);

      final versions = await api.getBibleVersions(language: 'pt-BR');

      expect(capturedRequest?.url.path, '/api/v1/bible_versions');
      expect(capturedRequest?.url.queryParameters['language'], 'pt-BR');
      expect(capturedRequest?.headers['X-App-Internal-Id'], 'test-id');
      expect(versions.single.code, 'nvi');
      expect(versions.single.fullName, 'Nova Versão Internacional');
      expect(versions.single.recommended, isTrue);
    },
  );

  test('encodes the selected prayer book in calendar preferences', () async {
    http.BaseRequest? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode([
            {
              'date': '2026-08-05',
              'color': 'verde',
              'celebration_name': 'Celebração',
              'week_name': 'Semana',
            },
          ]),
        ),
        200,
      );
    });
    final api = LectionaryApi(
      client: client,
      baseUrl: 'https://api.test/api/v1',
      internalIdentifier: 'test-id',
    );
    addTearDown(api.dispose);

    final days = await api.getCalendarMonth(DateTime(2026, 8), 'loc_2015');
    final preferences =
        jsonDecode(capturedRequest!.url.queryParameters['preferences']!)
            as Map<String, dynamic>;

    expect(capturedRequest!.url.path, '/api/v1/calendar/2026/8');
    expect(preferences['prayer_book_code'], 'loc_2015');
    expect(days.single.date, DateTime(2026, 8, 5));
    expect(days.single.celebrationName, 'Celebração');
  });

  test('parses a day response and sends its date and LOC', () async {
    http.BaseRequest? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'date': '2026-08-05',
            'day_of_week': 'Quarta-feira',
            'liturgical_season': 'Tempo Comum',
            'liturgical_color': 'verde',
            'readings': {
              'gospel': {'reference': 'João 1:1–5'},
            },
          }),
        ),
        200,
      );
    });
    final api = LectionaryApi(
      client: client,
      baseUrl: 'https://api.test/api/v1',
      internalIdentifier: 'test-id',
    );
    addTearDown(api.dispose);

    final day = await api.getDay(
      DateTime(2026, 8, 5),
      'loc_2015',
      readingType: 'complementary',
      bibleVersion: 'nvi',
    );
    final preferences =
        jsonDecode(capturedRequest!.url.queryParameters['preferences']!)
            as Map<String, dynamic>;

    expect(capturedRequest!.url.path, '/api/v1/calendar/2026/8/5');
    expect(preferences['prayer_book_code'], 'loc_2015');
    expect(preferences['reading_type'], 'complementary');
    expect(preferences['bible_version'], 'nvi');
    expect(day.readings.single.reference, 'João 1:1–5');
  });

  test('accepts a top-level list for prayer books', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'id': 'loc-test',
            'code': 'loc_test',
            'name': 'LOC Teste',
            'language': 'pt-BR',
            'jurisdiction': 'TEST',
            'year': 2026,
          },
        ]),
        200,
      );
    });
    final api = LectionaryApi(client: client, baseUrl: 'https://api.test');
    addTearDown(api.dispose);

    expect((await api.getPrayerBooks()).single.code, 'loc_test');
  });

  test('surfaces non-success responses as ApiException', () async {
    final client = MockClient(
      (request) async => http.Response('{"error":"unauthorized"}', 401),
    );
    final api = LectionaryApi(client: client, baseUrl: 'https://api.test');
    addTearDown(api.dispose);

    await expectLater(
      api.getPrayerBooks(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });

  test('rejects an invalid day response shape', () async {
    final client = MockClient((request) async => http.Response('[]', 200));
    final api = LectionaryApi(client: client, baseUrl: 'https://api.test');
    addTearDown(api.dispose);

    await expectLater(
      api.getDay(DateTime(2026, 8, 5), 'loc'),
      throwsFormatException,
    );
  });

  test(
    'handles successful empty payloads and exposes API error text',
    () async {
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/prayer_books')) {
          return http.Response('{}', 200);
        }
        if (request.url.path.endsWith('/8')) {
          return http.Response('{}', 200);
        }
        return http.Response('{}', 200);
      });
      final api = LectionaryApi(client: client, baseUrl: 'https://api.test');
      addTearDown(api.dispose);

      expect(await api.getPrayerBooks(), isEmpty);
      expect(await api.getCalendarMonth(DateTime(2026, 8), 'loc'), isEmpty);
      await expectLater(
        api.getDay(DateTime(2026, 8, 5), 'loc'),
        throwsFormatException,
      );
      expect(
        const ApiException(503, 'offline').toString(),
        'ApiException(503)',
      );
    },
  );
}
