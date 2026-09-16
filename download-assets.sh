#!/usr/bin/env bash
# Mirror Digita basketball free-throw assets from cdn-apps.drimify.com (offline).
# Source demo: https://apps.drimify.com/dKQ7aBXw/  (Drimify Basketball Free Throw)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE="https://cdn-apps.drimify.com/prod/basketball"
UA="Mozilla/5.0 (compatible; basketball-local-mirror/1.0)"

mkdir -p "$ROOT/prod/basketball/bundles" \
         "$ROOT/prod/basketball/data/default" \
         "$ROOT/prod/basketball/data/assets/front/sprites" \
         "$ROOT/media/cache"

fetch() {
  local url="$1"
  local out="$2"
  mkdir -p "$(dirname "$out")"
  echo "GET $url"
  curl -fsSL -A "$UA" --connect-timeout 20 --max-time 120 -o "$out" "$url"
  local size
  size=$(wc -c < "$out" | tr -d ' ')
  if [ "$size" -lt 20 ]; then
    echo "FAIL empty: $out" >&2
    rm -f "$out"
    return 1
  fi
  echo "  -> $out ($size bytes)"
}

fetch "$BASE/bundles/index.js"  "$ROOT/prod/basketball/bundles/index.js"
fetch "$BASE/bundles/index.css" "$ROOT/prod/basketball/bundles/index.css"
fetch "$BASE/data/default/config.json" "$ROOT/prod/basketball/data/default/config.json"

SPRITES=(
  howtoplay.png
  assets.json
  assets.png
  basketball.png
  basketball-net.png
  basketball-board.png
  crowd.png
  basketball-hoarding.jpg
  basketball-court.jpg
  logo.png
)

for f in "${SPRITES[@]}"; do
  fetch "$BASE/data/assets/front/sprites/$f" \
    "$ROOT/prod/basketball/data/assets/front/sprites/$f"
done

# Demo shell / marketing art (optional branding)
fetch "https://cdn-apps.drimify.com/upload/media/1/4/0015/64/Basketball-Start-Screen_8639d70bf3805702e4f32d4d4d973a.png" \
  "$ROOT/media/cache/Basketball-Start-Screen.png" || true
fetch "https://cdn-apps.drimify.com/upload/media/1/4/0015/63/background-660776588877_fa762fcb9168359215b09b8dda006a.png" \
  "$ROOT/media/cache/demo-background.png" || true
fetch "https://cdn-apps.drimify.com/favicon.ico" "$ROOT/media/cache/favicon.ico" || true

# iframeResizer (same helper used by Digita embeds)
if [ ! -f "$ROOT/iframeResizer.min.js" ]; then
  fetch "https://cdn.jsdelivr.net/npm/iframe-resizer@4.3.9/js/iframeResizer.min.js" \
    "$ROOT/iframeResizer.min.js" || \
  fetch "https://cdn-apps.drimify.com/prod/app/browser/iframeResizer.min.js" \
    "$ROOT/iframeResizer.min.js" || true
fi

echo ""
echo "Done. Local preview:"
echo "  cd \"$ROOT\" && python3 serve.py"
echo "  open http://127.0.0.1:8766/"
