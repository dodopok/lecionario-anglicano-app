# Testar em um iPhone sem TestFlight

É possível instalar a build diretamente em um iPhone conectado ao Mac pelo Xcode ou pelo Flutter. Isso usa assinatura de desenvolvimento e não publica o app nem inicia a revisão da Apple.

## Pelo Xcode com cabo

1. Conecte o iPhone ao Mac, desbloqueie-o e aceite **Confiar neste computador**.
2. No iPhone, habilite **Ajustes > Privacidade e Segurança > Modo Desenvolvedor** e reinicie quando solicitado.
3. Abra `ios/Runner.xcworkspace` no Xcode.
4. Em **Signing & Capabilities**, selecione seu Team e mantenha **Automatically manage signing** ativo.
5. Selecione o iPhone como destino e clique em **Run**.

O Xcode pode registrar automaticamente o dispositivo e gerar o perfil de desenvolvimento quando a assinatura automática está ativa. O Bundle ID usado pelo projeto é `br.com.caminhoanglicano.lecionarioanglicano`.

## Depois, pelo Wi-Fi

Depois da primeira associação por cabo, você pode desconectar o iPhone e continuar executando pelo Wi-Fi:

1. Mantenha o Mac e o iPhone na mesma rede Wi-Fi.
2. No Xcode, abra **Window > Devices and Simulators** ou **Manage Devices…** para abrir o Device Hub.
3. Selecione o iPhone já associado e confirme que ele aparece como disponível.
4. Escolha o iPhone como destino de execução no Xcode.
5. Pelo Flutter, confirme que ele aparece em `flutter devices` e execute `flutter run -d <id-do-iphone>`.

A rede precisa permitir IPv6. Redes de convidado, VPNs e firewalls podem impedir a descoberta do dispositivo.

Em iOS/iPadOS 27 ou posterior, o Device Hub também oferece **Add Device (+) > Pair Nearby Device…** para fazer a associação sem fio. Em versões anteriores, a Apple orienta fazer a primeira associação usando um cabo; depois, o cabo pode ser removido para executar pelo Wi-Fi.

## Pelo Flutter

Com o iPhone conectado e confiável:

```bash
flutter devices
flutter run -d <id-do-iphone>
```

Para uma execução sem o depurador, use o Xcode para selecionar a opção **Debug executable** conforme a necessidade do teste. A build direta deve ser usada no dispositivo da equipe; para distribuir a um grupo de testers, use TestFlight ou uma distribuição Ad Hoc devidamente assinada.

## Riscos e cuidados

- O Modo Desenvolvedor reduz algumas proteções do sistema para permitir a execução de apps assinados localmente. Ative-o somente no aparelho que será usado para desenvolvimento e desative-o quando terminar.
- A build atual consulta o endpoint configurado e envia o header interno da aplicação. Faça testes em um aparelho da equipe e não distribua o `.app` ou `.ipa` de desenvolvimento.
- Como é uma build de desenvolvimento, ela não representa exatamente o fluxo de revisão do TestFlight/App Store e pode ter logs, comportamento de depuração e validade de assinatura diferentes.
- O teste direto não substitui a validação do archive, do TestFlight e da submissão final.

Referências: [gerenciar dispositivos no Device Hub](https://developer.apple.com/documentation/xcode/pairing-your-devices-with-your-mac), [executar o app em dispositivos físicos](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices), [ativar o Modo Desenvolvedor](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device) e [visão geral de dispositivos registrados](https://developer.apple.com/help/account/devices/devices-overview).
