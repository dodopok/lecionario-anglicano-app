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
  String get readings => switch (language) {
    AppLanguage.pt => 'Leituras de hoje',
    AppLanguage.en => "Today's readings",
    AppLanguage.es => 'Lecturas de hoy',
  };
  String get readingsForDay => switch (language) {
    AppLanguage.pt => 'Leituras do dia',
    AppLanguage.en => "Day's readings",
    AppLanguage.es => 'Lecturas del día',
  };
  String get liturgicalExplanationAction => switch (language) {
    AppLanguage.pt => 'Entenda este dia',
    AppLanguage.en => 'Understand this day',
    AppLanguage.es => 'Comprende este día',
  };
  String get liturgicalExplanationTitle => switch (language) {
    AppLanguage.pt => 'Entenda este dia',
    AppLanguage.en => 'Understand this day',
    AppLanguage.es => 'Comprende este día',
  };
  String get liturgicalExplanationError => switch (language) {
    AppLanguage.pt => 'Não foi possível carregar a explicação deste dia.',
    AppLanguage.en => "We couldn't load the explanation for this day.",
    AppLanguage.es => 'No se pudo cargar la explicación de este día.',
  };
  String get liturgicalExplanationLoading => switch (language) {
    AppLanguage.pt => 'Carregando explicação litúrgica',
    AppLanguage.en => 'Loading liturgical explanation',
    AppLanguage.es => 'Cargando explicación litúrgica',
  };
  String get liturgicalExplanationCalendarSection => switch (language) {
    AppLanguage.pt => 'O tempo litúrgico',
    AppLanguage.en => 'The liturgical season',
    AppLanguage.es => 'El tiempo litúrgico',
  };
  String get liturgicalExplanationCelebrationSection => switch (language) {
    AppLanguage.pt => 'A celebração do dia',
    AppLanguage.en => 'The celebration of the day',
    AppLanguage.es => 'La celebración del día',
  };
  String get liturgicalExplanationColorSection => switch (language) {
    AppLanguage.pt => 'A cor litúrgica',
    AppLanguage.en => 'The liturgical color',
    AppLanguage.es => 'El color litúrgico',
  };
  String get liturgicalExplanationColorMeaning => switch (language) {
    AppLanguage.pt => 'Significado da cor',
    AppLanguage.en => 'Meaning of the color',
    AppLanguage.es => 'Significado del color',
  };
  String get liturgicalExplanationTransfersSection => switch (language) {
    AppLanguage.pt => 'Transferências',
    AppLanguage.en => 'Transfers',
    AppLanguage.es => 'Traslados',
  };
  String get liturgicalExplanationReadingsSection => switch (language) {
    AppLanguage.pt => 'As leituras',
    AppLanguage.en => 'The readings',
    AppLanguage.es => 'Las lecturas',
  };
  String get liturgicalExplanationSeason => switch (language) {
    AppLanguage.pt => 'Tempo',
    AppLanguage.en => 'Season',
    AppLanguage.es => 'Tiempo',
  };
  String get liturgicalExplanationCycle => switch (language) {
    AppLanguage.pt => 'Ciclo',
    AppLanguage.en => 'Cycle',
    AppLanguage.es => 'Ciclo',
  };
  String get liturgicalExplanationWeek => switch (language) {
    AppLanguage.pt => 'Semana',
    AppLanguage.en => 'Week',
    AppLanguage.es => 'Semana',
  };
  String get liturgicalExplanationProper => switch (language) {
    AppLanguage.pt => 'Próprio',
    AppLanguage.en => 'Proper',
    AppLanguage.es => 'Propio',
  };
  String get liturgicalExplanationSeasonProgress => switch (language) {
    AppLanguage.pt => 'Progresso do tempo litúrgico',
    AppLanguage.en => 'Liturgical season progress',
    AppLanguage.es => 'Progreso del tiempo litúrgico',
  };
  String liturgicalExplanationCandidates(int count) => switch (language) {
    AppLanguage.pt => '$count possibilidades consideradas',
    AppLanguage.en => '$count possibilities considered',
    AppLanguage.es => '$count posibilidades consideradas',
  };
  String get liturgicalExplanationSelected => switch (language) {
    AppLanguage.pt => 'Celebração escolhida para o dia',
    AppLanguage.en => 'Celebration selected for the day',
    AppLanguage.es => 'Celebración elegida para el día',
  };
  String get liturgicalExplanationSource => switch (language) {
    AppLanguage.pt => 'Origem',
    AppLanguage.en => 'Source',
    AppLanguage.es => 'Origen',
  };
  String get liturgicalExplanationNoTransfers => switch (language) {
    AppLanguage.pt => 'Nenhuma celebração foi transferida nesta data.',
    AppLanguage.en => 'No celebration was transferred on this date.',
    AppLanguage.es => 'Ninguna celebración fue trasladada en esta fecha.',
  };
  String get liturgicalExplanationFrom => switch (language) {
    AppLanguage.pt => 'De',
    AppLanguage.en => 'From',
    AppLanguage.es => 'De',
  };
  String get liturgicalExplanationTo => switch (language) {
    AppLanguage.pt => 'Para',
    AppLanguage.en => 'To',
    AppLanguage.es => 'A',
  };
  String get liturgicalExplanationHowReadingsChosen => switch (language) {
    AppLanguage.pt => 'Como estas leituras foram escolhidas?',
    AppLanguage.en => 'How were these readings chosen?',
    AppLanguage.es => '¿Cómo se eligieron estas lecturas?',
  };
  String get liturgicalExplanationTrack => switch (language) {
    AppLanguage.pt => 'Trilha',
    AppLanguage.en => 'Track',
    AppLanguage.es => 'Pista',
  };
  String get liturgicalExplanationFallback => switch (language) {
    AppLanguage.pt => 'Alternativa',
    AppLanguage.en => 'Fallback',
    AppLanguage.es => 'Alternativa de respaldo',
  };
  String get liturgicalExplanationServiceType => switch (language) {
    AppLanguage.pt => 'Serviço',
    AppLanguage.en => 'Service',
    AppLanguage.es => 'Servicio',
  };
  String get liturgicalExplanationAlternatives => switch (language) {
    AppLanguage.pt => 'Leituras alternativas',
    AppLanguage.en => 'Alternative readings',
    AppLanguage.es => 'Lecturas alternativas',
  };
  String get liturgicalExplanationPartialTitle => switch (language) {
    AppLanguage.pt => 'Explicação parcial',
    AppLanguage.en => 'Partial explanation',
    AppLanguage.es => 'Explicación parcial',
  };
  String get liturgicalExplanationPartialMessage => switch (language) {
    AppLanguage.pt =>
      'Alguns dados não estão disponíveis para este livro de oração. '
          'As lacunas não foram preenchidas automaticamente.',
    AppLanguage.en =>
      'Some data is unavailable for this prayer book. Missing information '
          'has not been filled in automatically.',
    AppLanguage.es =>
      'Algunos datos no están disponibles para este libro de oración. La '
          'información ausente no se completó automáticamente.',
  };
  String get liturgicalExplanationMissing => switch (language) {
    AppLanguage.pt => 'Indisponível',
    AppLanguage.en => 'Unavailable',
    AppLanguage.es => 'No disponible',
  };
  String get liturgicalExplanationNoReadings => switch (language) {
    AppLanguage.pt => 'Não há leituras disponíveis para explicar nesta data.',
    AppLanguage.en =>
      'There are no readings available to explain on this date.',
    AppLanguage.es =>
      'No hay lecturas disponibles para explicar en esta fecha.',
  };
  String get collect => switch (language) {
    AppLanguage.pt => 'Coleta do dia',
    AppLanguage.en => 'Collect of the day',
    AppLanguage.es => 'Colecta del día',
  };
  String get collects => switch (language) {
    AppLanguage.pt => 'Coletas do dia',
    AppLanguage.en => 'Collects of the day',
    AppLanguage.es => 'Colectas del día',
  };
  String get openTodayReadings => switch (language) {
    AppLanguage.pt => 'Abrir o dia de hoje',
    AppLanguage.en => 'Open today',
    AppLanguage.es => 'Abrir el día de hoy',
  };
  String get copyAction => switch (language) {
    AppLanguage.pt => 'Copiar',
    AppLanguage.en => 'Copy',
    AppLanguage.es => 'Copiar',
  };
  String get copied => switch (language) {
    AppLanguage.pt => 'Copiado',
    AppLanguage.en => 'Copied',
    AppLanguage.es => 'Copiado',
  };
  String get chooseLoc => switch (language) {
    AppLanguage.pt => 'Escolher LOC',
    AppLanguage.en => 'Choose prayer book',
    AppLanguage.es => 'Elegir LOC',
  };
  String get recommended => switch (language) {
    AppLanguage.pt => 'RECOMENDADO',
    AppLanguage.en => 'RECOMMENDED',
    AppLanguage.es => 'RECOMENDADO',
  };
  String get changeLoc => switch (language) {
    AppLanguage.pt => 'Trocar livro de oração',
    AppLanguage.en => 'Change prayer book',
    AppLanguage.es => 'Cambiar libro de oración',
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
  String get offlineTitle => switch (language) {
    AppLanguage.pt => 'Sem conexão',
    AppLanguage.en => 'No connection',
    AppLanguage.es => 'Sin conexión',
  };
  String get offlineBody => switch (language) {
    AppLanguage.pt =>
      'O lecionário é carregado da internet e não foi possível alcançá-lo. '
          'Verifique a sua conexão.',
    AppLanguage.en =>
      'The lectionary is loaded from the internet and could not be reached. '
          'Check your connection.',
    AppLanguage.es =>
      'El leccionario se carga de internet y no fue posible alcanzarlo. '
          'Revisa tu conexión.',
  };
  String get serverErrorTitle => switch (language) {
    AppLanguage.pt => 'O lecionário não respondeu',
    AppLanguage.en => 'The lectionary did not answer',
    AppLanguage.es => 'El leccionario no respondió',
  };
  String get serverErrorBody => switch (language) {
    AppLanguage.pt =>
      'A consulta chegou, mas voltou sem os dados do dia. Tente de novo em '
          'instantes.',
    AppLanguage.en =>
      'The request arrived but came back without the day. Try again in a '
          'moment.',
    AppLanguage.es =>
      'La consulta llegó, pero volvió sin los datos del día. Inténtalo de '
          'nuevo en un momento.',
  };
  String get retry => switch (language) {
    AppLanguage.pt => 'Tentar de novo',
    AppLanguage.en => 'Try again',
    AppLanguage.es => 'Intentar de nuevo',
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
  String get readingTrack => switch (language) {
    AppLanguage.pt => 'Sequência das leituras',
    AppLanguage.en => 'Reading track',
    AppLanguage.es => 'Secuencia de lecturas',
  };
  String get sundayInCenter => switch (language) {
    AppLanguage.pt => 'Domingo no centro',
    AppLanguage.en => 'Sunday in the middle',
    AppLanguage.es => 'Domingo en el centro',
  };
  String get sundayInCenterHint => switch (language) {
    AppLanguage.pt =>
      'A semana começa na quinta-feira, com o domingo ao centro: à esquerda os '
          'dias que preparam para ele, à direita os que o refletem.',
    AppLanguage.en =>
      'The week starts on Thursday with Sunday in the middle: the days that '
          'prepare for it on the left, the days that reflect on it on the right.',
    AppLanguage.es =>
      'La semana empieza el jueves, con el domingo al centro: a la izquierda '
          'los días que preparan para él, a la derecha los que lo reflejan.',
  };
  String get bibleVersion => switch (language) {
    AppLanguage.pt => 'Versão da Bíblia',
    AppLanguage.en => 'Bible version',
    AppLanguage.es => 'Versión de la Biblia',
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
  String get languageLabel => switch (language) {
    AppLanguage.pt => 'Idioma',
    AppLanguage.en => 'Language',
    AppLanguage.es => 'Idioma',
  };
  String get languageSubtitle => switch (language) {
    AppLanguage.pt => 'Interface, LOCs e Bíblias disponíveis',
    AppLanguage.en => 'Interface, prayer books, and available Bibles',
    AppLanguage.es => 'Interfaz, LOCs y Biblias disponibles',
  };
  String get noPrayerBooksForLanguage => switch (language) {
    AppLanguage.pt => 'Nenhum LOC disponível neste idioma.',
    AppLanguage.en => 'No prayer book is available in this language.',
    AppLanguage.es => 'No hay ningún LOC disponible en este idioma.',
  };
  String get information => switch (language) {
    AppLanguage.pt => 'Informações',
    AppLanguage.en => 'Information',
    AppLanguage.es => 'Información',
  };
  String get informationSubtitle => switch (language) {
    AppLanguage.pt => 'Ajuda e privacidade',
    AppLanguage.en => 'Help and privacy',
    AppLanguage.es => 'Ayuda y privacidad',
  };
  String get privacyPolicy => switch (language) {
    AppLanguage.pt => 'Política de privacidade',
    AppLanguage.en => 'Privacy policy',
    AppLanguage.es => 'Política de privacidad',
  };
  String get support => switch (language) {
    AppLanguage.pt => 'Suporte',
    AppLanguage.en => 'Support',
    AppLanguage.es => 'Soporte',
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
