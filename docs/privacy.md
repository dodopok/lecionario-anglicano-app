# Inventário de privacidade para revisão

Este é um inventário técnico inicial, não uma política de privacidade publicada nem aconselhamento jurídico. Ele deve ser revisado pelo responsável pelo produto e pela API antes do preenchimento do App Store Connect.

## O que o app faz

- Consulta o backend do lecionário usando HTTPS.
- Envia o header `X-App-Internal-Id` em cada chamada da API.
- Envia o código do LOC selecionado e, quando existem, as preferências `reading_type` e `bible_version` na query `preferences`.
- Consulta versões de Bíblia pelo endpoint disponível, filtrando idioma quando aplicável.

## O que fica no dispositivo

O app usa `shared_preferences` para salvar localmente:

- código do LOC selecionado;
- idioma da interface;
- reading type selecionado;
- código da versão da Bíblia selecionada.

Não há conta, login, câmera, localização ou contatos no fluxo atual do app. Também não há dependência de analytics, anúncios ou crash reporting no `pubspec.yaml` atual.

## Tracking e manifesto da Apple

O app não solicita tracking e o manifesto `ios/Runner/PrivacyInfo.xcprivacy` declara `NSPrivacyTracking` como falso, sem domínios de tracking e sem tipos de dados coletados diretamente pelo app. O manifesto também declara o uso de UserDefaults para preferências locais.

Dependências podem ter seus próprios manifestos; o projeto mantém o manifesto do plugin `shared_preferences_foundation` no build de Pods. Reavalie este inventário se novas dependências, analytics, autenticação ou notificações push forem adicionadas.

## Pontos que ainda precisam de confirmação externa

- Quais dados o servidor registra em logs e por quanto tempo.
- Se o servidor relaciona o `X-App-Internal-Id` a algum usuário, dispositivo ou organização.
- URL pública da política de privacidade.
- Base legal, responsáveis pelo tratamento e canal de contato.
- Respostas finais do questionário App Privacy e da classificação etária.
