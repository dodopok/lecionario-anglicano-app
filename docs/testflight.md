# TestFlight

## Pré-requisitos

- Conta Apple Developer ativa.
- App criado no App Store Connect com o Bundle ID deste projeto.
- Xcode conectado ao seu Apple ID e ao Team correto.
- Um dispositivo iPhone ou iPad para o teste funcional.
- E-mails dos testadores, caso o grupo não seja apenas você.

## Gerar o build

Antes de gerar o archive:

```bash
flutter pub get
flutter analyze
flutter test --coverage
./tool/verify_ios_release.sh
```

Para uma verificação local sem certificados:

```bash
flutter build ios --release --no-codesign
```

Para o archive que será enviado:

```bash
FLUTTER_BUILD_NUMBER=3 ./tool/build_ios_release.sh
```

Para validar o mesmo script sem certificados, use `IOS_NO_CODESIGN=1`; esse modo não gera um artefato enviável:

```bash
IOS_NO_CODESIGN=1 ./tool/build_ios_release.sh
```

O script aceita `API_BASE_URL`, `APP_INTERNAL_IDENTIFIER`, `FLUTTER_BUILD_NAME` e `FLUTTER_BUILD_NUMBER` por variável de ambiente. Esses valores não devem ser colocados em scripts de CI públicos, logs ou commits.

## Enviar ao TestFlight

1. Abra o archive gerado pelo Flutter no Xcode Organizer ou abra o workspace `ios/Runner.xcworkspace` e faça o Archive pelo Xcode.
2. Selecione **Distribute App** e envie para **App Store Connect**.
3. Aguarde o processamento do build no portal.
4. Adicione o build ao grupo de testes interno.
5. Convide os testadores internos. Para testadores externos, complete as informações de beta e aguarde a revisão beta quando solicitada pelo portal.

O upload real exige a sua sessão Apple, certificados e permissões do App Store Connect; este repositório não armazena esses dados.

## Roteiro do teste

- Instalar o build em um iPhone e, se aplicável, em um iPad.
- Confirmar o ícone, a tela inicial e o nome `Lecionário Anglicano`.
- Selecionar um LOC na primeira abertura.
- Trocar idioma e confirmar que a interface acompanha a escolha.
- Conferir as capas retornadas pela API no seletor de LOC.
- Se o LOC fornecer `reading_type`, selecionar uma opção e reabrir o app para confirmar a preferência salva.
- Selecionar uma Bíblia quando o endpoint retornar versões disponíveis e confirmar que a preferência permanece salva.
- Consultar dia, semana e mês com conectividade real.
- Testar resposta vazia, indisponibilidade do backend e retorno para o dia atual.
- Confirmar que nenhum texto litúrgico local aparece quando a API não o fornece.

Registre o número do build, o dispositivo, a versão do iOS e o endpoint usado em cada rodada.

## Assinatura e problemas comuns

Se o Xcode reclamar de assinatura:

1. Abra `ios/Runner.xcworkspace`, não apenas o `.xcodeproj`.
2. Selecione o target **Runner** e a aba **Signing & Capabilities**.
3. Escolha o Team da conta correta e mantenha **Automatically manage signing** ativo.
4. Confirme que o Bundle ID continua sendo `br.com.caminhoanglicano.lecionarioanglicano`.
5. Repita o Archive com um número de build novo.

Não faça commit de `.p12`, provisioning profiles, certificados, chaves privadas ou arquivos exportados com credenciais.
