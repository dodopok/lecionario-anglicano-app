#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

require_file() {
  local path="$1"
  if [[ ! -f "$repo_root/$path" ]]; then
    echo "Missing required release file: $path" >&2
    exit 1
  fi
}

check_png_size() {
  local relative_path="$1"
  local expected_size="$2"
  local actual_size

  actual_size="$(sips -g pixelWidth -g pixelHeight "$repo_root/$relative_path" 2>/dev/null | awk '/pixelWidth/ {width=$2} /pixelHeight/ {height=$2} END {print width "x" height}')"
  if [[ "$actual_size" != "$expected_size" ]]; then
    echo "Unexpected PNG size for $relative_path: $actual_size (expected $expected_size)" >&2
    exit 1
  fi
}

icon_root="ios/Runner/Assets.xcassets/AppIcon.appiconset"
launch_root="ios/Runner/Assets.xcassets/LaunchImage.imageset"

require_file "ios/Runner/Info.plist"
require_file "ios/Runner/PrivacyInfo.xcprivacy"
require_file "ios/Runner.xcodeproj/project.pbxproj"
require_file "ios/Runner.xcworkspace/contents.xcworkspacedata"
require_file "tool/build_ios_release.sh"
require_file "$icon_root/Contents.json"
require_file "$launch_root/Contents.json"

if [[ ! -x "$repo_root/tool/build_ios_release.sh" ]]; then
  echo "Release build script is not executable: tool/build_ios_release.sh" >&2
  exit 1
fi

check_png_size "$icon_root/Icon-App-20x20@1x.png" "20x20"
check_png_size "$icon_root/Icon-App-20x20@2x.png" "40x40"
check_png_size "$icon_root/Icon-App-20x20@3x.png" "60x60"
check_png_size "$icon_root/Icon-App-29x29@1x.png" "29x29"
check_png_size "$icon_root/Icon-App-29x29@2x.png" "58x58"
check_png_size "$icon_root/Icon-App-29x29@3x.png" "87x87"
check_png_size "$icon_root/Icon-App-40x40@1x.png" "40x40"
check_png_size "$icon_root/Icon-App-40x40@2x.png" "80x80"
check_png_size "$icon_root/Icon-App-40x40@3x.png" "120x120"
check_png_size "$icon_root/Icon-App-60x60@2x.png" "120x120"
check_png_size "$icon_root/Icon-App-60x60@3x.png" "180x180"
check_png_size "$icon_root/Icon-App-76x76@1x.png" "76x76"
check_png_size "$icon_root/Icon-App-76x76@2x.png" "152x152"
check_png_size "$icon_root/Icon-App-83.5x83.5@2x.png" "167x167"
check_png_size "$icon_root/Icon-App-1024x1024@1x.png" "1024x1024"
check_png_size "$launch_root/LaunchImage.png" "168x185"
check_png_size "$launch_root/LaunchImage@2x.png" "336x370"
check_png_size "$launch_root/LaunchImage@3x.png" "504x555"

plutil -lint "$repo_root/ios/Runner/Info.plist" >/dev/null
plutil -lint "$repo_root/ios/Runner/PrivacyInfo.xcprivacy" >/dev/null
plutil -lint "$repo_root/ios/Runner.xcodeproj/project.pbxproj" >/dev/null

require_match() {
  local pattern="$1"
  local path="$2"

  if ! grep -Eq "$pattern" "$repo_root/$path"; then
    echo "Release check failed: $path does not match $pattern" >&2
    exit 1
  fi
}

require_plist_value() {
  local key="$1"
  local expected="$2"
  local path="$3"
  local actual

  actual="$(plutil -extract "$key" raw "$repo_root/$path" 2>/dev/null || true)"
  if [[ "$actual" != "$expected" ]]; then
    echo "Release check failed: $path $key is '$actual' (expected '$expected')" >&2
    exit 1
  fi
}

require_plist_value "CFBundleDisplayName" "Lecionário Anglicano" "ios/Runner/Info.plist"
require_plist_value "MinimumOSVersion" "15.0" "ios/Flutter/AppFrameworkInfo.plist"
require_match 'ITSAppUsesNonExemptEncryption</key>' "ios/Runner/Info.plist"
require_match 'PRODUCT_BUNDLE_IDENTIFIER = br\.com\.caminhoanglicano\.lecionarioanglicano;' "ios/Runner.xcodeproj/project.pbxproj"
require_match 'IPHONEOS_DEPLOYMENT_TARGET = 15\.0;' "ios/Runner.xcodeproj/project.pbxproj"
if grep -Eq 'IPHONEOS_DEPLOYMENT_TARGET = 1[0-4]\.' "$repo_root/ios/Runner.xcodeproj/project.pbxproj"; then
  echo "The iOS deployment target must be 15.0 or newer." >&2
  exit 1
fi
require_match 'PrivacyInfo\.xcprivacy in Resources' "ios/Runner.xcodeproj/project.pbxproj"
require_match 'group:Pods/Pods\.xcodeproj' "ios/Runner.xcworkspace/contents.xcworkspacedata"

echo "iOS release configuration, privacy manifest, icons and launch assets are valid."
