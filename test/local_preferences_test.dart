import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'helpers/test_doubles.dart';

void main() {
  test('defaults to Portuguese without persisted settings', () async {
    final preferences = await createLocalPreferences();

    expect(preferences.selectedPrayerBookCode, isNull);
    expect(preferences.selectedReadingType, isNull);
    expect(preferences.selectedBibleVersionCode, isNull);
    expect(preferences.language, AppLanguage.pt);
  });

  test('persists the selected LOC and language', () async {
    final preferences = await createLocalPreferences();

    await preferences.savePrayerBook('bcp_1979');
    await preferences.saveReadingType('complementary');
    await preferences.saveBibleVersion('nvi');
    await preferences.saveLanguage(AppLanguage.en);

    final restored = await createLocalPreferences({
      'selected_prayer_book_code': 'bcp_1979',
      'selected_reading_type': 'complementary',
      'selected_bible_version_code': 'nvi',
      'app_language': 'en',
    });
    expect(restored.selectedPrayerBookCode, 'bcp_1979');
    expect(restored.selectedReadingType, 'complementary');
    expect(restored.selectedBibleVersionCode, 'nvi');
    expect(restored.language, AppLanguage.en);
  });

  test(
    'keeps the calendar on a Sunday-first week until asked otherwise',
    () async {
      final preferences = await createLocalPreferences();
      expect(preferences.sundayInCenter, isFalse);

      await preferences.saveSundayInCenter(true);
      final restored = await createLocalPreferences({'sunday_in_center': true});
      expect(restored.sundayInCenter, isTrue);
    },
  );

  test('falls back safely when the persisted language is unknown', () async {
    final preferences = await createLocalPreferences({'app_language': 'fr'});

    expect(preferences.language, AppLanguage.pt);
  });
}
