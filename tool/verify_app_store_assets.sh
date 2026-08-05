#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

check_png_size() {
  local relative_path="$1"
  local expected_size="1284x2778"
  local actual_size

  actual_size="$(sips -g pixelWidth -g pixelHeight "$repo_root/$relative_path" 2>/dev/null | awk '/pixelWidth/ {width=$2} /pixelHeight/ {height=$2} END {print width "x" height}')"
  if [[ "$actual_size" != "$expected_size" ]]; then
    echo "Unexpected screenshot size for $relative_path: $actual_size (expected $expected_size)" >&2
    exit 1
  fi
}

required_files=(
  "store-assets/app-store/pt-BR/00-escolha-loc-pt.png"
  "store-assets/app-store/pt-BR/01-home-pt.png"
  "store-assets/app-store/pt-BR/02-mes-pt.png"
  "store-assets/app-store/en-US/00-choose-prayer-book-en.png"
  "store-assets/app-store/en-US/01-home-en.png"
  "store-assets/app-store/en-US/02-month-en.png"
  "store-assets/app-store/es/00-elige-loc-es.png"
  "store-assets/app-store/es/01-home-es.png"
  "store-assets/app-store/es/02-month-es.png"
)

for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$repo_root/$relative_path" ]]; then
    echo "Missing App Store screenshot: $relative_path" >&2
    exit 1
  fi
  check_png_size "$relative_path"
done

if [[ -f "$repo_root/store-assets/app-store/pt-BR/03-configuracoes-pt.png" ]]; then
  check_png_size "store-assets/app-store/pt-BR/03-configuracoes-pt.png"
fi

echo "App Store screenshots are present and use 1284x2778 px."
