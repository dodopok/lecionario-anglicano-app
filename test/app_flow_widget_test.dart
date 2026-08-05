import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';
import 'package:lecionario_anglicano/presentation/app_shell.dart';
import 'package:lecionario_anglicano/presentation/screens/home_screen.dart';
import 'package:lecionario_anglicano/presentation/screens/loc_selection_screen.dart';
import 'package:lecionario_anglicano/presentation/screens/settings_screen.dart';
import 'package:lecionario_anglicano/presentation/widgets/design_primitives.dart';
import 'package:lecionario_anglicano/presentation/widgets/home_sections.dart';

import 'helpers/pump_app.dart';
import 'helpers/test_doubles.dart';

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('shows a launch state before the controller initializes', (
    tester,
  ) async {
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      testMaterialApp(home: AppShell(controller: controller)),
    );
    expect(find.text('LECIONÁRIO'), findsOneWidget);

    await controller.initialize();
    await tester.pumpWidget(
      testMaterialApp(home: AppShell(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LocSelectionScreen), findsOneWidget);
  });

  testWidgets('starts with LOC selection and enters the home experience', (
    tester,
  ) async {
    final source = FakeLectionaryDataSource(
      books: [testBook()],
      dayBuilder: testDay,
    );
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(testControllerApp(controller));
    await tester.pumpAndSettle();

    expect(find.byType(LocSelectionScreen), findsOneWidget);
    expect(find.text('Escolha o seu\nLivro de Oração'), findsOneWidget);
    expect(find.text('LOC Teste'), findsOneWidget);

    final continueButton = find.text('Entrar no lecionário');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(controller.selectedPrayerBookCode, 'loc_test');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('Tempo de teste'), findsOneWidget);
  });

  testWidgets('keeps the LOC entry action in a fixed footer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(testControllerApp(controller));
    await tester.pumpAndSettle();

    final footer = find.byKey(const ValueKey('loc-selection-footer'));
    expect(footer, findsOneWidget);
    expect(tester.getRect(footer).bottom, closeTo(844, 1));
    expect(find.text('Entrar no lecionário'), findsOneWidget);
  });

  testWidgets('switches onboarding copy and LOC list to English', (
    tester,
  ) async {
    final source = FakeLectionaryDataSource(
      books: [
        testBook(language: AppLanguage.pt),
        testBook(code: 'bcp_test', name: 'BCP Test', language: AppLanguage.en),
      ],
    );
    final preferences = await createLocalPreferences();
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(testControllerApp(controller));
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(controller.locale, AppLanguage.en);
    expect(find.text('Choose your\nPrayer Book'), findsOneWidget);
    expect(find.text('BCP Test'), findsOneWidget);
    expect(find.text('LOC Teste'), findsNothing);
  });

  testWidgets('selects a different LOC from the narrow onboarding layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final source = FakeLectionaryDataSource(
      books: [
        testBook(),
        testBook(code: 'loc_second', name: 'Segundo LOC'),
      ],
      dayBuilder: testDay,
    );
    final controller = AppController(
      api: source,
      localPreferences: await createLocalPreferences(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(testControllerApp(controller));
    await tester.pumpAndSettle();

    final secondBook = find.text('Segundo LOC');
    await tester.ensureVisible(secondBook);
    await tester.tap(secondBook);
    await tester.pumpAndSettle();

    final continueButton = find.text('Entrar no lecionário');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(controller.selectedPrayerBookCode, 'loc_second');
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('renders the month, the readings and opens a reading', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final source = FakeLectionaryDataSource(
      books: [testBook()],
      dayBuilder: testDay,
    );
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': 'loc_test',
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('LEITURAS DE HOJE'), findsOneWidget);
    expect(find.text('João 1:1–5'), findsOneWidget);
    expect(find.text('COLETA DO DIA'), findsOneWidget);
    expect(find.text('Semana'), findsNothing);
    expect(find.text('Mês'), findsNothing);
    expect(
      find.text(AppCopy(AppLanguage.pt).monthYear(DateTime.now())),
      findsOneWidget,
    );

    final reading = find.text('João 1:1–5');
    await tester.ensureVisible(reading);
    await tester.tap(reading);
    await tester.pumpAndSettle();
    expect(find.text('No princípio.'), findsOneWidget);
  });

  testWidgets('shows home skeletons while the date is loading', (tester) async {
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_2015',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.isLoadingDay = true;
    controller.notifyListeners();
    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.byType(SkeletonBox), findsWidgets);
    expect(find.text('Tempo de teste'), findsNothing);
  });

  testWidgets('keeps the hero height stable while date data loads', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final copy = AppCopy(AppLanguage.pt);
    final date = DateTime(2026, 8, 5);

    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: DailyHero(
            day: null,
            activeDate: date,
            copy: copy,
            isLoading: true,
            onToday: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final loadingHeight = tester.getSize(find.byType(DailyHero)).height;

    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: DailyHero(
            day: testDay(date),
            activeDate: date,
            copy: copy,
            isLoading: false,
            onToday: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final loadedHeight = tester.getSize(find.byType(DailyHero)).height;

    expect(loadedHeight, closeTo(loadingHeight, .1));
  });

  testWidgets('renders the month calendar on a narrow home layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final source = FakeLectionaryDataSource(
      books: [testBook()],
      dayBuilder: testDay,
    );
    final controller = AppController(
      api: source,
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppCopy(AppLanguage.pt).monthYear(DateTime.now())),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'opens a selected mobile day in a detail sheet without replacing today',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateUtils.dateOnly(DateTime.now());
      final selectedDate = today.day == 1
          ? DateTime(today.year, today.month, 2)
          : DateTime(today.year, today.month, 1);
      final source = FakeLectionaryDataSource(
        books: [testBook()],
        dayBuilder: (date) {
          final isPrimary = DateUtils.isSameDay(date, today);
          return LectionaryDay(
            date: date,
            dayOfWeek: 'Dia de teste',
            season: isPrimary ? 'Dia principal' : 'Dia do painel',
            color: 'verde',
            readings: [
              Reading(
                kind: 'gospel',
                reference: isPrimary ? 'João 1:1–5' : 'Salmo 1',
                text: isPrimary ? 'Texto principal.' : 'Texto do painel.',
              ),
            ],
          );
        },
      );
      final controller = AppController(
        api: source,
        localPreferences: await createLocalPreferences({
          'selected_prayer_book_code': 'loc_test',
        }),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      await tester.pumpWidget(
        testMaterialApp(home: HomeScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dia principal'), findsOneWidget);
      final dayKey = ValueKey(
        'month-day-${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
      );
      await tester.tap(find.byKey(dayKey));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('mobile-day-detail-sheet')),
        findsOneWidget,
      );
      expect(find.text('Dia do painel'), findsOneWidget);
      expect(find.text('Salmo 1'), findsOneWidget);
      expect(find.text('LEITURAS DO DIA'), findsOneWidget);
      expect(DateUtils.isSameDay(controller.selectedDay?.date, today), isTrue);

      await tester.tap(find.byKey(const ValueKey('mobile-day-detail-close')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('mobile-day-detail-sheet')),
        findsNothing,
      );
      expect(find.text('Dia principal'), findsOneWidget);
    },
  );

  testWidgets('uses API LOC covers and persists reading and Bible choices', (
    tester,
  ) async {
    final book = testBook(
      thumbnailUrl: 'https://example.test/loc.png',
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

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.text('SEQUÊNCIA DAS LEITURAS'), findsNothing);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Preferências do lecionário'), findsOneWidget);
    expect(find.text('Preferências'), findsOneWidget);
    expect(find.text('SEQUÊNCIA DAS LEITURAS'), findsOneWidget);
    expect(find.text('VERSÃO DA BÍBLIA'), findsOneWidget);
    expect(find.text('NVI'), findsOneWidget);

    await tester.tap(find.text('SEQUÊNCIA DAS LEITURAS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complementares'));
    await tester.pumpAndSettle();
    expect(controller.selectedReadingType, 'complementary');
    expect(preferences.selectedReadingType, 'complementary');

    await tester.tap(find.text('VERSÃO DA BÍBLIA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NAA'));
    await tester.pumpAndSettle();
    expect(controller.selectedBibleVersionCode, 'naa');
    expect(preferences.selectedBibleVersionCode, 'naa');
  });

  testWidgets('changes language from settings on a narrow layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final source = FakeLectionaryDataSource(
      books: [
        testBook(),
        testBook(code: 'bcp_test', name: 'BCP Test', language: AppLanguage.en),
      ],
      dayBuilder: testDay,
    );
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': 'loc_test',
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(testControllerApp(controller));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.language_outlined), findsNothing);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.byType(LocSelectionScreen), findsOneWidget);
    expect(find.text('BCP Test'), findsOneWidget);

    await tester.tap(find.text('BCP Test'));
    await tester.ensureVisible(find.text('Enter the lectionary'));
    await tester.tap(find.text('Enter the lectionary'));
    await tester.pumpAndSettle();
    expect(controller.selectedPrayerBookCode, 'bcp_test');
    expect(find.textContaining('Tempo de teste'), findsOneWidget);
  });

  testWidgets('opens the prayer book sheet from the home header', (
    tester,
  ) async {
    final source = FakeLectionaryDataSource(
      books: [testBook()],
      dayBuilder: testDay,
    );
    final preferences = await createLocalPreferences({
      'selected_prayer_book_code': 'loc_test',
    });
    final controller = AppController(
      api: source,
      localPreferences: preferences,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final locButton = find.text('LOC Teste');
    expect(locButton, findsOneWidget);
    await tester.tap(locButton);
    await tester.pumpAndSettle();

    expect(find.text('Trocar livro de oração'), findsOneWidget);
  });

  testWidgets('navigates the wide calendar and changes the prayer book', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final first = testBook();
    final second = testBook(
      code: 'bcp_test',
      name: 'BCP Test',
      language: AppLanguage.en,
    );
    final third = testBook(
      code: 'bcp_second',
      name: 'BCP Second',
      language: AppLanguage.en,
    );
    final source = FakeLectionaryDataSource(
      books: [first, second, third],
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

    await tester.pumpWidget(testControllerApp(controller));
    await tester.pumpAndSettle();

    expect(find.text('LEITURAS DE HOJE'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(controller.locale, AppLanguage.en);
    expect(find.byType(LocSelectionScreen), findsOneWidget);
    await tester.tap(find.text('BCP Test'));
    await tester.ensureVisible(find.text('Enter the lectionary'));
    await tester.tap(find.text('Enter the lectionary'));
    await tester.pumpAndSettle();
    expect(find.text("TODAY'S READINGS"), findsOneWidget);

    await tester.tap(find.text('BCP Test'));
    await tester.pumpAndSettle();
    expect(find.text('Change prayer book'), findsOneWidget);
    await tester.tap(find.text('BCP Second').last);
    await tester.pumpAndSettle();
    expect(controller.selectedPrayerBookCode, third.code);
    expect(preferences.selectedPrayerBookCode, third.code);

    expect(
      find.text(AppCopy(AppLanguage.en).monthYear(DateTime.now())),
      findsOneWidget,
    );

    final nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1);
    await tester.tap(find.byKey(const ValueKey('calendar-next-month')));
    await tester.pumpAndSettle();
    expect(
      find.text(AppCopy(AppLanguage.en).monthYear(nextMonth)),
      findsOneWidget,
    );
    expect(
      source.requestedDates,
      contains(DateTime(nextMonth.year, nextMonth.month)),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
    await tester.pumpAndSettle();
    expect(
      find.text(AppCopy(AppLanguage.en).monthYear(DateTime.now())),
      findsOneWidget,
    );

    await tester.tap(find.text('Back to today'));
    await tester.pumpAndSettle();
    expect(source.requestedDates, contains(DateUtils.dateOnly(DateTime.now())));
  });

  testWidgets('does not render invented content when both API calls fail', (
    tester,
  ) async {
    final source = FakeLectionaryDataSource(dayBuilder: testDay)
      ..failDay = true
      ..failCalendarMonth = true;
    final controller = AppController(
      api: source,
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_2015',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tempo de teste'), findsNothing);
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
  });

  testWidgets('shows only the API translation when reading text is absent', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final source = FakeLectionaryDataSource(
      books: [testBook()],
      dayBuilder: (date) => LectionaryDay(
        date: date,
        dayOfWeek: 'Quarta-feira',
        season: 'Tempo de teste',
        color: 'verde',
        readings: const [
          Reading(kind: 'gospel', reference: 'João 1:1–5', translation: 'NAA'),
        ],
      ),
    );
    final controller = AppController(
      api: source,
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final reading = find.text('João 1:1–5');
    await tester.ensureVisible(reading);
    await tester.tap(reading);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A referência está disponível; o texto integral pode ser aberto quando o conteúdo estiver publicado.',
      ),
      findsNothing,
    );
    expect(find.text('NAA'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
  });

  testWidgets(
    'opens nested API reading verses instead of only the translation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final source = FakeLectionaryDataSource(
        books: [testBook()],
        dayBuilder: (date) => LectionaryDay(
          date: date,
          dayOfWeek: 'Quarta-feira',
          season: 'Tempo de teste',
          color: 'verde',
          readings: const [
            Reading(
              kind: 'gospel',
              reference: 'João 1:1–5',
              translation: 'NVI',
              content: ReadingContent(
                reference: 'João 1:1–5',
                translation: 'NVI',
                verses: [
                  ReadingVerse(number: 1, text: 'No princípio era o Verbo.'),
                  ReadingVerse(number: 2, text: 'Ele estava com Deus.'),
                ],
              ),
            ),
          ],
        ),
      );
      final controller = AppController(
        api: source,
        localPreferences: await createLocalPreferences({
          'selected_prayer_book_code': 'loc_test',
        }),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      await tester.pumpWidget(
        testMaterialApp(home: HomeScreen(controller: controller)),
      );
      await tester.pumpAndSettle();
      final reading = find.text('João 1:1–5');
      await tester.ensureVisible(reading);
      await tester.tap(reading);
      await tester.pumpAndSettle();

      expect(find.textContaining('No princípio era o Verbo.'), findsOneWidget);
      expect(find.textContaining('Ele estava com Deus.'), findsOneWidget);
      expect(find.text('NVI'), findsOneWidget);
    },
  );

  testWidgets('fits the phone home on a single screen, without scrolling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = AppController(
      api: FakeLectionaryDataSource(books: [testBook()], dayBuilder: testDay),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollable), findsNothing);
    expect(tester.getRect(find.byType(MonthCalendar)).bottom, lessThan(844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens today from the hero', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = AppController(
      api: FakeLectionaryDataSource(books: [testBook()], dayBuilder: testDay),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Abrir o dia de hoje'), findsOneWidget);
    await tester.tap(find.byType(DailyHero));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('mobile-day-detail-sheet')),
      findsOneWidget,
    );
    expect(find.text('LEITURAS DE HOJE'), findsOneWidget);
    expect(find.text('João 1:1–5'), findsOneWidget);
  });

  testWidgets('names the Sundays in the month grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = AppController(
      api: FakeLectionaryDataSource(
        books: [testBook()],
        dayBuilder: testDay,
        monthBuilder: (month) => List.generate(
          DateUtils.getDaysInMonth(month.year, month.month),
          (index) {
            final date = DateTime(month.year, month.month, index + 1);
            return CalendarDay(
              date: date,
              color: 'verde',
              sundayName: date.weekday == DateTime.sunday
                  ? 'Domingo ${index + 1}'
                  : null,
            );
          },
        ),
      ),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final firstSunday = 1 + (7 - firstOfMonth.weekday % 7) % 7;
    expect(find.text('Domingo $firstSunday'), findsOneWidget);
  });

  testWidgets('copies the readings, the collect and a full reading', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final controller = AppController(
      api: FakeLectionaryDataSource(books: [testBook()], dayBuilder: testDay),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('copy-readings')));
    await tester.pumpAndSettle();
    expect(copied.last, 'Evangelho: João 1:1–5');
    expect(find.text('Texto copiado'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('copy-collect')));
    await tester.pumpAndSettle();
    expect(copied.last, 'Coleta de teste.');

    await tester.tap(find.text('João 1:1–5'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('copy-reading')));
    await tester.pumpAndSettle();
    expect(copied.last, 'Evangelho — João 1:1–5\n\nNo princípio.');
  });
}
