import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';
import 'package:lecionario_anglicano/presentation/widgets/day_detail_sheet.dart';

import 'helpers/pump_app.dart';
import 'helpers/test_doubles.dart';

void main() {
  testWidgets('places the explanation action in the day detail sheet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var opened = false;
    final controller = AppController(
      api: FakeLectionaryDataSource(),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => DayDetailSheet(
                  controller: controller,
                  date: DateTime(2026, 8, 5),
                  copy: const AppCopy(AppLanguage.pt),
                  onOpenReading: (_) {},
                  onOpenExplanation: () => opened = true,
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final action = find.byKey(const ValueKey('mobile-day-detail-explanation'));
    await tester.ensureVisible(action);
    expect(action, findsOneWidget);
    await tester.tap(action);
    expect(opened, isTrue);
  });
}
