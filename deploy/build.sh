#!/usr/bin/env bash
# Monta public/ com o que vai para o ar. Uso: ./deploy/build.sh gksoftware.com.br
set -euo pipefail

DOMINIO="${1:-}"
if [ -z "$DOMINIO" ]; then
  echo "!! Informe o domínio: ./deploy/build.sh gksoftware.com.br" >&2
  exit 1
fi

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAIDA="$RAIZ/public"

rm -rf "$SAIDA"
mkdir -p "$SAIDA/assets"

# O domínio entra só aqui, na hora de publicar. Assim o fonte não guarda um
# endereço fixo e não há como subir a página com a URL de outro ambiente nas
# meta tags de compartilhamento — que é erro silencioso: a página funciona,
# mas o link no WhatsApp aponta para o lugar errado.
sed "s|__DOMINIO__|$DOMINIO|g" "$RAIZ/landing-scattered.html" > "$SAIDA/index.html"

if grep -q "__DOMINIO__" "$SAIDA/index.html"; then
  echo "!! Sobrou __DOMINIO__ no index.html gerado." >&2
  exit 1
fi

for a in gk-simbolo-positivo.png gk-simbolo-tinta.png icone-32.png icone-180.png icone-512.png og-gk.png; do
  cp "$RAIZ/assets/$a" "$SAIDA/assets/$a"
done

# Toda referência a assets/ precisa existir em public/, senão o deploy sobe com 404.
faltando=0
for ref in $(grep -oE 'assets/[a-z0-9._-]+' "$SAIDA/index.html" | sort -u); do
  [ -f "$SAIDA/$ref" ] || { echo "!! $ref referenciado mas ausente" >&2; faltando=1; }
done
[ "$faltando" -eq 0 ] || exit 1

echo "==> public/ pronto para $DOMINIO"
du -sh "$SAIDA"
find "$SAIDA" -type f | sed "s|$SAIDA|  public|"
