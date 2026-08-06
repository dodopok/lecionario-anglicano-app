import 'package:shared_preferences/shared_preferences.dart';

import '../models/lectionary_models.dart';

class LocalPreferences {
  const LocalPreferences(this._preferences);

  final SharedPreferences _preferences;

  String? get selectedPrayerBookCode =>
      _preferences.getString('selected_prayer_book_code');

  String? get selectedReadingType =>
      _preferences.getString('selected_reading_type');

  String? get selectedBibleVersionCode =>
      _preferences.getString('selected_bible_version_code');

  /// Whether the calendar puts Sunday in the middle of the week, so the days
  /// that look back and forward to it sit on either side.
  bool get sundayInCenter => _preferences.getBool('sunday_in_center') ?? false;

  AppLanguage get language {
    final code = _preferences.getString('app_language');
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.pt,
    );
  }

  Future<void> savePrayerBook(String code) async {
    await _preferences.setString('selected_prayer_book_code', code);
  }

  Future<void> clearPrayerBook() async {
    await _preferences.remove('selected_prayer_book_code');
  }

  Future<void> saveReadingType(String value) async {
    await _preferences.setString('selected_reading_type', value);
  }

  Future<void> saveBibleVersion(String code) async {
    await _preferences.setString('selected_bible_version_code', code);
  }

  Future<void> saveSundayInCenter(bool value) async {
    await _preferences.setBool('sunday_in_center', value);
  }

  Future<void> saveLanguage(AppLanguage language) async {
    await _preferences.setString('app_language', language.code);
  }
}
