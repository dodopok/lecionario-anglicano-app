# Screenshots para a App Store

As imagens são capturadas do app real, rodando contra a API real, por
`tool/capture_store_screenshots.sh`. O script dirige o app em dois simuladores
— um iPhone e um iPad — nos três idiomas da interface, e organiza o resultado
aqui.

```bash
./tool/capture_store_screenshots.sh
```

Precisa de macOS com Xcode. Se os simuladores padrão não estiverem instalados:

```bash
IPHONE="iPhone 16 Plus" IPAD="iPad Pro 13-inch (M4)" ./tool/capture_store_screenshots.sh
```

`tool/verify_app_store_assets.sh` confere se está tudo no lugar e nos tamanhos
que a loja aceita.

## Estrutura

Cada idioma tem uma pasta por família de dispositivo, porque o app é universal
e a App Store Connect pede um conjunto para cada uma:

```
pt-BR/iphone/{00-choose,01-home,02-day,03-settings}.png
pt-BR/ipad/{00-choose,01-home,02-day,03-settings}.png
en-US/...
es/...
```

1. `00-choose` — escolha do LOC, com as capas retornadas pela API;
2. `01-home` — o dia de hoje e o mês inteiro;
3. `02-day` — as leituras e a coleta do dia;
4. `03-settings` — preferências.

## Antes de enviar

Revise as imagens: elas mostram o que a API serviu no momento da captura. Se
um dia vier sem leituras, ou se um LOC não carregar, isso aparece na loja.

As imagens soltas na raiz de cada idioma (`01-home-pt.png` e afins) são de uma
interface anterior, com a visão por semana que não existe mais. Apague-as
quando as pastas `iphone/` e `ipad/` estiverem preenchidas.

O painel de **pré-visualizações** aceita vídeo e é separado das screenshots.
Não é necessário adicionar uma prévia em vídeo para enviar estas imagens.
