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

  test('declares the initial localized locales', () {
    expect(AppLanguage.pt.locale.toLanguageTag(), 'pt-BR');
    expect(AppLanguage.en.locale.toLanguageTag(), 'en-US');
    expect(AppLanguage.es.locale.toLanguageTag(), 'es');
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
    expect(portuguese.openTodayReadings, 'Abrir o dia de hoje');
    expect(portuguese.copyAction, 'Copiar');
    expect(portuguese.copiedToClipboard, 'Texto copiado');
    expect(portuguese.readings, 'Leituras de hoje');
    expect(portuguese.readingsForDay, 'Leituras do dia');
    expect(portuguese.collect, 'Coleta do dia');
    expect(portuguese.chooseLoc, 'Escolher LOC');
    expect(portuguese.recommended, 'RECOMENDADO');
    expect(portuguese.changeLoc, 'Trocar livro de oração');
    expect(portuguese.selected, 'SELECIONADO');
    expect(portuguese.backToToday, 'Voltar para hoje');
    expect(portuguese.close, 'Fechar');
    expect(portuguese.yearLabel, 'Ano');
    expect(portuguese.readingTrack, 'Sequência das leituras');
    expect(portuguese.bibleVersion, 'Versão da Bíblia');
    expect(portuguese.settings, 'Configurações');
    expect(portuguese.settingsSubtitle, 'Preferências do lecionário');
    expect(portuguese.information, 'Informações');
    expect(portuguese.informationSubtitle, 'Ajuda e privacidade');
    expect(portuguese.privacyPolicy, 'Política de privacidade');
    expect(portuguese.support, 'Suporte');
    expect(portuguese.languageLabel, 'Idioma');
    expect(
      portuguese.languageSubtitle,
      'Interface, LOCs e Bíblias disponíveis',
    );
    expect(portuguese.preferences, 'Preferências');

    expect(english.brand, 'Lectionary');
    expect(english.brandSubline, 'ANGLICAN');
    expect(english.chooseEyebrow, 'FIRST STEP');
    expect(english.chooseTitle, 'Choose your\nPrayer Book');
    expect(english.chooseSubtitle, contains('change your prayer book'));
    expect(english.continueLabel, 'Enter the lectionary');
    expect(english.today, 'Today');
    expect(english.openTodayReadings, 'Open today');
    expect(english.copyAction, 'Copy');
    expect(english.copiedToClipboard, 'Text copied');
    expect(english.readings, "Today's readings");
    expect(english.readingsForDay, "Day's readings");
    expect(english.collect, 'Collect of the day');
    expect(english.chooseLoc, 'Choose prayer book');
    expect(english.recommended, 'RECOMMENDED');
    expect(english.changeLoc, 'Change prayer book');
    expect(english.selected, 'SELECTED');
    expect(english.backToToday, 'Back to today');
    expect(english.close, 'Close');
    expect(english.yearLabel, 'Year');
    expect(english.readingTrack, 'Reading track');
    expect(english.bibleVersion, 'Bible version');
    expect(english.settings, 'Settings');
    expect(english.settingsSubtitle, 'Lectionary preferences');
    expect(english.information, 'Information');
    expect(english.informationSubtitle, 'Help and privacy');
    expect(english.privacyPolicy, 'Privacy policy');
    expect(english.support, 'Support');
    expect(english.languageLabel, 'Language');
    expect(
      english.languageSubtitle,
      'Interface, prayer books, and available Bibles',
    );
    expect(english.preferences, 'Preferences');

    expect(spanish.brand, 'Leccionario');
    expect(spanish.brandSubline, 'ANGLICANO');
    expect(spanish.chooseEyebrow, 'PRIMER PASO');
    expect(spanish.chooseTitle, 'Elige tu\nLibro de Oración');
    expect(spanish.continueLabel, 'Entrar al leccionario');
    expect(spanish.today, 'Hoy');
    expect(spanish.openTodayReadings, 'Abrir el día de hoy');
    expect(spanish.copyAction, 'Copiar');
    expect(spanish.copiedToClipboard, 'Texto copiado');
    expect(spanish.readings, 'Lecturas de hoy');
    expect(spanish.readingsForDay, 'Lecturas del día');
    expect(spanish.collect, 'Colecta del día');
    expect(spanish.chooseLoc, 'Elegir LOC');
    expect(spanish.recommended, 'RECOMENDADO');
    expect(spanish.changeLoc, 'Cambiar libro de oración');
    expect(spanish.selected, 'SELECCIONADO');
    expect(spanish.backToToday, 'Volver a hoy');
    expect(spanish.close, 'Cerrar');
    expect(spanish.yearLabel, 'Año');
    expect(spanish.readingTrack, 'Secuencia de lecturas');
    expect(spanish.bibleVersion, 'Versión de la Biblia');
    expect(spanish.settings, 'Configuración');
    expect(spanish.settingsSubtitle, 'Preferencias del leccionario');
    expect(spanish.information, 'Información');
    expect(spanish.informationSubtitle, 'Ayuda y privacidad');
    expect(spanish.privacyPolicy, 'Política de privacidad');
    expect(spanish.support, 'Soporte');
    expect(spanish.languageLabel, 'Idioma');
    expect(spanish.languageSubtitle, 'Interfaz, LOCs y Biblias disponibles');
    expect(spanish.preferences, 'Preferencias');
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
