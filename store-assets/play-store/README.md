# Gráficos da Google Play

O ícone da listagem é um só para o app inteiro. O resto tem uma pasta por
idioma, e dentro dela uma pasta por *slot* da ficha da loja:

```
icon.png                                                        512x512
pt-BR/feature-graphic.png                                      1024x500
pt-BR/phone/{00-choose,01-home,02-day,03-settings}.png         1080x1920
pt-BR/tablet-7/{00-choose,01-home,02-day,03-settings}.png      1200x1920
pt-BR/tablet-10/{00-choose,01-home,02-reading,03-settings}.png 1600x2560
en-US/...
es/...
```

1. `00-choose` — escolha do LOC, com as capas que a API serve;
2. `01-home` — o dia de hoje e o mês inteiro;
3. `02-day` / `02-reading` — as leituras e a coleta do dia. No celular e no
   tablet de 7" abre como bottom sheet; no de 10" as leituras já ficam ao lado
   do mês, então a captura mostra uma leitura aberta;
4. `03-settings` — preferências.

## O que o Play aceita

Ao contrário da App Store, o Play não pede tamanhos exatos para as
screenshots: pede regras, e são elas que aparecem numa recusa.

- todo lado entre 320 e 3840 px;
- nunca mais que o dobro de comprimento em relação à largura — é o que impede
  reaproveitar as imagens de iPhone, que são mais compridas que isso;
- no mínimo duas por slot; quatro com pelo menos 1080 px no lado maior é o que
  o Play quer antes de mostrar o app nas seções que ele destaca;
- até 8 MB cada.

O **gráfico de destaque** é o mais rígido: exatamente 1024×500 e sem canal
alfa. Sem ele a ficha não sai do rascunho. O **ícone de 512×512** é o
contrário do da App Store — aqui o alfa é pedido, e o arquivo tem que ser um
PNG de 32 bits.

As screenshots de tablet não impedem a publicação, mas sem elas o Play marca o
app como não otimizado para telas grandes e deixa de recomendá-lo em tablets e
ChromeOS.

## Como refazer

```bash
STORE=play ./tool/render_store_screenshots.sh              # só a Play
STORE=play DATE=2026-08-06 ./tool/render_store_screenshots.sh   # fixando o dia
./tool/render_store_screenshots.sh                         # as duas lojas
```

Desenha a interface real, com as fontes e os ícones reais, nos tamanhos que a
loja pede, preenchida com respostas capturadas da API de produção. Roda em
qualquer máquina com Flutter — não precisa de emulador nem do SDK do Android.
O que ela não mostra é a barra de status do Android.

O ícone de 512×512 sai de outro script, a partir do mesmo ícone de 1024 px que
o iOS publica:

```bash
./tool/generate_android_assets.py
```

`tool/verify_play_store_assets.sh` confere se está tudo no lugar e dentro das
regras; `flutter test test/play_store_assets_test.dart` faz a mesma conferência
dentro da suíte, para cada idioma que já tiver imagens.

## Antes de enviar

Revise as imagens: elas mostram o que a API serviu no momento da captura. Se
um dia vier sem leituras, ou se um LOC não carregar, isso aparece na loja.

O vídeo promocional é um campo à parte, opcional, e não é necessário para
publicar.
