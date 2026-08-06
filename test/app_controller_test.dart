import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';

import 'helpers/test_doubles.dart';

void main() {
  test('initializes into LOC selection when no LOC is persisted', () async {
    final source = FakeLectionaryDataSource();
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.isInitializing, isFalse);
    expect(controller.needsPrayerBook, isTrue);
    expect(controller.prayerBooks, isNotEmpty);
    expect(source.getDayCalls, 0);
    expect(source.getCalendarMonthCalls, 0);
  });

  test('does not request calendar data without a selected LOC', () async {
    final source = FakeLectionaryDataSource();
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    expect(controller.monthDays(DateTime.now()), isEmpty);
    await controller.loadForDate(DateTime.now());

    expect(source.getDayCalls, 0);
    expect(source.getCalendarMonthCalls, 0);
  });

  test('restores a LOC and loads the current day and month', () async {
    final source = FakeLectionaryDataSource(dayBuilder: testDay);
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': 'loc_2015',
      'app_language': 'pt',
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.selectedPrayerBookCode, 'loc_2015');
    expect(controller.selectedPrayerBook?.name, 'LOC 2015');
    expect(controller.selectedDay?.season, 'Tempo de teste');
    expect(controller.monthDays(DateTime.now()), isNotEmpty);
    expect(source.getDayCalls, 1);
    expect(source.getCalendarMonthCalls, 1);
  });

  test(
    'fetches a mobile day preview without replacing the primary day',
    () async {
      final source = FakeLectionaryDataSource(dayBuilder: testDay);
      final controller = AppController(
        api: source,
        localPreferences: await createLocalPreferences({
          'selected_prayer_book_code': 'loc_2015',
        }),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      final primaryDate = controller.selectedDay!.date;
      final previewDate = DateTime(primaryDate.year, primaryDate.month, 7);

      final preview = await controller.fetchDayForDate(previewDate);
      await controller.loadMonth(
        DateTime(primaryDate.year, primaryDate.month + 1),
      );

      expect(preview?.date, previewDate);
      expect(controller.selectedDay?.date, primaryDate);
      expect(source.getDayCalls, 2);
      expect(
        source.requestedMonths,
        contains(DateTime(primaryDate.year, primaryDate.month + 1)),
      );
    },
  );

  test(
    'choosing a LOC persists it, clears the cache and reloads content',
    () async {
      final book = testBook();
      final source = FakeLectionaryDataSource(
        books: [book],
        dayBuilder: testDay,
      );
      final preferences = await createLocalPreferences();
      final controller = AppController(
        api: source,
        localPreferences: preferences,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.choosePrayerBook(book);

      expect(controller.selectedPrayerBookCode, book.code);
      expect(preferences.selectedPrayerBookCode, book.code);
      expect(controller.selectedDay?.readings.single.reference, 'João 1:1–5');
      expect(source.getDayCalls, 1);
      expect(source.getCalendarMonthCalls, 1);
    },
  );

  test('loads and persists reading type and Bible preferences', () async {
    final book = testBook(
      readingTypes: const [
        ReadingTypeOption(
          value: 'semicontinuous',
          label: 'Semi-Contínuas',
          isDefault: true,
        ),
        ReadingTypeOption(value: 'complementary', label: 'Complementares'),
      ],
      defaultReadingType: 'semicontinuous',
    );
    const secondBible = BibleVersion(
      id: 'naa',
      code: 'naa',
      name: 'NAA',
      fullName: 'Nova Almeida Atualizada',
      language: 'pt-BR',
    );
    final source = FakeLectionaryDataSource(
      books: [book],
      bibleVersions: const [
        BibleVersion(
          id: 'nvi',
          code: 'nvi',
          name: 'NVI',
          language: 'pt-BR',
          recommended: true,
        ),
        secondBible,
      ],
      dayBuilder: testDay,
    );
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': book.code,
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.selectedReadingType, 'semicontinuous');
    expect(controller.selectedBibleVersionCode, 'nvi');
    expect(controller.readingTypeOptions, hasLength(2));
    expect(controller.bibleVersions, hasLength(2));

    final date = DateTime(2026, 8, 5);
    await controller.setReadingType('complementary', date);
    expect(preferences.selectedReadingType, 'complementary');
    expect(source.requestedReadingTypes, contains('complementary'));

    await controller.chooseBibleVersion(secondBible, date);
    expect(preferences.selectedBibleVersionCode, 'naa');
    expect(source.requestedBibleVersions, contains('naa'));
  });

  test(
    'does not reuse a saved reading type for an LOC that lacks it',
    () async {
      final book = testBook(
        readingTypes: const [
          ReadingTypeOption(value: 'semicontinuous', isDefault: true),
        ],
        defaultReadingType: 'semicontinuous',
      );
      final controller = AppController(
        api: FakeLectionaryDataSource(books: [book]),
        localPreferences: await createLocalPreferences({
          'selected_prayer_book_code': book.code,
          'selected_reading_type': 'complementary',
        }),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.selectedReadingType, 'semicontinuous');
    },
  );

  test('persists language changes and filters available LOCs', () async {
    final source = FakeLectionaryDataSource(
      books: [
        testBook(code: 'loc_pt', language: AppLanguage.pt),
        testBook(code: 'loc_en', name: 'BCP Test', language: AppLanguage.en),
      ],
    );
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.setLanguage(AppLanguage.en);

    expect(controller.locale, AppLanguage.en);
    expect(preferences.language, AppLanguage.en);
    expect(controller.booksForCurrentLanguage.single.code, 'loc_en');
  });

  test(
    'switching language clears the incompatible LOC and keeps the new list',
    () async {
      final englishBook = testBook(
        code: 'loc_en',
        name: 'BCP Test',
        language: AppLanguage.en,
      );
      final portugueseBook = testBook(code: 'loc_pt', language: AppLanguage.pt);
      final source = FakeLectionaryDataSource(
        books: [portugueseBook, englishBook],
        dayBuilder: testDay,
      );
      final preferences = await createLocalPreferences({
        'selected_prayer_book_code': portugueseBook.code,
      });
      final controller = AppController(
        api: source,
        localPreferences: preferences,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.setLanguage(AppLanguage.en);

      expect(controller.locale, AppLanguage.en);
      expect(controller.selectedPrayerBookCode, isNull);
      expect(preferences.selectedPrayerBookCode, isNull);
      expect(controller.booksForCurrentLanguage, [englishBook]);

      await controller.choosePrayerBook(englishBook);

      expect(controller.selectedPrayerBookCode, englishBook.code);
      expect(source.requestedBibleLanguages, contains('en-US'));
    },
  );

  test(
    'reuses cached months while still refreshing the selected day',
    () async {
      final source = FakeLectionaryDataSource(dayBuilder: testDay);
      final preferences = await createLocalPreferences({
        'selected_prayer_book_code': 'loc_2015',
      });
      final controller = AppController(
        api: source,
        localPreferences: preferences,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      final firstMonthCalls = source.getCalendarMonthCalls;

      await controller.selectDate(DateTime.now().add(const Duration(days: 2)));

      expect(source.getCalendarMonthCalls, firstMonthCalls);
      expect(source.getDayCalls, 2);
    },
  );

  test('does not fabricate content when network loading fails', () async {
    final source = FakeLectionaryDataSource();
    source.failDay = true;
    source.failCalendarMonth = true;
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': 'loc_2015',
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.lastError, isNotNull);
    expect(controller.selectedDay, isNull);
    expect(controller.monthDays(DateTime.now()), isEmpty);
  });

  test('keeps the LOC list empty when loading the book list fails', () async {
    final source = FakeLectionaryDataSource();
    source.failPrayerBooks = true;
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': 'book_that_does_not_exist',
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.lastError, contains('books unavailable'));
    expect(controller.prayerBooks, isEmpty);
    expect(controller.selectedPrayerBookCode, isNull);
    expect(controller.needsPrayerBook, isTrue);
    expect(source.getDayCalls, 0);
  });

  test('keeps the LOC list empty when the API returns no books', () async {
    final source = FakeLectionaryDataSource(books: const []);
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.prayerBooks, isEmpty);
    expect(controller.needsPrayerBook, isTrue);
  });

  test('clears month cache when changing the selected LOC', () async {
    final first = testBook();
    final second = testBook(code: 'loc_second', name: 'Segundo LOC');
    final source = FakeLectionaryDataSource(
      books: [first, second],
      dayBuilder: testDay,
    );
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': first.code,
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(source.getCalendarMonthCalls, 1);

    await controller.choosePrayerBook(second);

    expect(controller.selectedPrayerBookCode, second.code);
    expect(preferences.selectedPrayerBookCode, second.code);
    expect(source.getCalendarMonthCalls, 2);
  });

  test('does not expose books from another language when none match', () async {
    final book = testBook(language: AppLanguage.pt);
    final source = FakeLectionaryDataSource(books: [book]);
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.setLanguage(AppLanguage.es);

    expect(controller.booksForCurrentLanguage, isEmpty);
  });

  test('remembers where the calendar puts Sunday', () async {
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.sundayInCenter, isFalse);
    expect(controller.calendarFirstWeekday, DateTime.sunday);

    var notified = 0;
    controller.addListener(() => notified++);
    await controller.setSundayInCenter(true);

    expect(controller.calendarFirstWeekday, DateTime.thursday);
    expect(preferences.sundayInCenter, isTrue);
    expect(notified, 1);

    await controller.setSundayInCenter(true);
    expect(notified, 1);
  });

  test('restores the calendar layout on the next launch', () async {
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences({
        'sunday_in_center': true,
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.sundayInCenter, isTrue);
    expect(controller.calendarFirstWeekday, DateTime.thursday);
  });

  test('disposes its data source', () async {
    final source = FakeLectionaryDataSource();
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );

    controller.dispose();

    expect(source.disposed, isTrue);
  });
}
