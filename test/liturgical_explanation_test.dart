import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/liturgical_explanation.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/screens/liturgical_explanation_screen.dart';

import 'helpers/pump_app.dart';
import 'helpers/test_doubles.dart';

void main() {
  test('parses the localized liturgical explanation contract', () {
    final explanation = LiturgicalExplanation.fromApiJson({
      'data': {
        'date': '2026-05-24',
        'prayer_book_code': 'loc_2015',
        'locale': 'pt-BR',
        'presentation': {'title': 'Pentecostes', 'summary': 'Tempo de Páscoa.'},
        'calendar': {
          'season': 'Páscoa',
          'season_range': {
            'start_date': '2026-04-05',
            'end_date': '2026-05-24',
            'days_remaining': 0,
            'presentation': {'title': 'A estação termina hoje.', 'summary': ''},
          },
          'cycle': 'A',
          'week': 8,
        },
        'celebration': {
          'selected': null,
          'candidates': [],
          'reason': {'code': '', 'message': ''},
          'presentation': {'title': '', 'summary': ''},
        },
        'color': {
          'value': 'vermelho',
          'source': 'celebration',
          'source_label': 'Celebração',
          'reason': {'code': 'celebration', 'message': 'Prevalece.'},
          'presentation': {'title': 'Vermelho', 'summary': ''},
        },
        'transfers': [],
        'reading_guide': {
          'cycle': {
            'code': 'A',
            'presentation': {'title': 'Ano A', 'summary': ''},
          },
          'method': {
            'code': 'celebration',
            'presentation': {'title': 'Celebração', 'summary': ''},
          },
        },
        'readings': [],
        'partial': {'partial': false, 'missing': []},
      },
      'meta': {'request_id': 'req-1', 'contract_version': 1},
    });

    expect(explanation.date, DateTime(2026, 5, 24));
    expect(explanation.presentation.title, 'Pentecostes');
    expect(explanation.calendar.seasonRange.daysRemaining, 0);
    expect(explanation.color.sourceLabel, 'Celebração');
    expect(explanation.completeness.isPartial, isFalse);
  });

  testWidgets('renders the explanation sections in the app visual language', (
    tester,
  ) async {
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      testMaterialApp(
        home: LiturgicalExplanationScreen(
          controller: controller,
          date: DateTime(2026, 5, 24),
          loader: (_) async => _explanation,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entenda este dia'), findsOneWidget);
    expect(find.text('Pentecostes'), findsWidgets);
    expect(find.text('O tempo litúrgico'), findsOneWidget);
    expect(find.text('A celebração do dia'), findsOneWidget);
    expect(find.text('A cor litúrgica'), findsOneWidget);
    expect(find.text('Transferências'), findsOneWidget);
    expect(find.text('As leituras'), findsOneWidget);
    expect(
      find.text('O vermelho representa o fogo do Espírito.'),
      findsOneWidget,
    );
    expect(find.text('Atos 2:1-21'), findsOneWidget);

    final candidates = find.text('2 possibilidades consideradas');
    await tester.drag(
      find.byKey(const ValueKey('liturgical-explanation-content')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    await tester.tap(candidates);
    await tester.pumpAndSettle();

    expect(find.text('Outra celebração'), findsOneWidget);
    expect(find.text('A festa principal tem precedência.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offers retry when the explanation cannot be loaded', (
    tester,
  ) async {
    var attempts = 0;
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      testMaterialApp(
        home: LiturgicalExplanationScreen(
          controller: controller,
          date: DateTime(2026, 5, 24),
          loader: (_) async {
            attempts++;
            if (attempts == 1) throw StateError('network');
            return _explanation;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar a explicação deste dia.'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('liturgical-explanation-retry')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pentecostes'), findsWidgets);
    expect(attempts, 2);
  });
}

final _explanation = LiturgicalExplanation(
  date: DateTime(2026, 5, 24),
  prayerBookCode: 'loc_2015',
  locale: 'pt-BR',
  presentation: ExplanationPresentation(
    title: 'Pentecostes',
    summary: 'Estamos no tempo de Páscoa, no ciclo A.',
  ),
  calendar: LiturgicalCalendarExplanation(
    season: 'Páscoa',
    seasonRange: LiturgicalSeasonRange(
      startDate: DateTime(2026, 4, 5),
      endDate: DateTime(2026, 5, 24),
      daysRemaining: 0,
      presentation: ExplanationPresentation(
        title: 'Páscoa começou em 05/04/2026.',
        summary: 'A estação termina hoje.',
      ),
    ),
    cycle: 'A',
    week: 8,
  ),
  celebration: LiturgicalCelebrationExplanation(
    selected: LiturgicalCelebrationSelection(
      key: 'pentecost',
      name: 'Pentecostes',
      type: 'principal_feast',
      typeLabel: 'Festa principal',
      date: DateTime(2026, 5, 24),
    ),
    candidates: [
      LiturgicalCelebrationCandidate(
        key: 'pentecost',
        name: 'Pentecostes',
        type: 'principal_feast',
        typeLabel: 'Festa principal',
        date: DateTime(2026, 5, 24),
        selected: true,
      ),
      LiturgicalCelebrationCandidate(
        key: 'other',
        name: 'Outra celebração',
        type: 'lesser_feast',
        typeLabel: 'Festa menor',
        date: DateTime(2026, 5, 24),
        selected: false,
        discardedReason: ExplanationReason(
          code: 'principal_feast',
          message: 'A festa principal tem precedência.',
        ),
      ),
    ],
    reason: ExplanationReason(
      code: 'principal_feast',
      message: 'Esta é a celebração designada para a data.',
    ),
    presentation: ExplanationPresentation(
      title: 'Hoje celebramos Pentecostes',
      summary: 'Esta é a celebração designada para a data.',
    ),
  ),
  color: LiturgicalColorExplanation(
    value: 'vermelho',
    source: 'celebration',
    sourceLabel: 'Celebração',
    reason: ExplanationReason(
      code: 'celebration',
      message: 'A celebração prevalece sobre a estação.',
    ),
    meaning: ExplanationReason(
      code: 'pentecost_red',
      message: 'O vermelho representa o fogo do Espírito.',
    ),
    presentation: ExplanationPresentation(
      title: 'A cor litúrgica de hoje é vermelho',
      summary: 'A celebração prevalece sobre a estação.',
    ),
  ),
  transfers: [
    LiturgicalTransferExplanation(
      from: '2026-05-23',
      to: '2026-05-24',
      reason: ExplanationReason(
        code: 'calendar_conflict',
        message: 'Houve conflito no calendário.',
      ),
      presentation: ExplanationPresentation(
        title: 'Celebração transferida',
        summary: 'A celebração foi movida para esta data.',
      ),
    ),
  ],
  readingGuide: LiturgicalReadingGuide(
    cycle: LiturgicalReadingGuideItem(
      code: 'A',
      presentation: ExplanationPresentation(
        title: 'Ano A do ciclo dominical',
        summary: 'Rotação dominical de três anos.',
      ),
    ),
    track: LiturgicalReadingGuideItem(
      code: 'semicontinuous',
      presentation: ExplanationPresentation(
        title: 'Trilha semicontínua',
        summary: 'Uma sequência de textos bíblicos.',
      ),
    ),
    method: LiturgicalReadingGuideItem(
      code: 'principal_feast',
      source: 'celebration',
      sourceLabel: 'Celebração',
      presentation: ExplanationPresentation(
        title: 'Leituras da celebração principal',
        summary: 'A celebração determina estas leituras.',
      ),
    ),
  ),
  readings: [
    LiturgicalReadingExplanation(
      slot: 'first_reading',
      reference: 'Atos 2:1-21',
      alternatives: ['Números 11:24-30'],
      source: 'celebration',
      sourceLabel: 'Celebração',
      track: 'semicontinuous',
      trackLabel: 'Semicontínua',
      cycle: 'A',
      cycleLabel: 'Ano A',
      serviceType: 'eucharist',
      serviceTypeLabel: 'Eucaristia',
      reason: ExplanationReason(
        code: 'principal_feast',
        message: 'As leituras próprias têm precedência.',
      ),
      presentation: ExplanationPresentation(
        title: 'Primeira leitura',
        summary: 'Atos 2:1-21.',
      ),
    ),
  ],
  completeness: LiturgicalExplanationCompleteness(
    isPartial: false,
    missing: [],
  ),
  requestId: 'request-id',
  contractVersion: 1,
);
