# Google Play Console

Este documento separa o que já está no projeto do que ainda precisa ser feito
no Play Console. O pacote de textos localizados está em
[play-store-metadata.md](play-store-metadata.md); os gráficos prontos para
upload estão em
[store-assets/play-store/README.md](../store-assets/play-store/README.md).

Para a lista de tudo que ainda falta, em ordem, veja
[o que falta para ser aprovado](#o-que-falta-para-ser-aprovado) no fim.

## Identidade atual do projeto

- Nome no launcher: `Lecionário`
- ID do aplicativo: `br.com.caminhoanglicano.lecionario_anglicano`
- Versão no `pubspec.yaml`: `1.0.0+3` (`versionName 1.0.0`, `versionCode 3`)
- `targetSdk`: o do Flutter, com piso na API 35 (veja
  [requisitos técnicos](#requisitos-técnicos-do-binário))
- `minSdk`: o do Flutter
- Permissões declaradas: apenas `android.permission.INTERNET`
- Endpoint padrão: `https://api.caminhoanglicano.com.br/api/v1`
- Header de integração: `X-App-Internal-Id`

> **Confirme o ID do aplicativo antes do primeiro upload.** O Play amarra a
> ficha ao `applicationId` no primeiro envio e nunca mais o deixa mudar; para
> trocá-lo depois é preciso criar outra listagem, sem os downloads e as
> avaliações da primeira. O ID do Android tem um `_` que o Bundle ID do iOS não
> tem — `lecionario_anglicano` contra `lecionarioanglicano`. Os dois são
> válidos e nada obriga que sejam iguais, mas se a intenção era serem iguais,
> este é o último momento para alinhar: mude
> `android/app/build.gradle.kts` (`namespace` e `applicationId`), renomeie a
> pasta de `android/app/src/main/kotlin/...` junto e rode
> `./tool/verify_android_release.sh`.

## O que já está no repositório

- Ícone do launcher em todas as densidades, e o ícone adaptativo que o Android
  8 em diante usa — gerados a partir do mesmo ícone de 1024 px que o iOS
  publica, por `./tool/generate_android_assets.py`.
- Ícone de 512×512 da ficha da loja, em `store-assets/play-store/icon.png`.
- Tela de abertura na cor do app, inclusive no formato que o Android 12 em
  diante desenha sozinho (`values-v31/styles.xml`).
- Assinatura de release lendo `android/key.properties`, que é gitignored.
- `versionCode` e `versionName` vindos do `pubspec.yaml`, movidos por
  `./tool/version.sh`.
- Divisão por idioma desligada no bundle, para que os três idiomas do app
  cheguem em qualquer download.
- Scripts de build e de verificação, e testes na suíte:
  `flutter test test/android_release_test.dart`.

## Conta de desenvolvedor

Antes de qualquer upload:

- [ ] Conta de desenvolvedor criada e paga (taxa única de US$ 25).
- [ ] Verificação de identidade concluída. Contas pessoais enviam documento;
      contas de organização precisam de número D-U-N-S e de verificação dos
      dados da empresa. A verificação leva dias e trava a publicação.
- [ ] Endereço e telefone de contato confirmados no perfil.

> **O teste fechado de 14 dias.** Contas **pessoais** criadas a partir de
> novembro de 2023 só ganham acesso à produção depois de rodar um teste
> fechado com pelo menos **12 testadores inscritos por 14 dias seguidos**, e
> só então solicitar o acesso. Contas de **organização** não passam por isso.
> É o item de maior prazo de todo o lançamento — se a conta for pessoal, o
> teste fechado deve começar antes de tudo o mais estar pronto, não depois.
> Confirme o número e os dias vigentes no próprio Console, na página de acesso
> à produção.

## Chave de upload e assinatura

O Play assina o app com uma chave que ele guarda (Play App Signing,
obrigatório para apps novos). O que você gera aqui é a **chave de upload**, que
só serve para provar que o envio é seu.

```bash
keytool -genkey -v -keystore ~/keys/lecionario-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Depois copie `android/key.properties.example` para `android/key.properties` e
preencha. Nem o arquivo nem o keystore entram no Git — `android/.gitignore` já
cobre `key.properties`, `*.jks` e `*.keystore`.

Perder a chave de upload não faz perder a listagem: o Play guarda a chave de
assinatura e permite redefinir a de upload. Mas o processo trava os envios até
sair, então guarde uma cópia fora da máquina.

## Gerar o bundle

```bash
./tool/version.sh bump build      # todo upload precisa de um versionCode novo
./tool/build_android_release.sh
```

O script recusa começar se `android/key.properties` não estiver lá, porque um
bundle assinado com a chave de debug é recusado no upload. O arquivo sai em
`build/app/outputs/bundle/release/app-release.aab`.

Para apontar o build para outro endpoint sem gravar nada no Git:

```bash
API_BASE_URL="https://seu-endpoint-real/api/v1" \
APP_INTERNAL_IDENTIFIER="seu-identificador" \
  ./tool/build_android_release.sh
```

Para instalar em um aparelho físico sem passar pelo Play, um APK resolve:

```bash
ANDROID_BUILD_APK=1 ./tool/build_android_release.sh
```

O Play não aceita APK: apps publicados a partir de agosto de 2021 enviam
`.aab`. O APK serve só para teste local.

## Ficha da loja

Com os textos de [play-store-metadata.md](play-store-metadata.md):

- [ ] App criado no Console com o `applicationId` correto.
- [ ] Nome, descrição curta e descrição completa nos três idiomas.
- [ ] Ícone de 512×512 e gráfico de destaque de 1024×500.
- [ ] Screenshots de celular (mínimo 2; o repositório traz 4).
- [ ] Screenshots de tablet 7" e 10", para o app não ser marcado como não
      otimizado para telas grandes.
- [ ] Categoria e tags.
- [ ] E-mail de contato público.
- [ ] URL da política de privacidade — publicada e abrindo em janela anônima.
- [ ] Países e regiões de distribuição.
- [ ] App gratuito, sem compras no app.

```bash
./tool/verify_play_store_assets.sh
```

## Declarações obrigatórias no Console

Nenhuma delas é opcional: a ficha não sai do rascunho enquanto houver uma em
aberto.

### Segurança dos dados

É um formulário à parte da política de privacidade, e as respostas aparecem na
página pública do app. O inventário técnico está em [privacy.md](privacy.md).
O que o app faz hoje:

- não pede conta, login, câmera, localização, contatos nem identificador de
  publicidade;
- salva idioma, LOC, tipo de leitura e versão da Bíblia **apenas no aparelho**
  (`shared_preferences`), o que o Play não considera coleta;
- envia à API, por HTTPS, o header `X-App-Internal-Id` e o LOC selecionado com
  as preferências da consulta.

Resposta proposta: **nenhum dado do usuário coletado ou compartilhado**, com
criptografia em trânsito. Ela depende de uma confirmação que ainda está em
aberto no `privacy.md`: se o New Relic ou o Sentry do backend retêm IP ou
identificadores por requisição, isso muda a resposta. Confirme com o
responsável pela API antes de enviar o formulário — declarar a menos aqui é
motivo de suspensão.

### Classificação de conteúdo

Questionário IARC, respondido uma vez e reaproveitado pelos órgãos de cada
região. O app não tem violência, conteúdo sexual, apostas, compras nem
interação entre usuários; tem conteúdo religioso, que o questionário pergunta
explicitamente. O resultado esperado é livre para todos os públicos.

- [ ] Questionário respondido e classificação emitida.

### Público-alvo e conteúdo

- [ ] Faixas etárias selecionadas. O app não é dirigido a crianças; marque as
      faixas adultas e confirme que ele não atrai crianças, para não cair nas
      regras do programa Famílias, que exigem bem mais.
- [ ] Declaração de anúncios: **o app não contém anúncios**.

### As demais declarações

Todas negativas neste app, mas todas precisam ser respondidas:

- [ ] App de notícias: não.
- [ ] Recursos financeiros: não.
- [ ] Apps de saúde: não.
- [ ] App do governo: não.
- [ ] Conteúdo gerado pelo usuário: não.
- [ ] Acesso ao app: sem restrição de login — veja o texto em
      [play-store-metadata.md](play-store-metadata.md#acesso-ao-app-para-a-revisão).

## Requisitos técnicos do binário

- **Nível de API alvo.** O Play recusa uma versão que tenha um alvo abaixo do
  que ele está exigindo. O piso está fixado em
  `android/app/build.gradle.kts` e conferido por
  `tool/verify_android_release.sh`. O Google sobe essa exigência todo dia 31 de
  agosto; confirme o nível em vigor no próprio Console antes de enviar e suba o
  piso nos dois lugares junto.
- **Páginas de 16 KB.** Aparelhos Android de 64 bits passaram a usar páginas de
  memória de 16 KB, e o Play exige que apps novos as suportem. O Flutter e os
  plugins deste projeto já compilam assim em versões recentes do SDK; confirme
  no bundle gerado, pelo APK Analyzer do Android Studio, antes do primeiro
  envio.
- **App Bundle.** `.aab`, não `.apk`.
- **Telas grandes.** O app roda em tablet com layout próprio (calendário e
  leituras lado a lado) e gira livremente a partir de 600dp — o Play avalia
  isso, e as screenshots de tablet são parte da avaliação.

## Riscos de política que valem uma olhada antes

Nada aqui é impedimento automático, mas são os pontos deste app que uma
revisão pode questionar:

- **Conteúdo de terceiros.** O app apresenta lecionários e leituras servidos
  pela API, e não textos próprios. A política de propriedade intelectual do
  Play recusa apps que reproduzem obra de terceiros sem autorização. Tenha
  documentada a autorização de uso dos LOCs e das versões da Bíblia servidas
  pela API — é o tipo de coisa que a revisão pede depois de recusar, não antes.
- **Nome e marca.** A listagem não deve sugerir que o app é oficial de alguma
  província ou denominação anglicana, se ele não for. O texto atual não
  sugere; verifique se o ícone, o gráfico de destaque e o nome do
  desenvolvedor também não.
- **Dependência de rede.** Sem internet o app não tem o que mostrar. Confirme
  que os estados vazios e de erro explicam isso — uma tela em branco na
  revisão vira "app não funcional".

## Trilhas e envio

Ordem que costuma custar menos tempo:

1. **Teste interno** (até 100 testadores, disponível de imediato): sobe o
   primeiro bundle e confirma que instala, atualiza e fala com a API de
   produção.
2. **Teste fechado**: obrigatório para conta pessoal, com os 12 testadores por
   14 dias. Também é onde a ficha da loja é revisada pela primeira vez.
3. **Solicitar acesso à produção** (conta pessoal).
4. **Produção**, com lançamento gradual se preferir.

A primeira revisão de um app novo costuma levar mais que as seguintes. Cada
envio precisa de um `versionCode` maior que o anterior — nunca reaproveite um
número já enviado, nem em outra trilha.

## O que falta para ser aprovado

Em ordem de prazo, do que demora mais para o que se resolve na hora. O que o
repositório já resolveu não está aqui.

**Só o dono da conta pode fazer:**

1. Conta de desenvolvedor criada, paga e com identidade verificada.
2. Se a conta for pessoal: teste fechado com 12 testadores por 14 dias
   seguidos, antes de pedir acesso à produção. É o item mais longo.
3. Chave de upload gerada e `android/key.properties` preenchido.

**Precisa de uma confirmação externa:**

4. Retenção de registros do New Relic e do Sentry, para responder o formulário
   de Segurança dos dados com precisão (já aberto em [privacy.md](privacy.md)).
5. Autorização de uso do conteúdo litúrgico servido pela API.
6. Política de privacidade e página de suporte publicadas e acessíveis
   publicamente — a mesma pendência do lançamento iOS.

**Depende de uma máquina com Flutter:**

7. Screenshots e gráfico de destaque renderizados e revisados:
   `STORE=play ./tool/render_store_screenshots.sh`.
8. Bundle assinado, gerado e instalado em um aparelho real antes do envio.
9. Suporte a páginas de 16 KB conferido no bundle.

**No Console, com o material que já existe:**

10. Ficha da loja preenchida nos três idiomas.
11. Segurança dos dados, classificação de conteúdo, público-alvo, anúncios e
    as demais declarações.
12. Países de distribuição e preço.

Referências oficiais:
[preparar o lançamento](https://support.google.com/googleplay/android-developer/answer/9859152),
[requisitos de nível de API](https://support.google.com/googleplay/android-developer/answer/11926878)
e [deploy de apps Flutter no Android](https://docs.flutter.dev/deployment/android).
