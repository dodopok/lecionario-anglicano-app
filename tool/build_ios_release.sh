#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/.."

"$script_dir/verify_ios_release.sh"

build_args=(build ipa --release)

if [[ -n "${API_BASE_URL:-}" ]]; then
  build_args+=(--dart-define="API_BASE_URL=${API_BASE_URL}")
fi

if [[ -n "${APP_INTERNAL_IDENTIFIER:-}" ]]; then
  build_args+=(--dart-define="APP_INTERNAL_IDENTIFIER=${APP_INTERNAL_IDENTIFIER}")
fi

# Beta-only external API key — see lib/data/services/lectionary_api.dart.
# Omit once the backend flips the beta prayer book to app-visible.
if [[ -n "${API_KEY:-}" ]]; then
  build_args+=(--dart-define="API_KEY=${API_KEY}")
fi

if [[ -n "${FLUTTER_BUILD_NAME:-}" ]]; then
  build_args+=(--build-name="$FLUTTER_BUILD_NAME")
fi

if [[ -n "${FLUTTER_BUILD_NUMBER:-}" ]]; then
  build_args+=(--build-number="$FLUTTER_BUILD_NUMBER")
fi

if [[ "${IOS_NO_CODESIGN:-0}" == "1" ]]; then
  build_args+=(--no-codesign)
fi

exec flutter "${build_args[@]}"
