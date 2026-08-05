import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';

void main() {
  test('parses the lectionary API day shape', () {
    final day = LectionaryDay.fromJson({
      'date': '2026-08-05',
      'day_of_week': 'Quarta-feira',
      'liturgical_season': 'Tempo depois de Pentecostes',
      'liturgical_color': 'verde',
      'liturgical_year': 'C',
      'celebration': {'name': 'A vida diante de Deus', 'type': 'comemoração'},
      'readings': {
        'first_reading': {'reference': '1 Reis 19:4–8'},
        'psalm': {'reference': 'Salmo 34:1–8'},
        'gospel': {'reference': 'Lucas 9:28–36'},
      },
      'collect': [
        {'text': 'Deus de toda misericórdia.'},
      ],
    });

    expect(day.date, DateTime(2026, 8, 5));
    expect(day.season, 'Tempo depois de Pentecostes');
    expect(day.celebration?.name, 'A vida diante de Deus');
    expect(day.readings.map((reading) => reading.kind), [
      'first_reading',
      'psalm',
      'gospel',
    ]);
    expect(day.collects.single.text, 'Deus de toda misericórdia.');
  });

  test('maps prayer book language to the supported app locale', () {
    final book = PrayerBook.fromJson({
      'id': 'bcp',
      'code': 'bcp_1979',
      'name': 'BCP 1979',
      'full_name': 'Book of Common Prayer',
      'language': 'en-US',
      'jurisdiction': 'TEC',
      'year': 1979,
    });

    expect(book.appLanguage, AppLanguage.en);
  });

  test('supports aliases and safe defaults in API models', () {
    final portuguese = PrayerBook.fromJson({
      'id': 'loc',
      'language': 'português',
      'year': 2026.0,
      'is_recommended': true,
      'thumbnail_url': 'https://example.com/loc.png',
    });
    final spanish = PrayerBook.fromJson({
      'code': 'loc_es',
      'language': 'español',
    });
    final fallback = PrayerBook.fromJson(const {});

    expect(portuguese.code, 'loc');
    expect(portuguese.name, 'Livro de Oração Comum');
    expect(portuguese.year, 2026);
    expect(portuguese.recommended, isTrue);
    expect(portuguese.thumbnailUrl, 'https://example.com/loc.png');
    expect(portuguese.appLanguage, AppLanguage.pt);
    expect(spanish.appLanguage, AppLanguage.es);
    expect(fallback.fullName, 'Livro de Oração Comum');

    final calendarDay = CalendarDay.fromJson({
      'date': '05/08/2026',
      'liturgical_color': 'branco',
      'celebration': {'name': 'Transfiguração'},
      'week': 'Semana da Transfiguração',
    });
    expect(calendarDay.date, DateTime(2026, 8, 5));
    expect(calendarDay.color, 'branco');
    expect(calendarDay.celebrationName, 'Transfiguração');
    expect(calendarDay.weekName, 'Semana da Transfiguração');

    final celebration = Celebration.fromJson({
      'nome': 'Festa',
      'tipo_nome': 'Festival',
      'description': 'Descrição',
      'transferred': true,
    });
    final reading = Reading.fromJson({
      'kind': 'psalm',
      'referencia': 'Salmo 1',
      'texto': 'Texto',
      'versao': 'NAA',
    });
    final collect = Collect.fromJson({'texto': 'Coleta', 'title': 'Título'});

    expect(celebration.name, 'Festa');
    expect(celebration.type, 'Festival');
    expect(celebration.description, 'Descrição');
    expect(celebration.transferred, isTrue);
    expect(reading.kind, 'psalm');
    expect(reading.reference, 'Salmo 1');
    expect(reading.text, 'Texto');
    expect(reading.translation, 'NAA');
    expect(collect.text, 'Coleta');
    expect(collect.title, 'Título');
  });

  test('parses list readings, collect variants and descriptions', () {
    final day = LectionaryDay.fromJson({
      'date': DateTime(2026, 8, 5),
      'weekDay': 'Wednesday',
      'season': 'Season',
      'color': 'green',
      'cycle': 'A',
      'week': 'Week',
      'sunday_name': 'Sunday',
      'description': 'A single description',
      'celebration': {'name': 'Celebration'},
      'readings': [
        {'type': 'gospel', 'reference': 'John 1', 'text': 'In the beginning'},
        'ignored',
      ],
      'coletas': [
        {'texto': 'First collect'},
        'Second collect',
        null,
      ],
    });

    expect(day.date, DateTime(2026, 8, 5));
    expect(day.dayOfWeek, 'Wednesday');
    expect(day.season, 'Season');
    expect(day.color, 'green');
    expect(day.liturgicalYear, 'A');
    expect(day.weekName, 'Week');
    expect(day.sundayName, 'Sunday');
    expect(day.description, ['A single description']);
    expect(day.celebration?.name, 'Celebration');
    expect(day.readings.single.kind, 'gospel');
    expect(day.collects.map((item) => item.text), [
      'First collect',
      'Second collect',
    ]);

    final mapCollect = LectionaryDay.fromJson({
      'date': '2026-08-05',
      'collects': {'text': 'Map collect'},
    });
    final textCollect = LectionaryDay.fromJson({
      'date': '2026-08-05',
      'collect': 'Text collect',
    });

    expect(mapCollect.collects.single.text, 'Map collect');
    expect(textCollect.collects.single.text, 'Text collect');
    expect(textCollect.season, 'Tempo Comum');
    expect(textCollect.color, 'verde');
  });

  test('parses ISO, Brazilian and fallback dates', () {
    expect(parseApiDate(DateTime(2026, 8, 5)), DateTime(2026, 8, 5));
    expect(parseApiDate('2026-08-05T12:00:00Z'), DateTime(2026, 8, 5));
    expect(parseApiDate('05/08/2026'), DateTime(2026, 8, 5));

    final fallback = parseApiDate('not-a-date');
    expect(fallback.year, DateTime.now().year);
    expect(fallback.month, DateTime.now().month);
    expect(fallback.day, DateTime.now().day);
  });
}
