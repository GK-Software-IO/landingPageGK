# Deploy da landing GK

A página é HTML estático: sem build, sem runtime, sem banco. São 152 KB —
um `index.html` e seis PNGs. Qualquer servidor web entrega.

## Fluxo

```bash
./deploy/build.sh gksoftware.com.br            # gera public/ com o domínio embutido
./deploy/sync.sh  deploy@VPS:/opt/gk-landing   # envia via rsync
```

Depois, no servidor, garanta que o Caddy sirva esse diretório (abaixo).

## 1. DNS primeiro

O Caddy só emite o certificado se o domínio **já apontar** para o IP da VPS.
Crie o registro A (e o de `www`, se for usar) e confirme antes de recarregar:

```bash
dig +short gksoftware.com.br
```

Se isso não devolver o IP da VPS, pare aqui — o Let's Encrypt vai falhar e o
Caddy entra em backoff, o que atrasa a próxima tentativa.

## 2. Caddy

Acrescente o conteúdo de `Caddyfile.trecho` ao Caddyfile da VPS e recarregue.

**A pegadinha:** se o Caddy roda em container (é o caso do DataCrawler), o
`root` do bloco é o caminho **dentro do container**. Não basta copiar os
arquivos para `/opt/gk-landing` na VPS — é preciso um bind mount no
`docker-compose.yml` do Caddy:

```yaml
services:
  caddy:
    volumes:
      - /opt/gk-landing:/srv/gk-landing:ro
```

Como isso muda o compose, aqui o serviço precisa ser **recriado**, não só
recarregado:

```bash
docker compose up -d caddy
```

Nas vezes seguintes, quando só o conteúdo mudar, o `sync.sh` basta — arquivo
servido de bind mount não exige reload nenhum. Reload só é necessário quando o
**Caddyfile** muda:

```bash
docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
```

Se a configuração nova for inválida, o Caddy recusa e mantém a anterior: o site
continua no ar com a versão antiga, e o comando sai com erro.

## 3. Se a VPS não tiver Caddy

Aí sobe um container só para isto — **desde que as portas 80 e 443 estejam
livres**. Se já houver nginx ou outro Caddy escutando nelas, este compose não
sobe, e o caminho certo é o item 2.

```yaml
name: gk-landing
services:
  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - /opt/gk-landing:/srv/gk-landing:ro
      - caddy_data:/data
      - caddy_config:/config
volumes:
  caddy_data:
  caddy_config:
```

`caddy_data` guarda os certificados — sem esse volume, cada `docker compose up`
pede certificado novo e você bate no limite semanal do Let's Encrypt.

## Conviver com o Condex

Hospedar a landing na VPS do Condex faz as duas coisas dividirem destino:
reboot, disco cheio e um Caddyfile inválido afetam ambas. Para uma landing
institucional isso costuma ser aceitável — só não é um detalhe invisível.

O risco concreto e evitável é o Caddyfile: ele passa a ser um arquivo
compartilhado por dois sites. Valide antes de recarregar:

```bash
docker compose exec -T caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
```

## Fontes externas

A página carrega Archivo, IBM Plex e Instrument Serif do Google Fonts. Funciona
sem nenhum ajuste, mas cria dependência de terceiro e envia o IP do visitante
para o Google. Se isso incomodar, o caminho é baixar os `.woff2`, servir de
`assets/fontes/` e trocar o `<link>` por um `@font-face` local.
