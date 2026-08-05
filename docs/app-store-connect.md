# App Store Connect

Este documento separa o que já está no projeto do que precisa ser preenchido no App Store Connect. O pacote de copy localizado está em [app-store-metadata.md](app-store-metadata.md), e as screenshots prontas para upload estão em [store-assets/app-store/README.md](../store-assets/app-store/README.md).

## Identidade atual do projeto

- Nome exibido no iOS: `Lecionário Anglicano`
- Bundle ID no Xcode: `br.com.caminhoanglicano.lecionarioanglicano`
- Team ID atualmente configurado: `R573HPN65Q`
- Versão no `pubspec.yaml`: `1.0.0+1`
- Deployment target: iOS 15.0
- Endpoint padrão: `https://api.caminhoanglicano.com.br/api/v1`
- Header de integração: `X-App-Internal-Id`
- Idiomas iniciais da interface: `pt-BR`, `en-US` e `es`

O idioma da interface é alterado em **Configurações**. A troca filtra os LOCs pela língua selecionada; depois que o usuário escolhe um LOC, as versões de Bíblia são carregadas para o idioma retornado por esse LOC.

Confirme o Bundle ID e o Team ID no seu Apple Developer antes do primeiro upload. Se o Bundle ID já estiver registrado, não o altere no projeto.

## Criar o registro do app

No App Store Connect:

- [ ] Criar o app com o nome aprovado pelo produto.
- [ ] Selecionar a plataforma iOS.
- [ ] Usar exatamente o Bundle ID configurado no projeto.
- [ ] Confirmar SKU interno definido pela equipe.
- [ ] Definir categoria, classificação etária e informações de copyright.
- [ ] Preencher URL de suporte.
- [ ] Preencher URL de marketing somente se houver uma página pública do produto.
- [ ] Publicar uma política de privacidade em uma URL real e preencher o campo correspondente.
- [ ] Revisar os nomes, subtítulos, descrições, palavras-chave e textos promocionais em [app-store-metadata.md](app-store-metadata.md).
- [ ] Adicionar screenshots reais do app nos tamanhos solicitados pelo portal.

## Privacidade e conformidade

O projeto contém `ios/Runner/PrivacyInfo.xcprivacy` e declara que não faz tracking e não coleta dados diretamente no app. A integração também usa `shared_preferences` para salvar localmente idioma, LOC, reading type e versão da Bíblia. A tela de Configurações oferece links para a política e o suporte.

Antes de responder o questionário de App Privacy, confronte a declaração com a política da API: o app consulta o backend e envia o `X-App-Internal-Id`, o LOC selecionado e, quando disponíveis, `reading_type` e `bible_version` como parâmetros da requisição. A API não mantém logs identificáveis das requisições; New Relic e Sentry recebem registros operacionais não identificáveis para monitoramento e diagnóstico. A configuração e retenção desses registros ainda devem ser revisadas.

URLs planejadas para o primeiro lançamento:

- Política de privacidade: `https://lecionarioapp.caminhoanglicano.com.br/privacidade/`
- Suporte: `https://lecionarioapp.caminhoanglicano.com.br/suporte/`
- Marketing: `https://lecionarioapp.caminhoanglicano.com.br/`
- Contato para revisão e privacidade: Douglas Araujo — `dev@dodopok.dev`

O `Info.plist` já contém:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Isso informa que o app não usa criptografia não isenta própria. Se o backend ou alguma dependência mudar o perfil de criptografia, reavalie a resposta de export compliance no portal.

## Selecionar um build

1. Execute a suíte local e a análise estática descritas em [release-checklist.md](release-checklist.md).
2. Gere um build assinado com o script:

   ```bash
   FLUTTER_BUILD_NUMBER=3 ./tool/build_ios_release.sh
   ```

3. Se o ambiente de produção precisar de valores diferentes dos defaults, passe-os sem gravá-los no Git:

   ```bash
   API_BASE_URL="https://seu-endpoint-real/api/v1" \
   APP_INTERNAL_IDENTIFIER="seu-identificador" \
   FLUTTER_BUILD_NAME="1.0.0" \
    FLUTTER_BUILD_NUMBER="3" \
    ./tool/build_ios_release.sh
    ```

4. No Xcode Organizer, valide o archive e envie-o ao App Store Connect. O Flutter também deixa o `.ipa` em `build/ios/ipa/`.

O número de build precisa ser maior que qualquer build anterior enviado para a mesma versão. O nome da versão (`FLUTTER_BUILD_NAME`) e o número do build (`FLUTTER_BUILD_NUMBER`) podem ser alterados sem editar o contrato da API.

Para conferir as screenshots antes do upload, execute:

```bash
./tool/verify_app_store_assets.sh
```

## Informações para App Review

Preencha as notas de revisão com informações factuais e atualizadas. O fluxo principal começa pela seleção de um LOC; depois o app consulta a API para mostrar o dia, a semana ou o mês. Se a revisão depender de uma API protegida, forneça nas notas o procedimento de acesso aprovado pela equipe, sem publicar credenciais no repositório.

Referências oficiais: [upload de builds no App Store Connect](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/), [TestFlight](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview) e [deploy de apps Flutter](https://docs.flutter.dev/deployment).
