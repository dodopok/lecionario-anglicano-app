# Screenshots para a App Store

Cada idioma tem uma pasta por *slot* da App Store Connect, com o nome do slot.
O app é universal, então a loja pede um conjunto para cada família — e cada
slot aceita só os tamanhos dele:

```
pt-BR/iphone-6.5/{00-choose,01-home,02-day,03-settings}.png   1284x2778
pt-BR/iphone-6.9/{00-choose,01-home,02-day,03-settings}.png   1290x2796
pt-BR/ipad-13/{00-choose,01-home,02-reading,03-settings}.png  2064x2752
en-US/...
es/...
```

**O slot de iPhone que a sua listagem mostra é um só** — 6,5" ou 6,9" — e ele
recusa a imagem do outro: mandar 1290x2796 para o slot de 6,5" dá "As
dimensões de uma ou mais capturas de tela estão incorretas". Por isso os dois
tamanhos ficam prontos aqui; suba o que a tela pedir.

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
IPHONE_69="iPhone 16 Plus" ./tool/capture_store_screenshots.sh
```

Dirige o app em um simulador por slot, nos três idiomas. É o app rodando de
verdade, pela pilha do iOS. Os simuladores padrão são `iPhone 11 Pro Max`
(6,5"), `iPhone 16 Pro Max` (6,9") e `iPad Pro 13-inch (M4)`; sobrescreva com
`IPHONE_65`, `IPHONE_69` e `IPAD_13`.

`tool/verify_app_store_assets.sh` confere se está tudo no lugar e nos tamanhos
que a loja aceita; `flutter test test/store_assets_test.dart` faz a mesma
conferência dentro da suíte.

## Antes de enviar

Revise as imagens: elas mostram o que a API serviu no momento da captura. Se
um dia vier sem leituras, ou se um LOC não carregar, isso aparece na loja.

O painel de **pré-visualizações** aceita vídeo e é separado das screenshots.
Não é necessário adicionar uma prévia em vídeo para enviar estas imagens.
