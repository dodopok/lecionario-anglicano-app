import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/data/services/lectionary_api.dart';
import 'package:lecionario_anglicano/data/services/local_preferences.dart';

class FakeLectionaryDataSource implements LectionaryDataSource {
  FakeLectionaryDataSource({
    List<PrayerBook>? books,
    List<BibleVersion>? bibleVersions,
    LectionaryDay Function(DateTime date)? dayBuilder,
    List<CalendarDay> Function(DateTime month)? monthBuilder,
    this.dayDelay,
  }) : books = books ?? [testBook(code: 'loc_2015', name: 'LOC 2015')],
       monthBuilder = monthBuilder ?? testMonth,
       bibleVersions =
           bibleVersions ??
           const [
             BibleVersion(
               id: 'nvi',
               code: 'nvi',
               name: 'NVI',
               fullName: 'Nova Versão Internacional',
               language: 'pt-BR',
               recommended: true,
             ),
           ],
       dayBuilder = dayBuilder ?? testDay;

  List<PrayerBook> books;
  List<BibleVersion> bibleVersions;
  LectionaryDay Function(DateTime date) dayBuilder;
  List<CalendarDay> Function(DateTime month) monthBuilder;

  /// Holds getDay open, so a loading state can be looked at. Set it after the
  /// controller has initialised: a delay awaited outside a pump never returns.
  Duration? dayDelay;
  final List<DateTime> requestedDates = [];
  final List<DateTime> requestedMonths = [];
  final List<String?> requestedReadingTypes = [];
  final List<String?> requestedBibleVersions = [];
  final List<String?> requestedBibleLanguages = [];
  int getPrayerBooksCalls = 0;
  int getReadingTypeOptionsCalls = 0;
  int getBibleVersionsCalls = 0;
  int getCalendarMonthCalls = 0;
  int getDayCalls = 0;
  bool failPrayerBooks = false;
  bool failReadingTypeOptions = false;
  bool failBibleVersions = false;
  bool failCalendarMonth = false;
  bool failDay = false;
  bool disposed = false;

  /// Fails as a lost connection rather than a bad response.
  bool failAsOffline = false;

  Object get _failure => failAsOffline
      ? http.ClientException('Failed host lookup')
      : StateError('unavailable');

  /// Fails everything, the way a device with no connection does.
  void goOffline() {
    failAsOffline = true;
    failPrayerBooks = true;
    failCalendarMonth = true;
    failDay = true;
  }

  void goOnline() {
    failAsOffline = false;
    failPrayerBooks = false;
    failCalendarMonth = false;
    failDay = false;
  }

  @override
  Future<List<PrayerBook>> getPrayerBooks() async {
    getPrayerBooksCalls++;
    if (failPrayerBooks) throw _failure;
    return books;
  }

  @override
  Future<List<ReadingTypeOption>> getReadingTypeOptions(
    String prayerBookCode,
  ) async {
    getReadingTypeOptionsCalls++;
    if (failReadingTypeOptions) {
      throw StateError('reading type options unavailable');
    }
    for (final book in books) {
      if (book.code == prayerBookCode) return book.readingTypes;
    }
    return const [];
  }

  @override
  Future<List<BibleVersion>> getBibleVersions({String? language}) async {
    getBibleVersionsCalls++;
    requestedBibleLanguages.add(language);
    if (failBibleVersions) throw StateError('bible versions unavailable');
    return bibleVersions;
  }

  @override
  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String prayerBookCode, {
    String? readingType,
    String? bibleVersion,
  }) async {
    getCalendarMonthCalls++;
    requestedMonths.add(month);
    requestedReadingTypes.add(readingType);
    requestedBibleVersions.add(bibleVersion);
    if (failCalendarMonth) throw _failure;
    return monthBuilder(month);
  }

  @override
  Future<LectionaryDay> getDay(
    DateTime date,
    String prayerBookCode, {
    String? readingType,
    String? bibleVersion,
  }) async {
    getDayCalls++;
    requestedDates.add(date);
    requestedReadingTypes.add(readingType);
    requestedBibleVersions.add(bibleVersion);
    if (failDay) throw _failure;
    if (dayDelay != null) await Future<void>.delayed(dayDelay!);
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
  String? thumbnailUrl,
  bool recommended = false,
  List<ReadingTypeOption> readingTypes = const [],
  String? defaultReadingType,
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
    recommended: recommended,
    thumbnailUrl: thumbnailUrl,
    readingTypes: readingTypes,
    defaultReadingType: defaultReadingType,
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
