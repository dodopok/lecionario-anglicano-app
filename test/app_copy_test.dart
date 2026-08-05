import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';

void main() {
  setUpAll(initializeDateFormatting);

  final date = DateTime(2026, 8, 5);

  test('formats dates for Portuguese, English and Spanish', () {
    expect(AppCopy(AppLanguage.pt).dateLong(date), 'Quarta-feira, 5 de agosto');
    expect(AppCopy(AppLanguage.en).dateLong(date), 'Wednesday, August 5');
    expect(AppCopy(AppLanguage.es).dateLong(date), 'Miércoles, 5 de agosto');
  });

  test('translates reading labels and liturgical colors', () {
    final english = AppCopy(AppLanguage.en);
    final portuguese = AppCopy(AppLanguage.pt);

    expect(portuguese.readingLabel('first_reading'), 'Primeira leitura');
    expect(portuguese.readingLabel('gospel'), 'Evangelho');
    expect(english.readingLabel('psalm'), 'Psalm');
    expect(english.colorLabel('vermelho'), 'Red');
    expect(portuguese.colorLabel('purple'), 'Roxo');
  });

  test('maps arbitrary locale codes to supported languages', () {
    expect(AppLanguageX.fromLocale(const Locale('en', 'GB')), AppLanguage.en);
    expect(AppLanguageX.fromLocale(const Locale('fr')), AppLanguage.pt);
    expect(AppLanguage.es.locale.languageCode, 'es');
  });
}
