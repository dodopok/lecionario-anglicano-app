import 'package:shared_preferences/shared_preferences.dart';

import '../models/lectionary_models.dart';

class LocalPreferences {
  const LocalPreferences(this._preferences);

  final SharedPreferences _preferences;

  String? get selectedPrayerBookCode =>
      _preferences.getString('selected_prayer_book_code');

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

  Future<void> saveLanguage(AppLanguage language) async {
    await _preferences.setString('app_language', language.code);
  }
}
