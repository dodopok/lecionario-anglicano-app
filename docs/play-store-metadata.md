# Metadados da Google Play

Pacote preparado para a primeira versão Android do Lecionário Anglicano. Como
na App Store, os textos descrevem somente recursos implementados no app: o
conteúdo litúrgico não está embutido nem nos textos nem no aplicativo, ele é
carregado da API.

Os limites do Play são diferentes dos da Apple e são recusados no próprio
formulário:

| Campo               | Limite         |
| ------------------- | -------------- |
| Nome do app         | 30 caracteres  |
| Descrição curta     | 80 caracteres  |
| Descrição completa  | 4000 caracteres |

O Play não tem campo de palavras-chave: a busca lê o nome e as descrições. Não
encha os textos de termos repetidos — a política de *spam* de metadados trata
isso como motivo de recusa.

## Informações gerais

- ID do aplicativo: `br.com.caminhoanglicano.lecionario_anglicano`
- Versão no `pubspec.yaml`: `1.0.0+3` (`versionName 1.0.0`, `versionCode 3`)
- Categoria sugerida: Estilo de vida (alternativa: Livros e referências)
- Tags: lecionário, liturgia, calendário litúrgico
- Contém anúncios: **não**
- Compras no app: **não**
- Idiomas da listagem: Português (Brasil), English (United States) e Español

No Play Console o espanhol aparece como **Español (Latinoamérica)** e
**Español (España)**. A pasta `store-assets/play-store/es/` serve as duas;
escolha uma como idioma da listagem e, se quiser as duas, envie as mesmas
imagens e os mesmos textos.

## Português (Brasil)

**Nome do app:** `Lecionário Anglicano`

**Descrição curta:**

> Leituras do lecionário anglicano para cada dia, por dia e por mês.

**Descrição completa:**

> O Lecionário Anglicano reúne o dia de hoje e o mês inteiro em uma tela.
>
> Na primeira abertura, escolha o LOC que deseja consultar. A partir daí,
> navegue pelas datas e veja as leituras e demais informações que a fonte
> disponibilizar para aquele LOC.
>
> O app permite:
>
> • consultar o dia atual;
> • navegar pelo mês e abrir qualquer dia;
> • deixar o domingo ao centro do calendário, quando preferir;
> • escolher entre os LOCs disponíveis;
> • visualizar a capa retornada para cada LOC;
> • salvar o tipo de leitura quando o LOC oferecer essa opção;
> • escolher e salvar uma versão da Bíblia quando disponível;
> • usar a interface em português do Brasil, inglês ou espanhol.
>
> Em tablets, o calendário e as leituras do dia ficam lado a lado.
>
> O app não pede conta nem login e não exibe anúncios. As preferências de
> idioma, LOC, tipo de leitura e versão da Bíblia ficam salvas apenas no
> aparelho.
>
> O conteúdo do lecionário é carregado da API pela internet. O que aparece no
> app depende dos dados fornecidos para o LOC e a data escolhidos.

## English (United States)

**App name:** `Anglican Lectionary`

**Short description:**

> The Anglican lectionary for every day, by day and by month.

**Full description:**

> Anglican Lectionary brings today and the whole month together on one screen.
>
> On first launch, choose the prayer book you want to consult. Then browse
> dates and read the readings and other information provided for that prayer
> book.
>
> The app lets you:
>
> • view today's lectionary;
> • browse the month and open any day;
> • keep Sunday in the middle of the calendar, if you prefer;
> • choose from the available prayer books;
> • view the cover returned for each prayer book;
> • save a reading track when the prayer book provides one;
> • choose and save a Bible version when available;
> • use the interface in Brazilian Portuguese, English, or Spanish.
>
> On tablets, the calendar and the day's readings sit side by side.
>
> The app asks for no account and no sign-in, and shows no ads. Your language,
> prayer book, reading track and Bible version are saved on the device only.
>
> Lectionary content is loaded from the API over the internet. What appears in
> the app depends on the data provided for the selected prayer book and date.

## Español

**Nombre de la app:** `Leccionario Anglicano`

**Descripción corta:**

> El leccionario anglicano para cada día, por día y por mes.

**Descripción completa:**

> El Leccionario Anglicano reúne el día de hoy y el mes entero en una pantalla.
>
> Al abrir la aplicación por primera vez, elige el LOC que quieres consultar.
> Después, navega por las fechas y consulta las lecturas y la información que
> la fuente proporcione para ese LOC.
>
> La aplicación permite:
>
> • consultar el leccionario de hoy;
> • navegar por el mes y abrir cualquier día;
> • dejar el domingo al centro del calendario, si lo prefieres;
> • elegir entre los LOC disponibles;
> • ver la portada proporcionada para cada LOC;
> • guardar el tipo de lectura cuando el LOC lo ofrezca;
> • elegir y guardar una versión de la Biblia cuando esté disponible;
> • usar la interfaz en portugués de Brasil, inglés o español.
>
> En tablets, el calendario y las lecturas del día se muestran lado a lado.
>
> La aplicación no pide cuenta ni inicio de sesión y no muestra anuncios. El
> idioma, el LOC, el tipo de lectura y la versión de la Biblia se guardan
> solo en el dispositivo.
>
> El contenido del leccionario se carga desde la API por internet. Lo que
> aparece en la aplicación depende de los datos proporcionados para el LOC y
> la fecha elegidos.

## Gráficos da listagem

Ficam em `store-assets/play-store/` e são gerados pelos scripts do
repositório — veja [o README da pasta](../store-assets/play-store/README.md).

| Recurso                     | Onde                                          | Tamanho    |
| --------------------------- | --------------------------------------------- | ---------- |
| Ícone da listagem           | `icon.png`                                    | 512×512    |
| Gráfico de destaque         | `<idioma>/feature-graphic.png`                | 1024×500   |
| Screenshots de celular      | `<idioma>/phone/`                             | 1080×1920  |
| Screenshots de tablet 7"    | `<idioma>/tablet-7/`                          | 1200×1920  |
| Screenshots de tablet 10"   | `<idioma>/tablet-10/`                         | 1600×2560  |

O gráfico de destaque é obrigatório para publicar; sem ele a listagem não sai
do rascunho. As screenshots de tablet não bloqueiam a publicação, mas sem elas
o Play marca o app como não otimizado para telas grandes e deixa de
recomendá-lo em tablets e ChromeOS.

## Contato e URLs

- E-mail de contato (público na listagem): `dev@dodopok.dev`
- Política de privacidade: `https://lecionarioapp.caminhoanglicano.com.br/privacidade/`
- Site: `https://lecionarioapp.caminhoanglicano.com.br/`
- Suporte: `https://lecionarioapp.caminhoanglicano.com.br/suporte/`

O e-mail de contato aparece na página pública do app. Confirme que é um
endereço monitorado antes de publicar: é por ele que o Play encaminha
notificações de política.

## Acesso ao app, para a revisão

Na seção **Acesso ao app**, marque que todas as funcionalidades estão
disponíveis sem restrição — o app não tem login. Texto sugerido para as
instruções, caso o formulário peça:

> O app não exige conta nem login. Na primeira abertura, selecione um LOC para
> entrar no lecionário. Depois, toque no cartão do dia para abrir as leituras
> de hoje e navegue pelo calendário do mês. As preferências de idioma, LOC,
> tipo de leitura e Bíblia ficam no ícone de configurações no cabeçalho.
>
> O conteúdo é carregado da API pela internet. Para validar o fluxo, mantenha o
> aparelho conectado e selecione um dos LOCs apresentados na primeira tela.
