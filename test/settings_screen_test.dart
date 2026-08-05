import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/core/app_links.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/screens/settings_screen.dart';

import 'helpers/pump_app.dart';
import 'helpers/test_doubles.dart';

void main() {
  testWidgets('opens privacy and support links from settings', (tester) async {
    final controller = AppController(
      api: FakeLectionaryDataSource(
        books: [testBook()],
        dayBuilder: testDay,
      ),
      localPreferences: await createLocalPreferences({
        'selected_prayer_book_code': 'loc_test',
      }),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    final opened = <Uri>[];
    await tester.pumpWidget(
      testMaterialApp(
        home: SettingsScreen(
          controller: controller,
          openUrl: (uri) async {
            opened.add(uri);
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Informações'), findsOneWidget);
    expect(find.text('Política de privacidade'), findsOneWidget);
    expect(find.text('Suporte'), findsOneWidget);

    await tester.tap(find.text('Política de privacidade'));
    await tester.pump();
    await tester.tap(find.text('Suporte'));
    await tester.pump();

    expect(opened, [AppLinks.privacyPolicy, AppLinks.support]);
  });
}
