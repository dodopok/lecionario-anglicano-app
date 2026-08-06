#!/usr/bin/env bash
#
# Builds the Android App Bundle the Play Console takes for upload.
#
#   ./tool/build_android_release.sh
#
# The version comes from pubspec.yaml — use tool/version.sh to move it — and
# can still be overridden for a one-off build the same way the iOS script
# allows:
#
#   FLUTTER_BUILD_NUMBER=4 ./tool/build_android_release.sh
#
# Play takes a bundle, not an APK: an APK upload is refused for any app first
# published after August 2021. Set ANDROID_BUILD_APK=1 to get an APK anyway,
# which is what a sideloaded test build on a real phone needs.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/.."

if [[ "${ANDROID_BUILD_APK:-0}" == "1" ]]; then
  "$script_dir/verify_android_release.sh"
  build_args=(build apk --release)
else
  REQUIRE_UPLOAD_KEY=1 "$script_dir/verify_android_release.sh"
  build_args=(build appbundle --release)
fi

if [[ -n "${API_BASE_URL:-}" ]]; then
  build_args+=(--dart-define="API_BASE_URL=${API_BASE_URL}")
fi

if [[ -n "${APP_INTERNAL_IDENTIFIER:-}" ]]; then
  build_args+=(--dart-define="APP_INTERNAL_IDENTIFIER=${APP_INTERNAL_IDENTIFIER}")
fi

if [[ -n "${FLUTTER_BUILD_NAME:-}" ]]; then
  build_args+=(--build-name="$FLUTTER_BUILD_NAME")
fi

if [[ -n "${FLUTTER_BUILD_NUMBER:-}" ]]; then
  build_args+=(--build-number="$FLUTTER_BUILD_NUMBER")
fi

exec flutter "${build_args[@]}"
