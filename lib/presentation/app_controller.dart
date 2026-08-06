import 'package:flutter/foundation.dart';

import '../data/models/lectionary_models.dart';
import '../data/services/lectionary_api.dart';
import '../data/services/load_failure.dart';
import '../data/services/local_preferences.dart';

class AppController extends ChangeNotifier {
  AppController({required this.api, required this.localPreferences});

  final LectionaryDataSource api;
  final LocalPreferences localPreferences;

  AppLanguage locale = AppLanguage.pt;
  List<PrayerBook> prayerBooks = const [];
  List<ReadingTypeOption> readingTypeOptions = const [];
  List<BibleVersion> bibleVersions = const [];
  String? selectedPrayerBookCode;
  String? selectedReadingType;
  String? selectedBibleVersionCode;
  LectionaryDay? selectedDay;
  final Map<String, List<CalendarDay>> _monthCache = {};
  bool sundayInCenter = false;
  bool isInitializing = true;
  bool isLoadingDay = false;
  bool isLoadingMonth = false;
  bool isLoadingPreferences = false;

  /// Why the lectionary on screen is missing, when it is. Preference lookups
  /// are left out of this: they fail quietly and the day still reads.
  LoadFailure? failure;
  DateTime _lastRequestedDate = DateTime.now();

  PrayerBook? get selectedPrayerBook {
    for (final book in prayerBooks) {
      if (book.code == selectedPrayerBookCode) return book;
    }
    return null;
  }

  BibleVersion? get selectedBibleVersion {
    for (final version in bibleVersions) {
      if (version.code == selectedBibleVersionCode) return version;
    }
    return null;
  }

  bool get needsPrayerBook => selectedPrayerBookCode == null;

  List<PrayerBook> get booksForCurrentLanguage {
    return prayerBooks.where((book) => book.appLanguage == locale).toList();
  }

  Future<void> initialize() async {
    locale = localPreferences.language;
    sundayInCenter = localPreferences.sundayInCenter;
    selectedPrayerBookCode = localPreferences.selectedPrayerBookCode;

    await _loadPrayerBooks();

    final restoredBook = selectedPrayerBook;
    if (restoredBook == null || restoredBook.appLanguage != locale) {
      selectedPrayerBookCode = null;
      await localPreferences.clearPrayerBook();
    }

    isInitializing = false;
    notifyListeners();

    final book = selectedPrayerBook;
    if (book != null) {
      await _loadBookPreferences(book);
      await loadForDate(DateTime.now());
    }
  }

  Future<void> _loadPrayerBooks() async {
    try {
      prayerBooks = await api.getPrayerBooks();
      failure = null;
    } catch (error) {
      failure = LoadFailure.from(error);
      prayerBooks = const [];
    }
  }

  /// Asks for the prayer books again, after the first attempt failed.
  Future<void> retryPrayerBooks() async {
    isInitializing = true;
    notifyListeners();
    await _loadPrayerBooks();
    isInitializing = false;
    notifyListeners();

    final book = selectedPrayerBook;
    if (book != null) {
      await _loadBookPreferences(book);
      await loadForDate(_lastRequestedDate);
    }
  }

  /// Asks for the day on screen again, after it failed to arrive.
  Future<void> retryDay() async {
    _monthCache.clear();
    await loadForDate(_lastRequestedDate);
  }

  /// Which weekday the calendar starts on: Sunday first, or Thursday first so
  /// Sunday lands in the middle column.
  int get calendarFirstWeekday =>
      sundayInCenter ? DateTime.thursday : DateTime.sunday;

  Future<void> setSundayInCenter(bool value) async {
    if (sundayInCenter == value) return;
    sundayInCenter = value;
    await localPreferences.saveSundayInCenter(value);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (locale == language) return;

    locale = language;
    await localPreferences.saveLanguage(language);
    _monthCache.clear();
    selectedDay = null;
    readingTypeOptions = const [];
    bibleVersions = const [];
    selectedReadingType = null;
    selectedBibleVersionCode = null;

    final book = selectedPrayerBook;
    if (book == null || book.appLanguage != language) {
      selectedPrayerBookCode = null;
      await localPreferences.clearPrayerBook();
      failure = null;
      isLoadingPreferences = false;
      notifyListeners();
      return;
    }

    notifyListeners();
    await _loadBookPreferences(book);
    await loadForDate(DateTime.now());
  }

  Future<void> choosePrayerBook(PrayerBook book) async {
    selectedPrayerBookCode = book.code;
    selectedDay = null;
    _monthCache.clear();
    failure = null;
    readingTypeOptions = book.readingTypes;
    bibleVersions = const [];
    selectedReadingType = null;
    selectedBibleVersionCode = null;
    await localPreferences.savePrayerBook(book.code);
    notifyListeners();
    await _loadBookPreferences(book);
    await loadForDate(DateTime.now());
  }

  Future<void> setReadingType(String value, DateTime date) async {
    if (!readingTypeOptions.any((option) => option.value == value)) return;
    if (selectedReadingType == value) return;

    selectedReadingType = value;
    await localPreferences.saveReadingType(value);
    _monthCache.clear();
    notifyListeners();
    await loadForDate(date);
  }

  Future<void> chooseBibleVersion(BibleVersion version, DateTime date) async {
    if (!bibleVersions.any((item) => item.code == version.code)) return;
    if (selectedBibleVersionCode == version.code) return;

    selectedBibleVersionCode = version.code;
    await localPreferences.saveBibleVersion(version.code);
    _monthCache.clear();
    notifyListeners();
    await loadForDate(date);
  }

  Future<void> loadForDate(DateTime date) async {
    final code = selectedPrayerBookCode;
    if (code == null) return;

    _lastRequestedDate = date;
    isLoadingDay = true;
    isLoadingMonth = true;
    failure = null;
    notifyListeners();

    final month = DateTime(date.year, date.month);
    final readingType = selectedReadingType;
    final bibleVersion = selectedBibleVersionCode;
    await Future.wait([
      _loadDay(date, code, readingType, bibleVersion),
      _loadMonth(month, code, readingType, bibleVersion),
    ]);

    isLoadingDay = false;
    isLoadingMonth = false;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    await loadForDate(DateTime(date.year, date.month, date.day));
  }

  Future<({LectionaryDay? day, LoadFailure? failure})> fetchDayForDate(
    DateTime date,
  ) async {
    final code = selectedPrayerBookCode;
    if (code == null) return (day: null, failure: null);

    try {
      final day = await api.getDay(
        DateTime(date.year, date.month, date.day),
        code,
        readingType: selectedReadingType,
        bibleVersion: selectedBibleVersionCode,
      );
      return (day: day, failure: null);
    } catch (error) {
      return (day: null, failure: LoadFailure.from(error));
    }
  }

  Future<void> loadMonth(DateTime month) async {
    final code = selectedPrayerBookCode;
    if (code == null) return;

    final normalizedMonth = DateTime(month.year, month.month);
    final key = _monthKey(
      normalizedMonth,
      code,
      selectedReadingType,
      selectedBibleVersionCode,
    );
    if (_monthCache.containsKey(key)) return;

    isLoadingMonth = true;
    notifyListeners();
    await _loadMonth(
      normalizedMonth,
      code,
      selectedReadingType,
      selectedBibleVersionCode,
    );
    isLoadingMonth = false;
    notifyListeners();
  }

  /// The failure when it left nothing at all to read, as opposed to one that
  /// only cost part of what is on screen.
  LoadFailure? get strandedBy {
    if (failure == null || isLoadingDay) return null;
    if (selectedDay != null) return null;
    if (_monthCache.values.any((days) => days.isNotEmpty)) return null;
    return failure;
  }

  List<CalendarDay> monthDays(DateTime month) {
    final key = _monthKey(
      month,
      selectedPrayerBookCode,
      selectedReadingType,
      selectedBibleVersionCode,
    );
    return _monthCache[key] ?? const [];
  }

  Future<void> _loadBookPreferences(PrayerBook book) async {
    isLoadingPreferences = true;
    readingTypeOptions = book.readingTypes;
    selectedReadingType = _resolveReadingType(book, readingTypeOptions);
    selectedBibleVersionCode = null;
    notifyListeners();

    await Future.wait<void>([
      () async {
        try {
          final options = await api.getReadingTypeOptions(book.code);
          if (options.isNotEmpty) readingTypeOptions = options;
        } catch (_) {
          // A missing preference list does not stop the day from reading.
        }
      }(),
      () async {
        try {
          bibleVersions = await api.getBibleVersions(language: book.language);
        } catch (_) {
          bibleVersions = const [];
        }
      }(),
    ]);

    selectedReadingType = _resolveReadingType(book, readingTypeOptions);
    selectedBibleVersionCode = _resolveBibleVersion();
    isLoadingPreferences = false;
    notifyListeners();
  }

  String? _resolveReadingType(
    PrayerBook book,
    List<ReadingTypeOption> options,
  ) {
    final values = options.map((option) => option.value).toSet();
    final stored = localPreferences.selectedReadingType;
    if (stored != null && values.contains(stored)) return stored;

    if (book.defaultReadingType != null &&
        values.contains(book.defaultReadingType)) {
      return book.defaultReadingType;
    }

    for (final option in options) {
      if (option.isDefault) return option.value;
    }

    return options.length == 1 ? options.single.value : null;
  }

  String? _resolveBibleVersion() {
    final stored = localPreferences.selectedBibleVersionCode?.toLowerCase();
    if (stored != null &&
        bibleVersions.any((version) => version.code == stored)) {
      return stored;
    }

    for (final version in bibleVersions) {
      if (version.recommended) return version.code;
    }
    return bibleVersions.firstOrNull?.code;
  }

  Future<void> _loadDay(
    DateTime date,
    String code,
    String? readingType,
    String? bibleVersion,
  ) async {
    try {
      selectedDay = await api.getDay(
        date,
        code,
        readingType: readingType,
        bibleVersion: bibleVersion,
      );
    } catch (error) {
      failure = LoadFailure.from(error);
      selectedDay = null;
    }
  }

  Future<void> _loadMonth(
    DateTime month,
    String code,
    String? readingType,
    String? bibleVersion,
  ) async {
    final key = _monthKey(month, code, readingType, bibleVersion);
    if (_monthCache.containsKey(key)) return;

    try {
      _monthCache[key] = await api.getCalendarMonth(
        month,
        code,
        readingType: readingType,
        bibleVersion: bibleVersion,
      );
    } catch (error) {
      failure = LoadFailure.from(error);
      _monthCache[key] = const [];
    }
  }

  String _monthKey(
    DateTime month,
    String? code,
    String? readingType,
    String? bibleVersion,
  ) =>
      '${code ?? 'none'}-${month.year}-${month.month}-${readingType ?? 'none'}-${bibleVersion ?? 'none'}';

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
