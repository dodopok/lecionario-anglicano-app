import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lecionario_anglicano/core/theme/app_colors.dart';
import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';
import 'package:lecionario_anglicano/presentation/widgets/home_sections.dart';

import 'helpers/pump_app.dart';

void main() {
  setUpAll(initializeDateFormatting);

  const copy = AppCopy(AppLanguage.pt);
  final today = DateUtils.dateOnly(DateTime.now());

  LectionaryDay day({
    String? season = 'Tempo Comum',
    String? celebration,
    String? sundayName,
    String? weekName,
    String? color = 'verde',
    String? liturgicalYear = 'C',
    List<String>? description,
  }) {
    return LectionaryDay(
      date: today,
      dayOfWeek: null,
      season: season,
      color: color,
      liturgicalYear: liturgicalYear,
      weekName: weekName,
      sundayName: sundayName,
      description: description,
      celebration: celebration == null ? null : Celebration(name: celebration),
    );
  }

  Future<void> pumpHero(
    WidgetTester tester, {
    LectionaryDay? value,
    DateTime? date,
    bool isLoading = false,
    VoidCallback? onToday,
    VoidCallback? onTap,
    String? actionLabel,
  }) async {
    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: DailyHero(
            day: value,
            activeDate: date ?? today,
            copy: copy,
            isLoading: isLoading,
            onToday: onToday,
            onTap: onTap,
            actionLabel: actionLabel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DailyHero', () {
    testWidgets('leads with the celebration and moves the season to the '
        'eyebrow', (tester) async {
      await pumpHero(
        tester,
        value: day(celebration: 'Osvaldo, Rei e Mártir', weekName: 'Proper 13'),
      );

      expect(find.text('Osvaldo, Rei e Mártir'), findsOneWidget);
      expect(find.text('HOJE · Tempo Comum'), findsOneWidget);
      expect(find.text('Ano C · Verde'), findsOneWidget);
      expect(find.text(copy.dateLong(today)), findsOneWidget);
    });

    testWidgets('falls back through Sunday name, week name and season', (
      tester,
    ) async {
      await pumpHero(
        tester,
        value: day(sundayName: '8º Domingo', weekName: 'Proper 13'),
      );
      expect(find.text('8º Domingo'), findsOneWidget);

      await pumpHero(tester, value: day(weekName: 'Proper 13'));
      expect(find.text('Proper 13'), findsOneWidget);

      await pumpHero(tester, value: day(season: 'Advento'));
      expect(find.text('Advento'), findsOneWidget);
    });

    testWidgets('omits metadata the API did not send', (tester) async {
      await pumpHero(
        tester,
        value: day(celebration: 'Festa', color: null, liturgicalYear: null),
      );

      expect(find.text('Ano C · Verde'), findsNothing);
      expect(find.text('HOJE · Tempo Comum'), findsOneWidget);
    });

    testWidgets('shows neither the day nor the season while it loads', (
      tester,
    ) async {
      await pumpHero(
        tester,
        value: day(celebration: 'Osvaldo, Rei e Mártir'),
        isLoading: true,
      );

      expect(find.text('Osvaldo, Rei e Mártir'), findsNothing);
      expect(find.text('HOJE · Tempo Comum'), findsNothing);
      expect(find.text('HOJE'), findsOneWidget);
    });

    testWidgets('offers the way back only when another day is shown', (
      tester,
    ) async {
      var returned = 0;
      await pumpHero(tester, value: day(), onToday: () => returned++);
      expect(find.text('Voltar para hoje'), findsNothing);

      await pumpHero(
        tester,
        value: day(),
        date: today.subtract(const Duration(days: 3)),
        onToday: () => returned++,
      );
      expect(find.text('SELECIONADO · Tempo Comum'), findsOneWidget);

      await tester.tap(find.text('Voltar para hoje'));
      expect(returned, 1);
    });

    testWidgets('only invites a tap when there is somewhere to go', (
      tester,
    ) async {
      await pumpHero(tester, value: day());
      expect(find.text('Abrir o dia de hoje'), findsNothing);

      var opened = 0;
      await pumpHero(
        tester,
        value: day(),
        onTap: () => opened++,
        actionLabel: copy.openTodayReadings,
      );
      expect(find.text('Abrir o dia de hoje'), findsOneWidget);

      await tester.tap(find.byType(DailyHero));
      expect(opened, 1);
    });

    testWidgets('keeps its height whether or not the API sends a long day', (
      tester,
    ) async {
      await pumpHero(tester, value: day(celebration: 'Festa'));
      final short = tester.getSize(find.byType(DailyHero)).height;

      await pumpHero(
        tester,
        value: day(
          celebration:
              'Comemoração de todos os fiéis defuntos, com um nome bem longo '
              'que ocupa mais de uma linha',
        ),
      );
      expect(tester.getSize(find.byType(DailyHero)).height, short);
    });
  });

  group('MonthCalendar', () {
    final month = DateTime(2026, 8);
    final selected = DateTime(2026, 8, 5);

    List<CalendarDay> monthDays() => [
      CalendarDay(
        date: DateTime(2026, 8, 2),
        color: 'verde',
        sundayName: '8º Domingo depois de Pentecostes',
        weekName: 'Semana da Proper 13',
      ),
      CalendarDay(
        date: DateTime(2026, 8, 5),
        color: 'branco',
        celebrationName: 'Osvaldo, Rei e Mártir',
        weekName: 'Semana da Proper 13',
      ),
      CalendarDay(
        date: DateTime(2026, 8, 6),
        color: 'branco',
        weekName: 'Semana da Proper 13',
      ),
    ];

    Future<void> pumpCalendar(
      WidgetTester tester, {
      Size size = const Size(390, 700),
      ValueChanged<DateTime>? onSelect,
      VoidCallback? onPrevious,
      VoidCallback? onNext,
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        testMaterialApp(
          home: Scaffold(
            body: MonthCalendar(
              month: month,
              selectedDate: selected,
              copy: copy,
              monthDays: monthDays(),
              onSelect: onSelect ?? (_) {},
              onPrevious: onPrevious ?? () {},
              onNext: onNext ?? () {},
              fillHeight: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('names the Sundays and leaves the weekdays to their number', (
      tester,
    ) async {
      await pumpCalendar(tester);

      expect(find.text('Agosto 2026'), findsOneWidget);
      expect(find.text('8º Domingo depois de Pentecostes'), findsOneWidget);
      expect(find.text('Semana da Proper 13'), findsNothing);
      expect(find.text('Osvaldo, Rei e Mártir'), findsNothing);
    });

    testWidgets('marks a weekday feast with a dot instead of a name', (
      tester,
    ) async {
      await pumpCalendar(tester);

      expect(find.byKey(const ValueKey('celebration-2026-8-5')), findsOneWidget);
      expect(find.byKey(const ValueKey('celebration-2026-8-6')), findsNothing);
    });

    testWidgets('renders every day of the month exactly once', (tester) async {
      await pumpCalendar(tester);

      for (final dayNumber in [1, 15, 31]) {
        expect(
          find.byKey(ValueKey('month-day-2026-8-$dayNumber')),
          findsOneWidget,
        );
      }
      expect(find.byKey(const ValueKey('month-day-2026-9-1')), findsNothing);
    });

    testWidgets('paints the selected day so its number stays legible', (
      tester,
    ) async {
      await pumpCalendar(tester);

      Material cellSurface(String key) => tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(Material),
            )
            .first,
      );

      expect(cellSurface('month-day-2026-8-5').color, AppColors.pine);
      expect(cellSurface('month-day-2026-8-12').color, isNot(AppColors.pine));
    });

    testWidgets('reports the tapped day and the month arrows', (tester) async {
      final tapped = <DateTime>[];
      var previous = 0;
      var next = 0;
      await pumpCalendar(
        tester,
        onSelect: tapped.add,
        onPrevious: () => previous++,
        onNext: () => next++,
      );

      await tester.tap(find.byKey(const ValueKey('month-day-2026-8-12')));
      expect(tapped, [DateTime(2026, 8, 12)]);

      await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
      await tester.tap(find.byKey(const ValueKey('calendar-next-month')));
      expect([previous, next], [1, 1]);
    });

    testWidgets('degrades to bare dates on a short screen without overflowing', (
      tester,
    ) async {
      await pumpCalendar(tester, size: const Size(640, 340));

      expect(tester.takeException(), isNull);
      expect(find.text('8º Domingo depois de Pentecostes'), findsNothing);
      expect(find.byKey(const ValueKey('month-day-2026-8-31')), findsOneWidget);
    });
  });

  group('day content', () {
    testWidgets('lists the readings the API sent, in order', (tester) async {
      final opened = <Reading>[];
      await tester.pumpWidget(
        testMaterialApp(
          home: Scaffold(
            body: ReadingsCard(
              day: LectionaryDay(
                date: today,
                dayOfWeek: null,
                season: null,
                color: null,
                readings: const [
                  Reading(kind: 'first_reading', reference: 'Êxodo 34:29–35'),
                  Reading(kind: 'psalm', reference: 'Salmo 99'),
                  Reading(kind: 'gospel', reference: ''),
                ],
              ),
              copy: copy,
              onOpen: opened.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEITURAS DE HOJE'), findsOneWidget);
      expect(find.text('Primeira leitura'), findsOneWidget);
      expect(find.text('Salmo 99'), findsOneWidget);
      expect(find.text('Evangelho'), findsNothing);

      await tester.tap(find.text('Êxodo 34:29–35'));
      expect(opened.single.reference, 'Êxodo 34:29–35');
    });

    testWidgets('says nothing when the API sent no collect', (tester) async {
      await tester.pumpWidget(
        testMaterialApp(
          home: Scaffold(body: CollectCard(day: day(), copy: copy)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('COLETA DO DIA'), findsNothing);
    });

    testWidgets('shows the day note only when there is one', (tester) async {
      await tester.pumpWidget(
        testMaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DayDescription(day: day(description: const ['Rei mártir.'])),
                DayDescription(day: day()),
                const DayDescription(day: null),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rei mártir.'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });

  test('copies the readings as their labels and references', () {
    expect(
      readingsAsText(const [
        Reading(kind: 'first_reading', reference: 'Êxodo 34:29–35'),
        Reading(kind: 'gospel', reference: 'Mateus 13:44–52'),
      ], copy),
      'Primeira leitura: Êxodo 34:29–35\nEvangelho: Mateus 13:44–52',
    );
  });
}
