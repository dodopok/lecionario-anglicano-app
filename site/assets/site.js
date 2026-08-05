(() => {
  const config = window.LECCIONARIO_SITE_CONFIG || {};
  const dictionaries = {
    pt: {
      language: 'pt-BR',
      shortLanguage: 'PT',
      languageLabel: 'Idioma',
      brand: 'Lecionário',
      brandAria: 'Lecionário Anglicano',
      brandSubline: 'ANGLICANO',
      navHow: 'Como funciona',
      navSupport: 'Suporte',
      navPrivacy: 'Privacidade',
      heroEyebrow: 'LECIONÁRIO ANGLICANO · IOS',
      heroTitleLead: 'O dia ganha',
      heroTitleAccent: 'um ritmo.',
      heroDescription: 'Uma forma serena de consultar o lecionário: comece pelo dia, percorra a semana ou abra o mês inteiro.',
      heroPrimary: 'Conheça o app',
      heroSecondary: 'Precisa de ajuda?',
      heroMeta: 'PT-BR · EN-US · ES',
      screenLabel: 'Visão do dia',
      screenCaption: 'Conteúdo carregado da fonte do lecionário',
      screenAlt: 'Tela do Lecionário Anglicano mostrando a visão semanal em português.',
      heroStamp: 'LEITURA\nDIÁRIA',
      sectionEyebrow: 'UM LIVRO ABERTO',
      sectionTitle: 'Feito para consultar, não para distrair.',
      sectionIntro: 'A experiência começa com uma escolha simples e deixa o conteúdo ocupar o lugar principal.',
      feature1Title: 'Escolha o seu LOC',
      feature1Text: 'Na primeira abertura, veja os livros disponíveis, suas capas e as informações retornadas pela API.',
      feature1Tag: 'Primeiro passo',
      feature2Title: 'Comece pelo dia',
      feature2Text: 'A tela principal coloca o dia atual no centro e deixa a semana e o mês a um toque.',
      feature2Tag: 'Hoje · Semana · Mês',
      feature3Title: 'Ajuste no seu tempo',
      feature3Text: 'Quando disponíveis, o tipo de leitura e a versão da Bíblia ficam salvos em Configurações.',
      feature3Tag: 'Preferências',
      sourceEyebrow: 'CONTEÚDO DA FONTE',
      sourceTitle: 'A API traz o que o dia tem para dizer.',
      sourceText: 'O app não substitui leituras, celebrações ou coletas por textos de demonstração. O que aparece depende do LOC, da data e dos dados fornecidos pelo serviço.',
      languageEyebrow: 'TRÊS IDIOMAS PARA COMEÇAR',
      languageTitle: 'A mesma cadência, três vozes.',
      languageText: 'A interface acompanha você em português do Brasil, inglês e espanhol.',
      ctaEyebrow: 'LECIONÁRIO ANGLICANO',
      ctaTitle: 'Abra o dia com presença.',
      ctaText: 'Conheça o app, escolha seu LOC e encontre a leitura que já estava esperando por você.',
      ctaLink: 'Ir para o suporte',
      footerTag: 'Um ritmo de leitura para cada dia.',
      footerRights: '© {year} Caminho Anglicano',
      supportEyebrow: 'CENTRAL DE AJUDA',
      supportTitle: 'Ajuda sem ruído.',
      supportIntro: 'Respostas rápidas para começar a usar o Lecionário Anglicano com tranquilidade.',
      supportContactTitle: 'Fale com a equipe',
      supportContactText: 'Se a resposta não estiver aqui, envie uma mensagem para o canal de suporte.',
      supportEmailLabel: 'Enviar e-mail',
      faqEyebrow: 'PERGUNTAS FREQUENTES',
      faqTitle: 'O essencial, sem rodeios.',
      faqIntro: 'O app foi desenhado para ser simples desde a primeira abertura.',
      faq1Q: 'Preciso criar uma conta?',
      faq1A: 'Não. O app não exige cadastro nem login. Na primeira abertura, escolha um LOC para entrar no lecionário.',
      faq2Q: 'Como escolho outro LOC?',
      faq2A: 'Na tela principal, toque no nome do LOC no cabeçalho e escolha outra opção. As capas e informações exibidas vêm da API.',
      faq3Q: 'Onde ficam o tipo de leitura e a Bíblia?',
      faq3A: 'Abra Configurações pelo ícone de ajustes no cabeçalho. Essas opções aparecem quando o LOC e a fonte as disponibilizam.',
      faq4Q: 'Por que uma leitura pode não aparecer?',
      faq4A: 'O conteúdo depende do LOC, da data e dos dados retornados pelo serviço. Verifique a conexão e tente novamente; o app não preenche campos ausentes com conteúdo fictício.',
      faq5Q: 'O app funciona sem internet?',
      faq5A: 'A consulta do conteúdo depende da conexão com a API. As preferências escolhidas ficam salvas localmente no aparelho.',
      supportStillEyebrow: 'AINDA PRECISA DE AJUDA?',
      supportStillTitle: 'Estamos por perto.',
      supportStillText: 'Se encontrou um problema, informe o modelo do aparelho, a versão do iOS e o que aconteceu.',
      supportBack: 'Voltar para o app',
      privacyEyebrow: 'PRIVACIDADE',
      privacyTitle: 'Privacidade com clareza.',
      privacyIntro: 'Esta página resume o que o aplicativo faz com os dados necessários para funcionar.',
      privacy1Title: 'O que fica no aparelho',
      privacy1Text: 'O app salva localmente o idioma, o LOC escolhido e, quando disponíveis, o tipo de leitura e a versão da Bíblia. Essas preferências não exigem uma conta.',
      privacy2Title: 'O que é enviado ao serviço',
      privacy2Text: 'Para consultar o lecionário, o app se conecta à API e envia os parâmetros necessários para o LOC, a data e as preferências selecionadas. O tratamento de registros técnicos no servidor depende do operador da API.',
      privacy3Title: 'O que o app não faz',
      privacy3Text: 'O app não solicita nome, e-mail, contatos ou localização e não possui anúncios ou cadastro de usuário.',
      privacy4Title: 'Dúvidas',
      privacy4Text: 'Para dúvidas sobre esta página, use o canal de suporte publicado neste site.',
      privacyBack: 'Voltar para o app',
    },
    en: {
      language: 'en-US',
      shortLanguage: 'EN',
      languageLabel: 'Language',
      brand: 'Lectionary',
      brandAria: 'Anglican Lectionary',
      brandSubline: 'ANGLICAN',
      navHow: 'How it works',
      navSupport: 'Support',
      navPrivacy: 'Privacy',
      heroEyebrow: 'ANGLICAN LECTIONARY · IOS',
      heroTitleLead: 'Give the day',
      heroTitleAccent: 'a rhythm.',
      heroDescription: 'A quiet way to consult the lectionary: begin with today, move through the week, or open the whole month.',
      heroPrimary: 'Explore the app',
      heroSecondary: 'Need help?',
      heroMeta: 'PT-BR · EN-US · ES',
      screenLabel: 'Today view',
      screenCaption: 'Content loaded from the lectionary source',
      screenAlt: 'Anglican Lectionary screen showing the weekly view in English.',
      heroStamp: 'DAILY\nREADING',
      sectionEyebrow: 'AN OPEN BOOK',
      sectionTitle: 'Made to consult, not to distract.',
      sectionIntro: 'The experience begins with one simple choice and lets the content take its proper place.',
      feature1Title: 'Choose your prayer book',
      feature1Text: 'On first launch, see the available books, their covers, and the information returned by the API.',
      feature1Tag: 'First step',
      feature2Title: 'Begin with today',
      feature2Text: 'The main screen puts today at the center and keeps the week and month one tap away.',
      feature2Tag: 'Today · Week · Month',
      feature3Title: 'Set your pace',
      feature3Text: 'When available, the reading track and Bible version are saved in Settings.',
      feature3Tag: 'Preferences',
      sourceEyebrow: 'SOURCE CONTENT',
      sourceTitle: 'The API brings what the day has to say.',
      sourceText: 'The app does not replace readings, celebrations, or collects with demo copy. What appears depends on the prayer book, date, and data provided by the service.',
      languageEyebrow: 'THREE LANGUAGES TO START',
      languageTitle: 'One cadence, three voices.',
      languageText: 'The interface is available in Brazilian Portuguese, English, and Spanish.',
      ctaEyebrow: 'ANGLICAN LECTIONARY',
      ctaTitle: 'Open the day with presence.',
      ctaText: 'Explore the app, choose your prayer book, and find the reading already waiting for you.',
      ctaLink: 'Go to support',
      footerTag: 'A reading rhythm for every day.',
      footerRights: '© {year} Caminho Anglicano',
      supportEyebrow: 'HELP CENTER',
      supportTitle: 'Help without the noise.',
      supportIntro: 'Quick answers to help you start using Anglican Lectionary with confidence.',
      supportContactTitle: 'Talk to the team',
      supportContactText: 'If you cannot find the answer here, send a message to the support channel.',
      supportEmailLabel: 'Send an email',
      faqEyebrow: 'FREQUENTLY ASKED QUESTIONS',
      faqTitle: 'The essentials, plainly.',
      faqIntro: 'The app is designed to feel simple from the first launch.',
      faq1Q: 'Do I need an account?',
      faq1A: 'No. The app does not require sign-up or login. On first launch, choose a prayer book to enter the lectionary.',
      faq2Q: 'How do I choose another prayer book?',
      faq2A: 'Tap the prayer book name in the home header and choose another option. Covers and displayed information come from the API.',
      faq3Q: 'Where are the reading track and Bible settings?',
      faq3A: 'Open Settings from the controls icon in the header. These options appear when the prayer book and source provide them.',
      faq4Q: 'Why might a reading be missing?',
      faq4A: 'Content depends on the prayer book, date, and data returned by the service. Check your connection and try again; the app does not fill missing fields with invented content.',
      faq5Q: 'Does the app work offline?',
      faq5A: 'Content lookup depends on a connection to the API. Your selected preferences are saved locally on the device.',
      supportStillEyebrow: 'STILL NEED HELP?',
      supportStillTitle: 'We are nearby.',
      supportStillText: 'If you found a problem, include your device model, iOS version, and what happened.',
      supportBack: 'Back to the app',
      privacyEyebrow: 'PRIVACY',
      privacyTitle: 'Privacy, clearly stated.',
      privacyIntro: 'This page summarizes what the app does with the data it needs to work.',
      privacy1Title: 'What stays on your device',
      privacy1Text: 'The app stores your language, selected prayer book, and, when available, reading track and Bible version locally. These preferences do not require an account.',
      privacy2Title: 'What is sent to the service',
      privacy2Text: 'To consult the lectionary, the app connects to the API and sends the parameters needed for the prayer book, date, and selected preferences. Server-side technical records are handled by the API operator.',
      privacy3Title: 'What the app does not do',
      privacy3Text: 'The app does not request your name, email, contacts, or location and has no ads or user registration.',
      privacy4Title: 'Questions',
      privacy4Text: 'For questions about this page, use the support channel published on this site.',
      privacyBack: 'Back to the app',
    },
    es: {
      language: 'es',
      shortLanguage: 'ES',
      languageLabel: 'Idioma',
      brand: 'Leccionario',
      brandAria: 'Leccionario Anglicano',
      brandSubline: 'ANGLICANO',
      navHow: 'Cómo funciona',
      navSupport: 'Soporte',
      navPrivacy: 'Privacidad',
      heroEyebrow: 'LECCIONARIO ANGLICANO · IOS',
      heroTitleLead: 'El día encuentra',
      heroTitleAccent: 'su ritmo.',
      heroDescription: 'Una forma serena de consultar el leccionario: empieza por hoy, recorre la semana o abre el mes completo.',
      heroPrimary: 'Conoce la aplicación',
      heroSecondary: '¿Necesitas ayuda?',
      heroMeta: 'PT-BR · EN-US · ES',
      screenLabel: 'Vista de hoy',
      screenCaption: 'Contenido cargado desde la fuente del leccionario',
      screenAlt: 'Pantalla del Leccionario Anglicano mostrando la vista semanal en español.',
      heroStamp: 'LECTURA\nDIARIA',
      sectionEyebrow: 'UN LIBRO ABIERTO',
      sectionTitle: 'Hecho para consultar, no para distraer.',
      sectionIntro: 'La experiencia empieza con una elección sencilla y deja que el contenido ocupe su lugar.',
      feature1Title: 'Elige tu LOC',
      feature1Text: 'En la primera apertura, consulta los libros disponibles, sus portadas y la información que devuelve la API.',
      feature1Tag: 'Primer paso',
      feature2Title: 'Empieza por hoy',
      feature2Text: 'La pantalla principal pone el día actual en el centro y deja la semana y el mes a un toque.',
      feature2Tag: 'Hoy · Semana · Mes',
      feature3Title: 'Ajusta tu ritmo',
      feature3Text: 'Cuando están disponibles, el tipo de lectura y la versión de la Biblia se guardan en Configuración.',
      feature3Tag: 'Preferencias',
      sourceEyebrow: 'CONTENIDO DE LA FUENTE',
      sourceTitle: 'La API trae lo que el día tiene para decir.',
      sourceText: 'La aplicación no reemplaza lecturas, celebraciones o colectas con textos de demostración. Lo que aparece depende del LOC, la fecha y los datos del servicio.',
      languageEyebrow: 'TRES IDIOMAS PARA EMPEZAR',
      languageTitle: 'Una cadencia, tres voces.',
      languageText: 'La interfaz está disponible en portugués de Brasil, inglés y español.',
      ctaEyebrow: 'LECCIONARIO ANGLICANO',
      ctaTitle: 'Abre el día con presencia.',
      ctaText: 'Conoce la aplicación, elige tu LOC y encuentra la lectura que ya te estaba esperando.',
      ctaLink: 'Ir al soporte',
      footerTag: 'Un ritmo de lectura para cada día.',
      footerRights: '© {year} Caminho Anglicano',
      supportEyebrow: 'CENTRO DE AYUDA',
      supportTitle: 'Ayuda sin ruido.',
      supportIntro: 'Respuestas rápidas para empezar a usar el Leccionario Anglicano con tranquilidad.',
      supportContactTitle: 'Habla con el equipo',
      supportContactText: 'Si no encuentras la respuesta aquí, envía un mensaje al canal de soporte.',
      supportEmailLabel: 'Enviar un correo',
      faqEyebrow: 'PREGUNTAS FRECUENTES',
      faqTitle: 'Lo esencial, sin rodeos.',
      faqIntro: 'La aplicación está diseñada para sentirse sencilla desde la primera apertura.',
      faq1Q: '¿Necesito crear una cuenta?',
      faq1A: 'No. La aplicación no requiere registro ni inicio de sesión. En la primera apertura, elige un LOC para entrar al leccionario.',
      faq2Q: '¿Cómo elijo otro LOC?',
      faq2A: 'Toca el nombre del LOC en el encabezado de la pantalla principal y elige otra opción. Las portadas y la información mostrada vienen de la API.',
      faq3Q: '¿Dónde están el tipo de lectura y la Biblia?',
      faq3A: 'Abre Configuración desde el icono de ajustes del encabezado. Estas opciones aparecen cuando el LOC y la fuente las ofrecen.',
      faq4Q: '¿Por qué puede faltar una lectura?',
      faq4A: 'El contenido depende del LOC, la fecha y los datos devueltos por el servicio. Comprueba la conexión e inténtalo de nuevo; la aplicación no completa los campos ausentes con contenido inventado.',
      faq5Q: '¿La aplicación funciona sin conexión?',
      faq5A: 'La consulta del contenido depende de la conexión con la API. Las preferencias elegidas se guardan localmente en el dispositivo.',
      supportStillEyebrow: '¿TODAVÍA NECESITAS AYUDA?',
      supportStillTitle: 'Estamos cerca.',
      supportStillText: 'Si encontraste un problema, incluye el modelo del dispositivo, la versión de iOS y lo que ocurrió.',
      supportBack: 'Volver a la aplicación',
      privacyEyebrow: 'PRIVACIDAD',
      privacyTitle: 'Privacidad con claridad.',
      privacyIntro: 'Esta página resume lo que hace la aplicación con los datos que necesita para funcionar.',
      privacy1Title: 'Lo que queda en el dispositivo',
      privacy1Text: 'La aplicación guarda localmente el idioma, el LOC elegido y, cuando están disponibles, el tipo de lectura y la versión de la Biblia. Estas preferencias no requieren una cuenta.',
      privacy2Title: 'Lo que se envía al servicio',
      privacy2Text: 'Para consultar el leccionario, la aplicación se conecta a la API y envía los parámetros necesarios para el LOC, la fecha y las preferencias seleccionadas. Los registros técnicos del servidor dependen del operador de la API.',
      privacy3Title: 'Lo que la aplicación no hace',
      privacy3Text: 'La aplicación no solicita nombre, correo electrónico, contactos ni ubicación y no tiene anuncios ni registro de usuarios.',
      privacy4Title: 'Dudas',
      privacy4Text: 'Para preguntas sobre esta página, utiliza el canal de soporte publicado en este sitio.',
      privacyBack: 'Volver a la aplicación',
    },
  };

  const readStoredLocale = () => {
    try {
      return localStorage.getItem('lecionario-site-locale');
    } catch (_) {
      return null;
    }
  };

  const queryLocale = new URLSearchParams(window.location.search).get('lang');
  const initialLocale = [queryLocale, readStoredLocale(), 'pt'].find((value) =>
    Object.prototype.hasOwnProperty.call(dictionaries, value),
  );

  let currentLocale = initialLocale || 'pt';

  const setText = (locale) => {
    const copy = dictionaries[locale];
    currentLocale = locale;
    document.documentElement.lang = copy.language;

    document.querySelectorAll('[data-i18n]').forEach((element) => {
      const key = element.dataset.i18n;
      if (copy[key] !== undefined) element.textContent = copy[key];
    });

    document.querySelectorAll('[data-i18n-attr]').forEach((element) => {
      element.dataset.i18nAttr.split(',').forEach((pair) => {
        const [attribute, key] = pair.split(':');
        if (attribute && key && copy[key] !== undefined) {
          element.setAttribute(attribute, copy[key]);
        }
      });
    });

    document.querySelectorAll('[data-locale-image]').forEach((element) => {
      element.src = locale === 'pt'
        ? '/assets/app-home.png'
        : `/assets/app-home-${locale}.png`;
    });

    document.querySelectorAll('[data-footer-rights]').forEach((element) => {
      element.textContent = copy.footerRights.replace('{year}', new Date().getFullYear());
    });

    document.querySelectorAll('[data-current-locale]').forEach((element) => {
      element.textContent = copy.shortLanguage;
    });

    document.querySelectorAll('[data-locale-choice]').forEach((element) => {
      const active = element.dataset.localeChoice === locale;
      element.classList.toggle('is-active', active);
      element.setAttribute('aria-current', active ? 'true' : 'false');
    });

    const title = document.body.dataset.page === 'support'
      ? `${copy.supportTitle} · ${copy.brand}`
      : document.body.dataset.page === 'privacy'
        ? `${copy.privacyTitle} · ${copy.brand}`
        : `${copy.brand} — ${copy.heroTitleLead} ${copy.heroTitleAccent}`;
    document.title = title;
    document.querySelectorAll('[data-language-menu]').forEach((element) => {
      element.setAttribute('aria-label', copy.languageLabel);
    });

    try {
      localStorage.setItem('lecionario-site-locale', locale);
    } catch (_) {
      // Local preference is optional; the page remains fully functional.
    }
  };

  const configureSupport = () => {
    const email = String(config.supportEmail || '').trim();
    document.querySelectorAll('[data-support-contact]').forEach((element) => {
      if (!email) return;
      element.hidden = false;
      element.querySelectorAll('[data-support-email]').forEach((link) => {
        link.href = `mailto:${email}`;
        link.textContent = email;
      });
    });

    const appStoreUrl = String(config.appStoreUrl || '').trim();
    document.querySelectorAll('[data-app-store-cta]').forEach((element) => {
      if (!appStoreUrl) return;
      element.hidden = false;
      element.href = appStoreUrl;
    });
  };

  const configureLanguageMenu = () => {
    const toggle = document.querySelector('[data-language-menu]');
    const menu = document.querySelector('[data-language-options]');
    if (!toggle || !menu) return;

    toggle.addEventListener('click', () => {
      const open = menu.hidden;
      menu.hidden = !open;
      toggle.setAttribute('aria-expanded', String(open));
    });

    document.querySelectorAll('[data-locale-choice]').forEach((choice) => {
      choice.addEventListener('click', () => {
        setText(choice.dataset.localeChoice);
        menu.hidden = true;
        toggle.setAttribute('aria-expanded', 'false');
      });
    });

    document.addEventListener('click', (event) => {
      if (!toggle.closest('.language-switcher')?.contains(event.target)) {
        menu.hidden = true;
        toggle.setAttribute('aria-expanded', 'false');
      }
    });
  };

  configureSupport();
  configureLanguageMenu();
  setText(currentLocale);
})();
