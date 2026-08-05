# Lecionário Anglicano

Aplicativo Flutter para consultar o lecionário anglicano por dia, semana e mês.

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
