#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

required_files=(
  "site/index.html"
  "site/suporte/index.html"
  "site/privacidade/index.html"
  "site/config.js"
  "site/assets/site.js"
  "site/assets/styles.css"
  "site/assets/icon.png"
  "site/assets/app-home.png"
  "site/assets/app-home-en.png"
  "site/assets/app-home-es.png"
  "site/vercel.json"
  "site/robots.txt"
  "site/sitemap.xml"
)

for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$repo_root/$relative_path" ]]; then
    echo "Missing site file: $relative_path" >&2
    exit 1
  fi
done

node --check "$repo_root/site/assets/site.js"
node -e "const fs = require('fs'); JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));" "$repo_root/site/vercel.json"

for page in "$repo_root/site/index.html" "$repo_root/site/suporte/index.html" "$repo_root/site/privacidade/index.html"; do
  rg -q 'assets/styles\.css' "$page"
  rg -q 'assets/site\.js' "$page"
  rg -q 'config\.js' "$page"
done

if ! rg -q "lecionarioapp\.caminhoanglicano\.com\.br" "$repo_root/site"; then
  echo "Site domain is missing from deployment files." >&2
  exit 1
fi

echo "Marketing, support and privacy site files are valid."
