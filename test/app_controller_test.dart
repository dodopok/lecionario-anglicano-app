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
    expect(controller.isDemoMode, isFalse);
  });

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

  test('uses local preview data when network loading fails', () async {
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

    expect(controller.isDemoMode, isTrue);
    expect(controller.lastError, isNotNull);
    expect(controller.selectedDay, isNotNull);
    expect(controller.monthDays(DateTime.now()), isNotEmpty);
  });

  test(
    'falls back to all books when the current language has no matches',
    () async {
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

      expect(controller.booksForCurrentLanguage, [book]);
    },
  );

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
