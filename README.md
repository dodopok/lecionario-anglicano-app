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

Quando a API não está disponível, o app entra em modo de prévia local para que o fluxo de seleção e a navegação possam ser testados.
