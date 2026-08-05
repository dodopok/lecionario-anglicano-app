import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'helpers/test_doubles.dart';

void main() {
  test('defaults to Portuguese without persisted settings', () async {
    final preferences = await createLocalPreferences();

    expect(preferences.selectedPrayerBookCode, isNull);
    expect(preferences.language, AppLanguage.pt);
  });

  test('persists the selected LOC and language', () async {
    final preferences = await createLocalPreferences();

    await preferences.savePrayerBook('bcp_1979');
    await preferences.saveLanguage(AppLanguage.en);

    final restored = await createLocalPreferences({
      'selected_prayer_book_code': 'bcp_1979',
      'app_language': 'en',
    });
    expect(restored.selectedPrayerBookCode, 'bcp_1979');
    expect(restored.language, AppLanguage.en);
  });

  test('falls back safely when the persisted language is unknown', () async {
    final preferences = await createLocalPreferences({'app_language': 'fr'});

    expect(preferences.language, AppLanguage.pt);
  });
}
