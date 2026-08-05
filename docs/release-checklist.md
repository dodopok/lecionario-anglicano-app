# Checklist de release

## Código e qualidade

- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test --coverage`
- [ ] `./tool/verify_ios_release.sh`
- [ ] `./tool/verify_app_store_assets.sh`
- [ ] `./tool/verify_site.sh`
- [ ] Verificar `git status` e confirmar que apenas arquivos intencionais serão enviados.
- [ ] Confirmar deployment target iOS 15.0 ou superior.
- [ ] Confirmar que o endpoint e o `X-App-Internal-Id` de produção são os corretos.
- [ ] Confirmar o número de versão e incrementar o build number.

## Verificação iOS

- [ ] `flutter build ios --release --no-codesign`
- [ ] Revisar Bundle ID, Team ID, deployment target e orientação de tela.
- [ ] Conferir o ícone de produção e a tela inicial em um dispositivo real.
- [ ] Conferir o `PrivacyInfo.xcprivacy` no target Runner.
- [ ] Conferir que não foram adicionadas permissões de sistema sem necessidade.
- [ ] Abrir os links de privacidade e suporte em Configurações.
- [ ] Testar uma build de desenvolvimento em um iPhone físico; consulte [test-device-without-testflight.md](test-device-without-testflight.md).

## Produto e conteúdo

- [ ] Testar a seleção inicial do LOC.
- [ ] Testar a troca de idioma em Configurações e confirmar que a lista de LOCs acompanha o idioma.
- [ ] Confirmar que as versões de Bíblia são consultadas para o idioma do LOC selecionado.
- [ ] Testar hoje, semana e mês.
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
- [ ] Screenshots reais adicionadas.
- [ ] Build enviado e processado.

## TestFlight

- [ ] Teste interno em pelo menos um iPhone.
- [ ] Teste em iPad se o suporte fizer parte do lançamento.
- [ ] Confirmar instalação, atualização e persistência das preferências.
- [ ] Registrar bugs com versão do app, build, iOS, dispositivo e endpoint.
- [ ] Decidir se o build está pronto para beta externo ou submissão para revisão.

## Comandos de referência

```bash
flutter pub get
flutter analyze
flutter test --coverage
./tool/verify_ios_release.sh
flutter build ios --release --no-codesign
IOS_NO_CODESIGN=1 ./tool/build_ios_release.sh
FLUTTER_BUILD_NUMBER=2 ./tool/build_ios_release.sh
```
