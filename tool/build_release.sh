#!/usr/bin/env bash
#
# Builds Android and iOS in one shot, sharing the same build number — see
# docs/versioning.md.
#
#   ./tool/build_release.sh
#
# Every env var the platform scripts accept is forwarded as-is, since they
# are just ordinary environment variables for this process' children:
#
#   API_KEY=estevao_xxxx ./tool/build_release.sh
#   API_KEY=estevao_xxxx FLUTTER_BUILD_NUMBER=4 ./tool/build_release.sh
#   API_KEY=estevao_xxxx ANDROID_BUILD_APK=1 IOS_NO_CODESIGN=1 ./tool/build_release.sh
#
# The iOS build needs Xcode, so it only makes sense on macOS. Set IOS_SKIP=1
# to build Android alone from a machine that doesn't have Xcode.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Android"
"$script_dir/build_android_release.sh"

if [[ "${IOS_SKIP:-0}" == "1" ]]; then
  echo "==> iOS skipped (IOS_SKIP=1)"
else
  echo "==> iOS"
  "$script_dir/build_ios_release.sh"
fi
