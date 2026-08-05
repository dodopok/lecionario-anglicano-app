# Inventário de privacidade para revisão

Este é um inventário técnico para revisão, não aconselhamento jurídico. A política pública está em `site/privacidade/` e deve ser revisada pelo responsável pelo produto antes da publicação.

## Responsável informado

- Responsável legal informado: Douglas Araujo.
- Canal público: `dev@dodopok.dev`.
- Política: `https://lecionarioapp.caminhoanglicano.com.br/privacidade/`.
- Suporte: `https://lecionarioapp.caminhoanglicano.com.br/suporte/`.

## O que o app faz

- Consulta o backend do lecionário usando HTTPS.
- Envia o header `X-App-Internal-Id` em cada chamada da API.
- Envia o código do LOC selecionado e, quando existem, as preferências `reading_type` e `bible_version` na query `preferences`.
- Consulta versões de Bíblia pelo endpoint disponível, filtrando idioma quando aplicável.

Segundo a confirmação do responsável pela API, o servidor não mantém logs identificáveis das requisições.

## O que fica no dispositivo

O app usa `shared_preferences` para salvar localmente:

- código do LOC selecionado;
- idioma da interface;
- reading type selecionado;
- código da versão da Bíblia selecionada.

Não há conta, login, câmera, localização ou contatos no fluxo atual do app. Também não há dependência de anúncios ou analytics no `pubspec.yaml` atual. O backend usa New Relic e Sentry para registros operacionais não identificáveis de monitoramento e diagnóstico.

## Tracking e manifesto da Apple

O app não solicita tracking e o manifesto `ios/Runner/PrivacyInfo.xcprivacy` declara `NSPrivacyTracking` como falso, sem domínios de tracking e sem tipos de dados coletados diretamente pelo app. O manifesto também declara o uso de UserDefaults para preferências locais.

Dependências podem ter seus próprios manifestos; o projeto mantém o manifesto do plugin `shared_preferences_foundation` no build de Pods. Reavalie este inventário se novas dependências, analytics, autenticação ou notificações push forem adicionadas.

## Pontos que ainda precisam de confirmação externa

- Configuração e prazo de retenção dos registros operacionais do New Relic e do Sentry, para documentar a política com precisão.
- Respostas finais do questionário App Privacy e da classificação etária.
- Revisão jurídica da política e dos direitos aplicáveis nas regiões de distribuição.
