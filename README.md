# Lecionário Anglicano

Aplicativo Flutter para consultar o lecionário anglicano: o dia de hoje e o mês inteiro em uma tela.

## Desenvolvimento

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.caminhoanglicano.com.br/api/v1
```

O app usa o mesmo contrato do `ordo-app`: as chamadas enviam `X-App-Internal-Id` e a preferência do LOC em `preferences`.

As configurações podem ser trocadas por `--dart-define`:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.caminhoanglicano.com.br/api/v1 \
  --dart-define=APP_INTERNAL_IDENTIFIER=seu-identificador
```

O app não substitui dados da API por conteúdo local: quando uma resposta falha ou não traz um campo, esse conteúdo permanece vazio.

Os idiomas iniciais da interface são Português do Brasil (`pt-BR`), English (United States, `en-US`) e Español (`es`).

### Beta: acesso a um LOC `external_only`

Enquanto um livro de oração estiver marcado `external_only` no backend (ex.: LOC 2027, publicado só pra
consumidores com API key até os ofícios diários existirem), ele fica invisível pelo fluxo normal de
`X-App-Internal-Id`. Pra liberar mesmo assim durante o beta, builda passando a API key da Estêvão API:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.caminhoanglicano.com.br/api/v1 \
  --dart-define=API_KEY=estevao_xxxxxxxxxxxxxxxx
```

ou, pros scripts de release — Android e iOS separados, ou os dois numa chamada só:

```bash
API_KEY=estevao_xxxxxxxxxxxxxxxx ./tool/build_android_release.sh
API_KEY=estevao_xxxxxxxxxxxxxxxx ./tool/build_ios_release.sh
API_KEY=estevao_xxxxxxxxxxxxxxxx ./tool/build_release.sh
```

A key nunca deve ser commitada — passe sempre por `--dart-define`/variável de ambiente na hora do build (local
ou CI). Sem ela, o app volta sozinho ao comportamento normal (`X-App-Internal-Id`), então **pra desligar o
beta depois que o livro virar `app_visible`, basta parar de passar `API_KEY` no build** — não precisa mexer em
código.

## Versão

Uma versão só, no `pubspec.yaml`, para as duas lojas — o Flutter a entrega
como `versionName`/`versionCode` no Android e como
`CFBundleShortVersionString`/`CFBundleVersion` no iOS.

```bash
./tool/version.sh                 # o que cada loja vai ver
./tool/version.sh bump build      # outro envio da mesma versão
./tool/version.sh bump minor      # 1.0.0 -> 1.1.0, com build novo
```

Detalhes em [docs/versioning.md](docs/versioning.md).

## Distribuição iOS

O projeto já inclui ícone, launch screen, privacy manifest e configuração de assinatura para o target Runner. Para preparar um build do TestFlight, consulte:

- [Checklist de release](docs/release-checklist.md)
- [Guia do TestFlight](docs/testflight.md)
- [App Store Connect](docs/app-store-connect.md)
- [Inventário de privacidade](docs/privacy.md)

O comando de archive é:

```bash
FLUTTER_BUILD_NUMBER=3 ./tool/build_ios_release.sh
```

O upload para o App Store Connect continua sendo feito na sessão Apple do responsável pela conta; nenhum certificado, segredo ou metadado de loja é versionado neste repositório.

## Distribuição Android

O projeto inclui o ícone do launcher em todas as densidades, o ícone
adaptativo, a tela de abertura e a assinatura de release lendo
`android/key.properties` — que fica fora do Git, como o keystore. Para
preparar um envio à Google Play, consulte:

- [Checklist de release](docs/release-checklist.md)
- [Play Console](docs/play-console.md), incluindo
  [o que falta para ser aprovado](docs/play-console.md#o-que-falta-para-ser-aprovado)
- [Metadados da Play](docs/play-store-metadata.md)
- [Gráficos da listagem](store-assets/play-store/README.md)

O comando de build é:

```bash
./tool/build_android_release.sh
```

Ele recusa começar sem a chave de upload, porque um bundle assinado com a
chave de debug é recusado no envio. O `.aab` sai em
`build/app/outputs/bundle/release/`. Para um teste em aparelho físico sem
passar pela loja, `ANDROID_BUILD_APK=1 ./tool/build_android_release.sh`.
