# Checklist de release

## Código e qualidade

- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test --coverage`
- [ ] `./tool/verify_ios_release.sh`
- [ ] `./tool/verify_android_release.sh`
- [ ] `./tool/verify_app_store_assets.sh`
- [ ] `./tool/verify_play_store_assets.sh`
- [ ] `./tool/verify_site.sh`
- [ ] Verificar `git status` e confirmar que apenas arquivos intencionais serão enviados.
- [ ] Confirmar deployment target iOS 15.0 ou superior.
- [ ] Confirmar que o endpoint e o `X-App-Internal-Id` de produção são os corretos.
- [ ] Incrementar a versão com `./tool/version.sh` e confirmar o que cada loja
      vai ver — veja [versioning.md](versioning.md). O número do build é
      compartilhado pelas duas plataformas e nunca se repete.

## Verificação iOS

- [ ] `flutter build ios --release --no-codesign`
- [ ] Revisar Bundle ID, Team ID, deployment target e orientação de tela.
- [ ] Conferir o ícone de produção e a tela inicial em um dispositivo real.
- [ ] Confirmar que nenhum ícone tem canal alpha — a validação do upload
      rejeita, e `flutter test test/app_icon_test.dart` cobre isso.
- [ ] Conferir o `PrivacyInfo.xcprivacy` no target Runner.
- [ ] Conferir que não foram adicionadas permissões de sistema sem necessidade.
- [ ] Abrir os links de privacidade e suporte em Configurações.
- [ ] Testar uma build de desenvolvimento em um iPhone físico; consulte [test-device-without-testflight.md](test-device-without-testflight.md).

## Verificação Android

- [ ] `flutter build appbundle --release` (ou `./tool/build_android_release.sh`).
- [ ] Confirmar o `applicationId`: o Play o amarra à ficha no primeiro upload e
      nunca mais o deixa mudar.
- [ ] Confirmar o nível de API alvo em vigor no Play Console e, se ele tiver
      subido, subir o piso em `android/app/build.gradle.kts` e em
      `tool/verify_android_release.sh` juntos.
- [ ] Conferir o ícone do launcher e a tela de abertura em um aparelho real,
      inclusive no Android 12 ou mais novo, onde o sistema desenha a abertura.
- [ ] Confirmar que o manifest continua pedindo só `INTERNET`.
- [ ] Confirmar que `android/key.properties` e o keystore não entraram no Git.
- [ ] Confirmar o suporte a páginas de 16 KB no bundle gerado.
- [ ] Abrir os links de privacidade e suporte em Configurações.
- [ ] Instalar o bundle em um aparelho real antes do envio
      (`ANDROID_BUILD_APK=1 ./tool/build_android_release.sh` para sideload).

## Produto e conteúdo

- [ ] Testar a seleção inicial do LOC.
- [ ] Testar a troca de idioma em Configurações e confirmar que a lista de LOCs acompanha o idioma.
- [ ] Confirmar que as versões de Bíblia são consultadas para o idioma do LOC selecionado.
- [ ] Testar hoje e o mês, no iPhone, no iPad, em um celular Android e em um tablet.
- [ ] Decidir o que fazer com os LOCs que a API marca como
      `premium_required` / `is_accessible: false` (hoje o app os lista e o
      backend serve o conteúdo).
- [ ] Testar idioma, reading type e versão da Bíblia quando fornecidos pela API.
- [ ] Confirmar que as capas são as URLs/imagens retornadas pela API.
- [ ] Confirmar que estados vazios e erros não substituem a resposta por conteúdo fictício.
- [ ] Fazer um teste com conectividade ruim e outro com o backend indisponível.

## App Store Connect

- [ ] App record criado com o Bundle ID correto.
- [ ] Metadados revisados pelo responsável pelo produto.
- [ ] Política de privacidade publicada em URL real.
- [ ] Política de privacidade também acessível dentro do app.
- [ ] Página de suporte publicada com contato público real.
- [ ] Questionário de App Privacy revisado com o responsável pela API.
- [ ] Classificação etária, categoria e copyright preenchidos.
- [ ] Screenshots atualizadas: `./tool/capture_store_screenshots.sh` (iPhone e
      iPad, três idiomas) e `./tool/verify_app_store_assets.sh`.
- [ ] Screenshots antigas removidas da raiz de `store-assets/app-store/<idioma>/`.
- [ ] Screenshots de iPad enviadas: o app é universal (`TARGETED_DEVICE_FAMILY = "1,2"`)
      e a loja exige o conjunto de iPad para publicar.
- [ ] Build enviado e processado.

## TestFlight

- [ ] Teste interno em pelo menos um iPhone.
- [ ] Teste em iPad se o suporte fizer parte do lançamento.
- [ ] Confirmar instalação, atualização e persistência das preferências.
- [ ] Registrar bugs com versão do app, build, iOS, dispositivo e endpoint.
- [ ] Decidir se o build está pronto para beta externo ou submissão para revisão.

## Google Play

O passo a passo, com as pendências que não dependem do repositório, está em
[play-console.md](play-console.md) — inclusive
[o que falta para ser aprovado](play-console.md#o-que-falta-para-ser-aprovado).

- [ ] Conta de desenvolvedor verificada.
- [ ] Se a conta for pessoal: teste fechado com 12 testadores por 14 dias
      seguidos, concluído, e acesso à produção solicitado. É o item de maior
      prazo do lançamento.
- [ ] Chave de upload gerada e `android/key.properties` preenchido.
- [ ] Ficha da loja preenchida nos três idiomas, com os textos de
      [play-store-metadata.md](play-store-metadata.md).
- [ ] Ícone de 512×512 e gráfico de destaque de 1024×500 enviados.
- [ ] Screenshots atualizadas: `STORE=play ./tool/render_store_screenshots.sh`
      e `./tool/verify_play_store_assets.sh`.
- [ ] Screenshots de tablet enviadas, para o app não ser marcado como não
      otimizado para telas grandes.
- [ ] Formulário de Segurança dos dados revisado com o responsável pela API.
- [ ] Classificação de conteúdo (IARC), público-alvo e declaração de anúncios.
- [ ] Demais declarações respondidas: notícias, finanças, saúde, governo,
      conteúdo gerado pelo usuário e acesso ao app.
- [ ] Países de distribuição e preço.
- [ ] Teste interno instalado em pelo menos um aparelho antes de promover.

## Comandos de referência

```bash
flutter pub get
flutter analyze
flutter test --coverage

./tool/version.sh
./tool/version.sh bump build

./tool/verify_ios_release.sh
flutter build ios --release --no-codesign
IOS_NO_CODESIGN=1 ./tool/build_ios_release.sh
FLUTTER_BUILD_NUMBER=3 ./tool/build_ios_release.sh

./tool/verify_android_release.sh
./tool/build_android_release.sh
ANDROID_BUILD_APK=1 ./tool/build_android_release.sh
./tool/generate_android_assets.py
```
