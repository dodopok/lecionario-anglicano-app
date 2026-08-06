#!/usr/bin/env bash
#
# Renders the App Store screenshots without a simulator: the real interface,
# the real fonts and icons, at the pixel sizes the store asks for, filled with
# responses captured from the production API.
#
#   ./tool/render_store_screenshots.sh
#
# Runs anywhere Flutter runs — no macOS, no Xcode. What it cannot show is the
# iOS status bar, and anything the platform draws rather than the app. When
# you have a Mac at hand, tool/capture_store_screenshots.sh drives the app on
# real simulators instead; either one fills store-assets/app-store/.
#
# The day it captures defaults to today. Pin it to a day worth showing:
#
#   DATE=2026-08-06 ./tool/render_store_screenshots.sh

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
cd "$repo_root"

command -v flutter >/dev/null || { echo "flutter not found in PATH." >&2; exit 1; }
command -v curl >/dev/null || { echo "curl not found." >&2; exit 1; }

api="${API_BASE_URL:-https://api.caminhoanglicano.com.br/api/v1}"
internal_id="${APP_INTERNAL_IDENTIFIER:-WxmP9zc51ioDltt41ZRbPzC70fcr0bWa3rhVeIzcFxI=}"
date="${DATE:-$(date +%Y-%m-%d)}"
year="${date%%-*}"
month="$(echo "$date" | cut -d- -f2 | sed 's/^0//')"
day="$(echo "$date" | cut -d- -f3 | sed 's/^0//')"

work="$repo_root/build/store-screenshots"
fixtures="$work/fixtures"
fonts="$work/fonts"
captures="$work/captures"
rm -rf "$captures"
mkdir -p "$fixtures/covers" "$fonts" "$captures"

fetch() {  # fetch <url> <destination>; skips what is already there
  [[ -s "$2" ]] && return 0
  curl -fsSL --retry 3 --retry-delay 2 -o "$2" "$1"
}

api_get() {  # api_get <path-with-query> <destination>
  [[ -s "$2" ]] && return 0
  curl -fsSL --retry 3 --retry-delay 2 \
    -H 'Content-Type: application/json' \
    -H "X-App-Internal-Id: $internal_id" \
    -o "$2" "$api$1"
}

echo '==> Fonts'
fetch 'https://raw.githubusercontent.com/google/fonts/main/ofl/cormorantgaramond/CormorantGaramond%5Bwght%5D.ttf' "$fonts/cg.ttf"
fetch 'https://raw.githubusercontent.com/google/fonts/main/ofl/sourcesans3/SourceSans3%5Bwght%5D.ttf' "$fonts/ss.ttf"

echo "==> Lectionary for $date"
api_get '/prayer_books' "$fixtures/prayer_books.json"

# One prayer book per interface language, matching test/store_capture_test.dart.
books_pt='loc_2015'
books_en='loc_2019_en'
books_es='loc_2019_es'

for language in pt en es; do
  book="books_$language"
  code="${!book}"
  preferences="$(python3 -c '
import json, sys, urllib.parse
print(urllib.parse.quote(json.dumps({"prayer_book_code": sys.argv[1]})))' "$code")"
  api_get "/calendar/$year/$month?preferences=$preferences" \
    "$fixtures/month-$language.json"
  api_get "/calendar/$year/$month/$day?preferences=$preferences" \
    "$fixtures/day-$language.json"

  # The Bible list is asked for by the book's own language tag, not by the
  # interface language: `pt-BR`, not `pt`. Asking with the wrong one answers
  # 200 with an empty list, and the preference silently disappears from the
  # screenshot — so take the tag from the book itself, as the app does.
  book_language="$(python3 -c '
import json, sys
payload = json.load(open(sys.argv[1]))
books = payload["data"] if isinstance(payload, dict) else payload
print(next(b["language"] for b in books if b["code"] == sys.argv[2]))' \
    "$fixtures/prayer_books.json" "$code")"
  api_get "/bible_versions?language=$book_language" \
    "$fixtures/bibles-$language.json"
done

echo '==> Covers'
python3 - "$fixtures/prayer_books.json" > "$work/covers.txt" <<'PY'
import json, sys
payload = json.load(open(sys.argv[1]))
books = payload['data'] if isinstance(payload, dict) else payload
for book in books:
    for key in ('thumbnail_url', 'image_url'):
        if book.get(key):
            print(book[key])
            break
PY
while read -r url; do
  fetch "$url" "$fixtures/covers/$(basename "$url")"
done < "$work/covers.txt"

echo '==> Rendering'
icon_font="$(dirname "$(dirname "$(command -v flutter)")")/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
if [[ ! -f "$icon_font" ]]; then
  icon_font="$(find "$(dirname "$(command -v flutter)")/.." -name MaterialIcons-Regular.otf 2>/dev/null | head -1)"
fi
[[ -f "$icon_font" ]] || {
  echo "MaterialIcons-Regular.otf not found. Run 'flutter precache' first." >&2
  exit 1
}

FIXTURE_DIR="$fixtures" FONT_DIR="$fonts" ICON_FONT="$icon_font" \
CAPTURE_DIR="$captures" \
  flutter test test/store_capture_test.dart \
    --tags capture --run-skipped --update-goldens

python3 - "$captures" "$repo_root/store-assets/app-store" <<'PY'
import pathlib, shutil, sys

source, destination = (pathlib.Path(argument) for argument in sys.argv[1:3])
languages = {'pt': 'pt-BR', 'en': 'en-US', 'es': 'es'}
# One folder per App Store Connect slot, named after the slot.
devices = {'iphone65': 'iphone-6.5', 'iphone69': 'iphone-6.9',
           'ipad13': 'ipad-13'}

count = 0
for image in sorted(source.glob('*.png')):
    device, language, screen = image.stem.split('-', 2)
    folder = destination / languages[language] / devices[device]
    folder.mkdir(parents=True, exist_ok=True)
    shutil.copy2(image, folder / f'{screen}.png')
    count += 1

print(f'\n{count} screenshots in {destination}')
PY

"$script_dir/verify_app_store_assets.sh"
