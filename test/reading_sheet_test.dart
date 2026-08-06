import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';
import 'package:lecionario_anglicano/presentation/widgets/reading_sheet.dart';

import 'helpers/pump_app.dart';

void main() {
  const copy = AppCopy(AppLanguage.pt);
  const withVerses = Reading(
    kind: 'gospel',
    reference: 'João 1:1–2',
    translation: 'NVI',
    content: ReadingContent(
      reference: 'João 1:1–2',
      translation: 'NVI',
      verses: [
        ReadingVerse(number: 1, text: 'No princípio era o Verbo.'),
        ReadingVerse(number: 2, text: 'Ele estava com Deus.'),
      ],
    ),
  );

  Future<void> pumpSheet(WidgetTester tester, Reading reading) async {
    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ReadingSheet(reading: reading, copy: copy),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the reading the API published', (tester) async {
    await pumpSheet(tester, withVerses);

    expect(find.text('Evangelho'), findsOneWidget);
    expect(find.text('João 1:1–2'), findsOneWidget);
    expect(find.textContaining('No princípio era o Verbo.'), findsOneWidget);
    expect(find.textContaining('Ele estava com Deus.'), findsOneWidget);
    expect(find.text('NVI'), findsOneWidget);
  });

  testWidgets('renders only what the API sent', (tester) async {
    await pumpSheet(
      tester,
      const Reading(kind: 'psalm', reference: 'Salmo 99'),
    );

    expect(find.text('Salmo'), findsOneWidget);
    expect(find.text('Salmo 99'), findsOneWidget);
    expect(find.byKey(const ValueKey('copy-reading')), findsOneWidget);
  });

  testWidgets('closes on the close action', (tester) async {
    await pumpSheet(tester, withVerses);
    expect(find.byKey(const ValueKey('reading-sheet')), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reading-sheet')), findsNothing);
  });

  testWidgets('copies the reading with its reference and verses', (
    tester,
  ) async {
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

    await pumpSheet(tester, withVerses);
    await tester.tap(find.byKey(const ValueKey('copy-reading')));
    await tester.pumpAndSettle();

    expect(copied.single, '''
Evangelho — João 1:1–2

1 No princípio era o Verbo.
2 Ele estava com Deus.

NVI''');
    expect(find.text('Texto copiado'), findsOneWidget);
  });

  test('keeps the copied text to what the API published', () {
    expect(
      readingAsText(
        const Reading(kind: 'psalm', reference: 'Salmo 99'),
        copy,
      ),
      'Salmo — Salmo 99',
    );
    expect(
      readingAsText(
        const Reading(
          kind: 'first_reading',
          reference: 'Êxodo 34:29',
          text: 'Desceu Moisés do monte Sinai.',
        ),
        copy,
      ),
      'Primeira leitura — Êxodo 34:29\n\nDesceu Moisés do monte Sinai.',
    );
  });
}
