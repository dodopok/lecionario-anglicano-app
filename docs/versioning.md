# Versão

Uma versão só, para as duas lojas. Ela mora no `pubspec.yaml`:

```yaml
version: 1.0.0+3
```

O que vem antes do `+` é o **nome da versão**, o que as pessoas veem. O que vem
depois é o **número do build**, que só serve para as lojas distinguirem um
envio do outro. O Flutter entrega os dois lados para cada plataforma na hora de
compilar:

| pubspec | Android | iOS |
| ------- | ------- | --- |
| `1.0.0` | `versionName` | `CFBundleShortVersionString` |
| `3`     | `versionCode` | `CFBundleVersion` |

Nem `android/` nem `ios/` guardam uma cópia. `android/app/build.gradle.kts` lê
`flutter.versionCode` e `flutter.versionName`; o `Info.plist` do iOS traz
`$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)`. Escrever um número à mão
em qualquer um dos dois é como as duas plataformas passam a divergir, e é
assim que se descobre, no upload, que o build não é o que se pensava.

## Mexer na versão

```bash
./tool/version.sh                 # o que as lojas vão ver agora
./tool/version.sh bump build      # outro envio da mesma versão
./tool/version.sh bump patch      # 1.0.0 -> 1.0.1, com build novo
./tool/version.sh bump minor      # 1.0.0 -> 1.1.0, com build novo
./tool/version.sh bump major      # 1.0.0 -> 2.0.0, com build novo
./tool/version.sh set 1.2.0       # uma versão exata, com build novo
./tool/version.sh set 1.2.0 12    # e um build exato
```

Todo `bump` mexe no número do build, inclusive quando muda o nome da versão:
as duas lojas recusam um envio cujo número já foi usado, e nenhuma das duas
deixa o número descer. Por isso `set` recusa um build menor ou igual ao atual.

O número do build é **compartilhado** pelas duas plataformas e só sobe. Um
envio para o Android e outro para o iOS na mesma versão gastam dois números, e
não há problema nenhum em haver buracos — o que não pode é repetir.

Para um build pontual sem mexer no arquivo, os dois scripts de release aceitam
as variáveis do Flutter:

```bash
FLUTTER_BUILD_NAME=1.0.0 FLUTTER_BUILD_NUMBER=4 ./tool/build_android_release.sh
FLUTTER_BUILD_NUMBER=4 ./tool/build_ios_release.sh
```

Isso serve para reenviar algo pontualmente. Para o fluxo normal, mova o
`pubspec.yaml` e faça o commit junto com a release: é o arquivo que diz o que
foi enviado.

## Para um script

```bash
$ ./tool/version.sh show --json
{"name":"1.0.0","build":3,"version":"1.0.0+3"}
```

## Antes de enviar

`flutter test test/android_release_test.dart` confere que o formato do
`version:` continua válido e que nenhum dos dois lados passou a carregar um
número próprio.
