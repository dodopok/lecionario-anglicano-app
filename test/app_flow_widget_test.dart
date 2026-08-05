import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';
import 'package:lecionario_anglicano/presentation/app_shell.dart';
import 'package:lecionario_anglicano/presentation/screens/home_screen.dart';
import 'package:lecionario_anglicano/presentation/screens/loc_selection_screen.dart';

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
    expect(find.text('Tempo de teste'), findsOneWidget);
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

  testWidgets('renders readings, changes to month view and opens a reading', (
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

    expect(find.text('LEITURAS DE HOJE'), findsOneWidget);
    expect(find.text('João 1:1–5'), findsOneWidget);
    expect(find.text('COLETA DO DIA'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Mês'), findsOneWidget);

    await tester.tap(find.text('Mês'));
    await tester.pumpAndSettle();
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

  testWidgets('uses a compact language menu on a narrow home layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
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

    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.language_outlined));
    await tester.pumpAndSettle();
    expect(find.text('EN'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text("TODAY'S READINGS"), findsOneWidget);
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
    final second = testBook(code: 'bcp_test', name: 'BCP Test');
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

    await tester.pumpWidget(
      testMaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('LEITURAS DE HOJE'), findsOneWidget);
    expect(find.text('PT'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(controller.locale, AppLanguage.en);
    expect(find.text("TODAY'S READINGS"), findsOneWidget);

    await tester.tap(find.text('LOC Teste'));
    await tester.pumpAndSettle();
    expect(find.text('Change prayer book'), findsOneWidget);
    await tester.tap(find.text('BCP Test').last);
    await tester.pumpAndSettle();
    expect(controller.selectedPrayerBookCode, second.code);
    expect(preferences.selectedPrayerBookCode, second.code);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(
      find.text(AppCopy(AppLanguage.en).monthYear(DateTime.now())),
      findsOneWidget,
    );

    final nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1);
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(
      find.text(AppCopy(AppLanguage.en).monthYear(nextMonth)),
      findsOneWidget,
    );
    expect(
      source.requestedDates,
      contains(DateTime(nextMonth.year, nextMonth.month)),
    );

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(
      find.text(AppCopy(AppLanguage.en).monthYear(DateTime.now())),
      findsOneWidget,
    );

    await tester.tap(find.text('Back to today'));
    await tester.pumpAndSettle();
    expect(source.requestedDates, contains(DateUtils.dateOnly(DateTime.now())));
  });

  testWidgets('shows the local preview banner when both API calls fail', (
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

    expect(
      find.text(
        'Prévia local · A API está indisponível. Mostrando conteúdo de prévia.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a reading fallback and translation when text is absent', (
    tester,
  ) async {
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
      findsOneWidget,
    );
    expect(find.text('NAA'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
  });
}
