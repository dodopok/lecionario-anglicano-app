# Site do Lecionário Anglicano

Site estático para publicar na Vercel:

- marketing: `https://lecionarioapp.caminhoanglicano.com.br/`
- suporte: `https://lecionarioapp.caminhoanglicano.com.br/suporte/`
- privacidade: `https://lecionarioapp.caminhoanglicano.com.br/privacidade/`

## Antes de publicar

O site já está configurado com o contato público `dev@dodopok.dev`. Revise esse endereço antes do deploy caso o canal oficial mude. `appStoreUrl` pode ser preenchido quando o app estiver publicado na App Store.

## Vercel

1. Importe o repositório na Vercel.
2. Configure `site` como **Root Directory** do projeto.
3. Selecione **Other** como framework.
4. Deixe o build command vazio e use `.` como output directory, se a Vercel solicitar.
5. Adicione o domínio `lecionarioapp.caminhoanglicano.com.br` em **Settings > Domains**.
6. Crie no provedor DNS o registro indicado pela Vercel para esse subdomínio.

O projeto não precisa de variáveis de ambiente nem de um servidor: é HTML, CSS, JavaScript e imagens estáticas. O seletor de idioma funciona no navegador para Português (Brasil), English e Español.

## Verificação local

Na raiz do repositório, execute:

```bash
./tool/verify_site.sh
```

Para uma revisão visual local:

```bash
cd site
python3 -m http.server 4173
```
