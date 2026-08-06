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
