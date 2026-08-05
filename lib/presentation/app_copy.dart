import 'package:intl/intl.dart';

import '../data/models/lectionary_models.dart';

class AppCopy {
  const AppCopy(this.language);

  final AppLanguage language;

  String get brand => switch (language) {
    AppLanguage.pt => 'Lecionário',
    AppLanguage.en => 'Lectionary',
    AppLanguage.es => 'Leccionario',
  };
  String get brandSubline => switch (language) {
    AppLanguage.pt => 'ANGLICANO',
    AppLanguage.en => 'ANGLICAN',
    AppLanguage.es => 'ANGLICANO',
  };
  String get chooseEyebrow => switch (language) {
    AppLanguage.pt => 'PRIMEIRO PASSO',
    AppLanguage.en => 'FIRST STEP',
    AppLanguage.es => 'PRIMER PASO',
  };
  String get chooseTitle => switch (language) {
    AppLanguage.pt => 'Escolha o seu\nLivro de Oração',
    AppLanguage.en => 'Choose your\nPrayer Book',
    AppLanguage.es => 'Elige tu\nLibro de Oración',
  };
  String get chooseSubtitle => switch (language) {
    AppLanguage.pt =>
      'A liturgia que acompanha seu dia. Você pode trocar de LOC a qualquer momento.',
    AppLanguage.en =>
      'The liturgy that accompanies your day. You can change your prayer book at any time.',
    AppLanguage.es =>
      'La liturgia que acompaña tu día. Puedes cambiar de LOC en cualquier momento.',
  };
  String get continueLabel => switch (language) {
    AppLanguage.pt => 'Entrar no lecionário',
    AppLanguage.en => 'Enter the lectionary',
    AppLanguage.es => 'Entrar al leccionario',
  };
  String get today => switch (language) {
    AppLanguage.pt => 'Hoje',
    AppLanguage.en => 'Today',
    AppLanguage.es => 'Hoy',
  };
  String get week => switch (language) {
    AppLanguage.pt => 'Semana',
    AppLanguage.en => 'Week',
    AppLanguage.es => 'Semana',
  };
  String get month => switch (language) {
    AppLanguage.pt => 'Mês',
    AppLanguage.en => 'Month',
    AppLanguage.es => 'Mes',
  };
  String get readings => switch (language) {
    AppLanguage.pt => 'Leituras de hoje',
    AppLanguage.en => "Today's readings",
    AppLanguage.es => 'Lecturas de hoy',
  };
  String get collect => switch (language) {
    AppLanguage.pt => 'Coleta do dia',
    AppLanguage.en => 'Collect of the day',
    AppLanguage.es => 'Colecta del día',
  };
  String get lectionary => switch (language) {
    AppLanguage.pt => 'LECIONÁRIO DO DIA',
    AppLanguage.en => 'DAILY LECTIONARY',
    AppLanguage.es => 'LECCIONARIO DEL DÍA',
  };
  String get chooseLoc => switch (language) {
    AppLanguage.pt => 'Escolher LOC',
    AppLanguage.en => 'Choose prayer book',
    AppLanguage.es => 'Elegir LOC',
  };
  String get changeLoc => switch (language) {
    AppLanguage.pt => 'Trocar livro de oração',
    AppLanguage.en => 'Change prayer book',
    AppLanguage.es => 'Cambiar libro de oración',
  };
  String get liturgicalColor => switch (language) {
    AppLanguage.pt => 'COR LITÚRGICA',
    AppLanguage.en => 'LITURGICAL COLOR',
    AppLanguage.es => 'COLOR LITÚRGICO',
  };
  String get selected => switch (language) {
    AppLanguage.pt => 'SELECIONADO',
    AppLanguage.en => 'SELECTED',
    AppLanguage.es => 'SELECCIONADO',
  };
  String get backToToday => switch (language) {
    AppLanguage.pt => 'Voltar para hoje',
    AppLanguage.en => 'Back to today',
    AppLanguage.es => 'Volver a hoy',
  };
  String get close => switch (language) {
    AppLanguage.pt => 'Fechar',
    AppLanguage.en => 'Close',
    AppLanguage.es => 'Cerrar',
  };
  String get yearLabel => switch (language) {
    AppLanguage.pt => 'Ano',
    AppLanguage.en => 'Year',
    AppLanguage.es => 'Año',
  };
  String get readingOpening => switch (language) {
    AppLanguage.pt => 'Abrir leitura',
    AppLanguage.en => 'Open reading',
    AppLanguage.es => 'Abrir lectura',
  };
  String get readingTrack => switch (language) {
    AppLanguage.pt => 'Sequência das leituras',
    AppLanguage.en => 'Reading track',
    AppLanguage.es => 'Secuencia de lecturas',
  };
  String get bibleVersion => switch (language) {
    AppLanguage.pt => 'Versão da Bíblia',
    AppLanguage.en => 'Bible version',
    AppLanguage.es => 'Versión de la Biblia',
  };
  String get chooseBible => switch (language) {
    AppLanguage.pt => 'Escolher Bíblia',
    AppLanguage.en => 'Choose Bible',
    AppLanguage.es => 'Elegir Biblia',
  };
  String get settings => switch (language) {
    AppLanguage.pt => 'Configurações',
    AppLanguage.en => 'Settings',
    AppLanguage.es => 'Configuración',
  };
  String get settingsSubtitle => switch (language) {
    AppLanguage.pt => 'Preferências do lecionário',
    AppLanguage.en => 'Lectionary preferences',
    AppLanguage.es => 'Preferencias del leccionario',
  };
  String get preferences => switch (language) {
    AppLanguage.pt => 'Preferências',
    AppLanguage.en => 'Preferences',
    AppLanguage.es => 'Preferencias',
  };
  String dateLong(DateTime date) {
    final locale = language.locale.toLanguageTag();
    final format = switch (language) {
      AppLanguage.pt => DateFormat("EEEE, d 'de' MMMM", locale),
      AppLanguage.en => DateFormat('EEEE, MMMM d', locale),
      AppLanguage.es => DateFormat("EEEE, d 'de' MMMM", locale),
    };
    return _capitalize(format.format(date));
  }

  String monthYear(DateTime date) {
    final value = DateFormat(
      'MMMM yyyy',
      language.locale.toLanguageTag(),
    ).format(date);
    return _capitalize(value);
  }

  String weekdayShort(DateTime date) {
    return DateFormat(
      'EEE',
      language.locale.toLanguageTag(),
    ).format(date).toUpperCase();
  }

  String dayOfWeek(DateTime date) {
    return _capitalize(
      DateFormat('EEEE', language.locale.toLanguageTag()).format(date),
    );
  }

  String readingLabel(String kind) {
    final normalized = kind.toLowerCase();
    if (normalized.contains('first') || normalized.contains('primeira')) {
      return switch (language) {
        AppLanguage.pt => 'Primeira leitura',
        AppLanguage.en => 'First reading',
        AppLanguage.es => 'Primera lectura',
      };
    }
    if (normalized.contains('second') || normalized.contains('segunda')) {
      return switch (language) {
        AppLanguage.pt => 'Segunda leitura',
        AppLanguage.en => 'Second reading',
        AppLanguage.es => 'Segunda lectura',
      };
    }
    if (normalized.contains('gospel') || normalized.contains('evangel')) {
      return switch (language) {
        AppLanguage.pt => 'Evangelho',
        AppLanguage.en => 'Gospel',
        AppLanguage.es => 'Evangelio',
      };
    }
    if (normalized.contains('psalm') || normalized.contains('salmo')) {
      return switch (language) {
        AppLanguage.pt => 'Salmo',
        AppLanguage.en => 'Psalm',
        AppLanguage.es => 'Salmo',
      };
    }
    return kind;
  }

  String colorLabel(String color) {
    final normalized = color.toLowerCase();
    if (normalized.contains('branco') || normalized == 'white') {
      return switch (language) {
        AppLanguage.pt => 'Branco',
        AppLanguage.en => 'White',
        AppLanguage.es => 'Blanco',
      };
    }
    if (normalized.contains('vermelho') || normalized == 'red') {
      return switch (language) {
        AppLanguage.pt => 'Vermelho',
        AppLanguage.en => 'Red',
        AppLanguage.es => 'Rojo',
      };
    }
    if (normalized.contains('roxo') ||
        normalized.contains('violet') ||
        normalized == 'purple') {
      return switch (language) {
        AppLanguage.pt => 'Roxo',
        AppLanguage.en => 'Purple',
        AppLanguage.es => 'Morado',
      };
    }
    if (normalized.contains('rosa') || normalized == 'rose') {
      return switch (language) {
        AppLanguage.pt => 'Rosa',
        AppLanguage.en => 'Rose',
        AppLanguage.es => 'Rosa',
      };
    }
    if (normalized.contains('verde') || normalized == 'green') {
      return switch (language) {
        AppLanguage.pt => 'Verde',
        AppLanguage.en => 'Green',
        AppLanguage.es => 'Verde',
      };
    }
    if (normalized.contains('azul') || normalized == 'blue') {
      return switch (language) {
        AppLanguage.pt => 'Azul',
        AppLanguage.en => 'Blue',
        AppLanguage.es => 'Azul',
      };
    }
    if (normalized.contains('preto') || normalized == 'black') {
      return switch (language) {
        AppLanguage.pt => 'Preto',
        AppLanguage.en => 'Black',
        AppLanguage.es => 'Negro',
      };
    }
    return color;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
