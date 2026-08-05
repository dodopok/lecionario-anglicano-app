import 'package:flutter/foundation.dart';

import '../data/models/lectionary_models.dart';
import '../data/services/lectionary_api.dart';
import '../data/services/local_preferences.dart';

class AppController extends ChangeNotifier {
  AppController({required this.api, required this.localPreferences});

  final LectionaryDataSource api;
  final LocalPreferences localPreferences;

  AppLanguage locale = AppLanguage.pt;
  List<PrayerBook> prayerBooks = const [];
  String? selectedPrayerBookCode;
  LectionaryDay? selectedDay;
  final Map<String, List<CalendarDay>> _monthCache = {};
  bool isInitializing = true;
  bool isLoadingDay = false;
  bool isLoadingMonth = false;
  String? lastError;

  PrayerBook? get selectedPrayerBook {
    for (final book in prayerBooks) {
      if (book.code == selectedPrayerBookCode) return book;
    }
    return null;
  }

  bool get needsPrayerBook => selectedPrayerBookCode == null;

  List<PrayerBook> get booksForCurrentLanguage {
    final matching = prayerBooks
        .where((book) => book.appLanguage == locale)
        .toList();
    return matching.isEmpty ? prayerBooks : matching;
  }

  Future<void> initialize() async {
    locale = localPreferences.language;
    selectedPrayerBookCode = localPreferences.selectedPrayerBookCode;

    try {
      prayerBooks = await api.getPrayerBooks();
      lastError = null;
    } catch (error) {
      lastError = '$error';
      prayerBooks = const [];
    }

    if (selectedPrayerBookCode != null &&
        !prayerBooks.any((book) => book.code == selectedPrayerBookCode)) {
      selectedPrayerBookCode = null;
    }

    isInitializing = false;
    notifyListeners();

    if (!needsPrayerBook) {
      await loadForDate(DateTime.now());
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    locale = language;
    await localPreferences.saveLanguage(language);
    notifyListeners();
  }

  Future<void> choosePrayerBook(PrayerBook book) async {
    selectedPrayerBookCode = book.code;
    await localPreferences.savePrayerBook(book.code);
    _monthCache.clear();
    lastError = null;
    notifyListeners();
    await loadForDate(DateTime.now());
  }

  Future<void> loadForDate(DateTime date) async {
    final code = selectedPrayerBookCode;
    if (code == null) return;

    isLoadingDay = true;
    isLoadingMonth = true;
    notifyListeners();

    final month = DateTime(date.year, date.month);
    await Future.wait([_loadDay(date, code), _loadMonth(month, code)]);

    isLoadingDay = false;
    isLoadingMonth = false;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    await loadForDate(DateTime(date.year, date.month, date.day));
  }

  List<CalendarDay> monthDays(DateTime month) {
    final key = _monthKey(month, selectedPrayerBookCode);
    return _monthCache[key] ?? const [];
  }

  Future<void> _loadDay(DateTime date, String code) async {
    try {
      selectedDay = await api.getDay(date, code);
      lastError = null;
    } catch (error) {
      lastError = '$error';
      selectedDay = null;
    }
  }

  Future<void> _loadMonth(DateTime month, String code) async {
    final key = _monthKey(month, code);
    if (_monthCache.containsKey(key)) return;

    try {
      _monthCache[key] = await api.getCalendarMonth(month, code);
    } catch (error) {
      lastError = '$error';
      _monthCache[key] = const [];
    }
  }

  String _monthKey(DateTime month, String? code) =>
      '${code ?? 'none'}-${month.year}-${month.month}';

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }
}
