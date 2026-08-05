import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/data/services/lectionary_api.dart';
import 'package:lecionario_anglicano/data/services/local_preferences.dart';

class FakeLectionaryDataSource implements LectionaryDataSource {
  FakeLectionaryDataSource({
    List<PrayerBook>? books,
    LectionaryDay Function(DateTime date)? dayBuilder,
  }) : books = books ?? [testBook(code: 'loc_2015', name: 'LOC 2015')],
       dayBuilder = dayBuilder ?? testDay;

  List<PrayerBook> books;
  LectionaryDay Function(DateTime date) dayBuilder;
  final List<DateTime> requestedDates = [];
  final List<DateTime> requestedMonths = [];
  int getPrayerBooksCalls = 0;
  int getCalendarMonthCalls = 0;
  int getDayCalls = 0;
  bool failPrayerBooks = false;
  bool failCalendarMonth = false;
  bool failDay = false;
  bool disposed = false;

  @override
  Future<List<PrayerBook>> getPrayerBooks() async {
    getPrayerBooksCalls++;
    if (failPrayerBooks) throw StateError('books unavailable');
    return books;
  }

  @override
  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String prayerBookCode,
  ) async {
    getCalendarMonthCalls++;
    requestedMonths.add(month);
    if (failCalendarMonth) throw StateError('month unavailable');
    return testMonth(month);
  }

  @override
  Future<LectionaryDay> getDay(DateTime date, String prayerBookCode) async {
    getDayCalls++;
    requestedDates.add(date);
    if (failDay) throw StateError('day unavailable');
    return dayBuilder(date);
  }

  @override
  void dispose() {
    disposed = true;
  }
}

Future<LocalPreferences> createLocalPreferences([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return LocalPreferences(preferences);
}

PrayerBook testBook({
  String code = 'loc_test',
  String name = 'LOC Teste',
  AppLanguage language = AppLanguage.pt,
}) {
  return PrayerBook(
    id: code,
    code: code,
    name: name,
    fullName: name,
    description: 'Livro de teste.',
    language: switch (language) {
      AppLanguage.pt => 'pt-BR',
      AppLanguage.en => 'en-US',
      AppLanguage.es => 'es-ES',
    },
    jurisdiction: 'TEST',
    year: 2026,
  );
}

LectionaryDay testDay(DateTime date) {
  return LectionaryDay(
    date: date,
    dayOfWeek: 'Quarta-feira',
    season: 'Tempo de teste',
    color: 'verde',
    liturgicalYear: 'C',
    weekName: 'Semana de teste',
    celebration: const Celebration(name: 'Celebração de teste'),
    readings: const [
      Reading(kind: 'gospel', reference: 'João 1:1–5', text: 'No princípio.'),
    ],
    collects: const [Collect(text: 'Coleta de teste.')],
  );
}

List<CalendarDay> testMonth(DateTime month) {
  return List.generate(
    DateUtils.getDaysInMonth(month.year, month.month),
    (index) => CalendarDay(
      date: DateTime(month.year, month.month, index + 1),
      color: index.isEven ? 'verde' : 'branco',
      celebrationName: index == 4 ? 'Celebração de teste' : null,
      weekName: 'Semana de teste',
    ),
  );
}
