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
}
