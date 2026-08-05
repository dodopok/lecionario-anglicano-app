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
    expect(AppLanguageX.fromLocale(const Locale('es', 'MX')), AppLanguage.es);
    expect(AppLanguageX.fromLocale(const Locale('fr')), AppLanguage.pt);
    expect(AppLanguage.pt.code, 'pt');
    expect(AppLanguage.en.shortLabel, 'EN');
    expect(AppLanguage.es.locale.languageCode, 'es');
  });

  test('covers the complete copy surface in every supported language', () {
    final portuguese = AppCopy(AppLanguage.pt);
    final english = AppCopy(AppLanguage.en);
    final spanish = AppCopy(AppLanguage.es);

    expect(portuguese.brand, 'Lecionário');
    expect(portuguese.brandSubline, 'ANGLICANO');
    expect(portuguese.chooseEyebrow, 'PRIMEIRO PASSO');
    expect(portuguese.chooseSubtitle, contains('Você pode trocar'));
    expect(portuguese.continueLabel, 'Entrar no lecionário');
    expect(portuguese.today, 'Hoje');
    expect(portuguese.week, 'Semana');
    expect(portuguese.month, 'Mês');
    expect(portuguese.readings, 'Leituras de hoje');
    expect(portuguese.collect, 'Coleta do dia');
    expect(portuguese.lectionary, 'LECIONÁRIO DO DIA');
    expect(portuguese.chooseLoc, 'Escolher LOC');
    expect(portuguese.changeLoc, 'Trocar livro de oração');
    expect(portuguese.liturgicalColor, 'COR LITÚRGICA');
    expect(portuguese.selected, 'SELECIONADO');
    expect(portuguese.backToToday, 'Voltar para hoje');
    expect(portuguese.close, 'Fechar');
    expect(portuguese.yearLabel, 'Ano');
    expect(portuguese.readingOpening, 'Abrir leitura');
    expect(portuguese.readingTrack, 'Sequência das leituras');
    expect(portuguese.bibleVersion, 'Versão da Bíblia');
    expect(portuguese.chooseBible, 'Escolher Bíblia');

    expect(english.brandSubline, 'ANGLICAN');
    expect(english.chooseEyebrow, 'FIRST STEP');
    expect(english.chooseTitle, 'Choose your\nPrayer Book');
    expect(english.chooseSubtitle, contains('change your prayer book'));
    expect(english.continueLabel, 'Enter the lectionary');
    expect(english.today, 'Today');
    expect(english.week, 'Week');
    expect(english.month, 'Month');
    expect(english.readings, "Today's readings");
    expect(english.collect, 'Collect of the day');
    expect(english.lectionary, 'DAILY LECTIONARY');
    expect(english.chooseLoc, 'Choose prayer book');
    expect(english.changeLoc, 'Change prayer book');
    expect(english.liturgicalColor, 'LITURGICAL COLOR');
    expect(english.selected, 'SELECTED');
    expect(english.backToToday, 'Back to today');
    expect(english.close, 'Close');
    expect(english.yearLabel, 'Year');
    expect(english.readingOpening, 'Open reading');
    expect(english.readingTrack, 'Reading track');
    expect(english.bibleVersion, 'Bible version');
    expect(english.chooseBible, 'Choose Bible');

    expect(spanish.brandSubline, 'ANGLICANO');
    expect(spanish.chooseEyebrow, 'PRIMER PASO');
    expect(spanish.chooseTitle, 'Elige tu\nLibro de Oración');
    expect(spanish.continueLabel, 'Entrar al leccionario');
    expect(spanish.today, 'Hoy');
    expect(spanish.week, 'Semana');
    expect(spanish.month, 'Mes');
    expect(spanish.readings, 'Lecturas de hoy');
    expect(spanish.collect, 'Colecta del día');
    expect(spanish.lectionary, 'LECCIONARIO DEL DÍA');
    expect(spanish.chooseLoc, 'Elegir LOC');
    expect(spanish.changeLoc, 'Cambiar libro de oración');
    expect(spanish.liturgicalColor, 'COLOR LITÚRGICO');
    expect(spanish.selected, 'SELECCIONADO');
    expect(spanish.backToToday, 'Volver a hoy');
    expect(spanish.close, 'Cerrar');
    expect(spanish.yearLabel, 'Año');
    expect(spanish.readingOpening, 'Abrir lectura');
    expect(spanish.readingTrack, 'Secuencia de lecturas');
    expect(spanish.bibleVersion, 'Versión de la Biblia');
    expect(spanish.chooseBible, 'Elegir Biblia');
  });

  test('formats month, weekday and reading metadata per language', () {
    final date = DateTime(2026, 8, 5);

    for (final copy in [
      AppCopy(AppLanguage.pt),
      AppCopy(AppLanguage.en),
      AppCopy(AppLanguage.es),
    ]) {
      expect(copy.monthYear(date), contains('2026'));
      expect(copy.weekdayShort(date), isNotEmpty);
      expect(copy.dayOfWeek(date), isNotEmpty);
      expect(copy.readingLabel('first_reading'), isNotEmpty);
      expect(copy.readingLabel('second_reading'), isNotEmpty);
      expect(copy.readingLabel('gospel'), isNotEmpty);
      expect(copy.readingLabel('psalm'), isNotEmpty);
      expect(copy.colorLabel('branco'), isNotEmpty);
      expect(copy.colorLabel('red'), isNotEmpty);
      expect(copy.colorLabel('purple'), isNotEmpty);
      expect(copy.colorLabel('rose'), isNotEmpty);
      expect(copy.colorLabel('unknown'), isNotEmpty);
    }
  });
}
