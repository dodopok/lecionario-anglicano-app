# Screenshots para a App Store

Cada idioma tem uma pasta por família de dispositivo, porque o app é universal
e a App Store Connect pede um conjunto para cada uma:

```
pt-BR/iphone/{00-choose,01-home,02-day,03-settings}.png   1290x2796
pt-BR/ipad/{00-choose,01-home,02-reading,03-settings}.png 2064x2752
en-US/...
es/...
```

1. `00-choose` — escolha do LOC, com as capas que a API serve;
2. `01-home` — o dia de hoje e o mês inteiro;
3. `02-day` / `02-reading` — as leituras e a coleta do dia. No iPhone abre
   como bottom sheet; no iPad as leituras já ficam ao lado do mês, então a
   captura mostra uma leitura aberta;
4. `03-settings` — preferências.

## Como refazer

Duas rotas, mesmo destino.

```bash
./tool/render_store_screenshots.sh          # em qualquer máquina
DATE=2026-08-06 ./tool/render_store_screenshots.sh   # fixando o dia
```

Desenha a interface real, com as fontes e os ícones reais, nos tamanhos que a
loja pede, preenchida com respostas capturadas da API de produção. Não precisa
de macOS. O que ela não mostra é a barra de status do iOS — a loja não a exige.

```bash
./tool/capture_store_screenshots.sh         # precisa de macOS com Xcode
IPHONE="iPhone 16 Plus" IPAD="iPad Pro 13-inch (M4)" ./tool/capture_store_screenshots.sh
```

Dirige o app em dois simuladores, um iPhone e um iPad, nos três idiomas. É o
app rodando de verdade, pela pilha do iOS.

`tool/verify_app_store_assets.sh` confere se está tudo no lugar e nos tamanhos
que a loja aceita; `flutter test test/store_assets_test.dart` faz a mesma
conferência dentro da suíte.

## Antes de enviar

Revise as imagens: elas mostram o que a API serviu no momento da captura. Se
um dia vier sem leituras, ou se um LOC não carregar, isso aparece na loja.

O painel de **pré-visualizações** aceita vídeo e é separado das screenshots.
Não é necessário adicionar uma prévia em vídeo para enviar estas imagens.
