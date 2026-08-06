#!/usr/bin/env bash
#
# Checks the Android side of the project is in the shape the Play Console
# expects, before a bundle is built rather than after it is rejected.
#
#   ./tool/verify_android_release.sh
#
# The upload key is only demanded when a build is actually going to be
# uploaded, which is how tool/build_android_release.sh calls it:
#
#   REQUIRE_UPLOAD_KEY=1 ./tool/verify_android_release.sh

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

application_id="br.com.caminhoanglicano.lecionario_anglicano"
# The API level Play enforces for new releases. Google raises it every August;
# raise it here and in android/app/build.gradle.kts together.
minimum_target_sdk=35

require_file() {
  local path="$1"
  if [[ ! -f "$repo_root/$path" ]]; then
    echo "Missing required release file: $path" >&2
    exit 1
  fi
}

require_match() {
  local pattern="$1"
  local path="$2"

  if ! grep -Eq "$pattern" "$repo_root/$path"; then
    echo "Release check failed: $path does not match $pattern" >&2
    exit 1
  fi
}

gradle="android/app/build.gradle.kts"
manifest="android/app/src/main/AndroidManifest.xml"

require_file "$gradle"
require_file "$manifest"
require_file "android/key.properties.example"
require_file "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
require_file "android/app/src/main/res/values/ic_launcher_background.xml"
require_file "tool/build_android_release.sh"

if [[ ! -x "$repo_root/tool/build_android_release.sh" ]]; then
  echo "Release build script is not executable: tool/build_android_release.sh" >&2
  exit 1
fi

# Play ties the listing to the application id at the first upload and never
# lets it change, so a typo here is permanent.
require_match "applicationId = \"${application_id//./\\.}\"" "$gradle"
require_match "namespace = \"${application_id//./\\.}\"" "$gradle"
require_match "targetSdk = maxOf\(flutter\.targetSdkVersion, $minimum_target_sdk\)" "$gradle"

# Both come from pubspec.yaml. A hard-coded versionCode is the classic way to
# upload a bundle Play rejects for not having moved.
require_match 'versionCode = flutter\.versionCode' "$gradle"
require_match 'versionName = flutter\.versionName' "$gradle"

# The release build has to be able to reach a real upload key at all.
require_match 'signingConfigs.getByName\("release"\)' "$gradle"

if [[ "${REQUIRE_UPLOAD_KEY:-0}" == "1" ]]; then
  key_properties="$repo_root/android/key.properties"
  if [[ ! -f "$key_properties" ]]; then
    echo "android/key.properties is missing, so the bundle would be signed" >&2
    echo "with the debug key and rejected on upload. Copy" >&2
    echo "android/key.properties.example and fill in the upload key." >&2
    exit 1
  fi

  for property in storePassword keyPassword keyAlias storeFile; do
    value="$(grep -E "^$property=" "$key_properties" | cut -d= -f2- || true)"
    if [[ -z "$value" ]]; then
      echo "android/key.properties has no value for $property." >&2
      exit 1
    fi
    if [[ "$property" == "storeFile" && ! -f "$value" ]]; then
      echo "The keystore named in android/key.properties is not there: $value" >&2
      exit 1
    fi
  done
fi

# Every permission the app asks for is one more thing the listing has to
# justify, and the release manifest should ask for nothing but the network.
declared="$(grep -oE 'android:name="android\.permission\.[A-Z_]+"' "$repo_root/$manifest" \
  | sed 's/.*permission\.//; s/"//' | sort -u)"
if [[ "$declared" != "INTERNET" ]]; then
  echo "The release manifest declares permissions beyond INTERNET:" >&2
  echo "$declared" >&2
  exit 1
fi

python3 - "$repo_root" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
resources = root / 'android/app/src/main/res'
problems = []

# 48dp for the launcher icon, 108dp for the adaptive icon's layers.
expected = {
    'mdpi': (48, 108),
    'hdpi': (72, 162),
    'xhdpi': (96, 216),
    'xxhdpi': (144, 324),
    'xxxhdpi': (192, 432),
}


def size_of(png: pathlib.Path) -> tuple[int, int]:
    header = png.read_bytes()[:24]
    if header[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'{png} is not a PNG')
    return (
        int.from_bytes(header[16:20], 'big'),
        int.from_bytes(header[20:24], 'big'),
    )


declared = re.search(
    r'<color name="ic_launcher_background">(#[0-9A-Fa-f]{6})</color>',
    (resources / 'values/ic_launcher_background.xml').read_text(),
)
if declared is None:
    problems.append('values/ic_launcher_background.xml declares no colour')

for density, (launcher, adaptive) in expected.items():
    folder = resources / f'mipmap-{density}'
    for name, side in (('ic_launcher.png', launcher),
                       ('ic_launcher_foreground.png', adaptive)):
        image = folder / name
        if not image.is_file():
            problems.append(
                f'mipmap-{density}/{name}: missing — run '
                './tool/generate_android_assets.py'
            )
            continue
        if size_of(image) != (side, side):
            width, height = size_of(image)
            problems.append(
                f'mipmap-{density}/{name}: {width}x{height} px, '
                f'expected {side}x{side}'
            )

# The stock Flutter logo is what a fresh project ships with, and it is easy to
# leave behind. It has a white corner; the app's own mark has the icon's
# background colour there, the one the adaptive icon's background layer uses.
if declared is not None:
    background = tuple(
        int(declared.group(1)[i:i + 2], 16) for i in (1, 3, 5)
    )
    icon = resources / 'mipmap-xxxhdpi/ic_launcher.png'
    if icon.is_file():
        sys.path.insert(0, str(root / 'tool'))
        from png import Image  # noqa: E402

        corner = tuple(Image.load(icon).pixels[0:3])
        if corner != background:
            problems.append(
                f'mipmap-xxxhdpi/ic_launcher.png starts on '
                f'#{corner[0]:02X}{corner[1]:02X}{corner[2]:02X}, not the '
                f'icon background {declared.group(1)} — is this still the '
                'default Flutter logo? Run ./tool/generate_android_assets.py'
            )

if problems:
    print('Android icons are not ready:', file=sys.stderr)
    for problem in problems:
        print(f'  - {problem}', file=sys.stderr)
    raise SystemExit(1)
PY

echo "Android release configuration, permissions and launcher icons are valid."
