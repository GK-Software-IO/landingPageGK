#!/usr/bin/env bash
# Envia public/ para a VPS. Uso: ./deploy/sync.sh usuario@host:/opt/gk-landing
set -euo pipefail

DESTINO="${1:-}"
if [ -z "$DESTINO" ]; then
  echo "!! Uso: ./deploy/sync.sh usuario@host:/opt/gk-landing" >&2
  exit 1
fi

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ ! -f "$RAIZ/public/index.html" ]; then
  echo "!! public/ não existe. Rode ./deploy/build.sh <dominio> antes." >&2
  exit 1
fi

# --delete remove da VPS o que saiu do public/. A barra final em "public/" é o
# que faz o rsync copiar o CONTEÚDO da pasta e não a pasta dentro do destino.
echo "==> Enviando para $DESTINO"
rsync -avz --delete --chmod=D755,F644 "$RAIZ/public/" "$DESTINO/"

echo "==> Enviado. Se o Caddy roda em container, recarregue a configuração:"
echo "    docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile"
