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

  testWidgets('closes when the reading itself is dragged down', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSheet(tester, withVerses);
    expect(find.byKey(const ValueKey('reading-sheet')), findsOneWidget);

    // From inside the scripture, not from the handle at the top.
    await tester.drag(
      find.textContaining('No princípio era o Verbo.'),
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reading-sheet')), findsNothing);
  });

  testWidgets('closes on the close action', (tester) async {
    await pumpSheet(tester, withVerses);
    expect(find.byKey(const ValueKey('reading-sheet')), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reading-sheet')), findsNothing);
  });

  testWidgets('confirms the copy on the button, where the finger is', (
    tester,
  ) async {
    await pumpSheet(tester, withVerses);

    String tooltip() => tester
        .widget<IconButton>(
          find.descendant(
            of: find.byKey(const ValueKey('copy-reading')),
            matching: find.byType(IconButton),
          ),
        )
        .tooltip!;

    expect(tooltip(), 'Copiar');
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.tap(find.byKey(const ValueKey('copy-reading')));
    await tester.pumpAndSettle();
    expect(tooltip(), 'Copiado');
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(tooltip(), 'Copiar');
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('keeps the copy action within reach at the top', (tester) async {
    await pumpSheet(tester, withVerses);

    final sheet = tester.getRect(find.byKey(const ValueKey('reading-sheet')));
    final button = tester.getRect(find.byKey(const ValueKey('copy-reading')));

    expect(button.top - sheet.top, lessThan(sheet.height / 3));
    expect(button.right, closeTo(sheet.right, 20));
  });

  testWidgets('tags the reading with the Bible version, next to the '
      'reference', (tester) async {
    await pumpSheet(tester, withVerses);

    final tag = find.byKey(const ValueKey('reading-translation'));
    expect(tag, findsOneWidget);
    expect(
      find.descendant(of: tag, matching: find.text('NVI')),
      findsOneWidget,
    );

    final reference = tester.getRect(find.text('João 1:1–2'));
    expect(tester.getRect(tag).left, greaterThan(reference.left));
    expect(tester.getRect(tag).center.dy, closeTo(reference.center.dy, 6));
  });

  testWidgets('leaves the tag out when the API sends no version', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      const Reading(kind: 'psalm', reference: 'Salmo 99'),
    );

    expect(find.byKey(const ValueKey('reading-translation')), findsNothing);
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
2 Ele estava com Deus.''');
    expect(copied.single, isNot(contains('NVI')));
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
