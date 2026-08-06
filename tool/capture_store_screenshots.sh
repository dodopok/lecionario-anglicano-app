#!/usr/bin/env bash
#
# Captures the App Store screenshots by driving the real app on iOS
# simulators, against the real API, in the three interface languages.
#
# Needs macOS with Xcode and the simulators installed. Run from anywhere:
#
#   ./tool/capture_store_screenshots.sh
#
# The images land in store-assets/app-store/<language>/ and are named
# <device>-<language>-<screen>.png. Review them before uploading: the App
# Store wants what the app really looks like, and this captures whatever the
# API served at the time.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
cd "$repo_root"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This needs macOS with Xcode: the screenshots come from iOS simulators." >&2
  exit 1
fi

command -v xcrun >/dev/null || { echo "xcrun not found. Install Xcode." >&2; exit 1; }
command -v flutter >/dev/null || { echo "flutter not found in PATH." >&2; exit 1; }

# One simulator per App Store Connect slot. Which iPhone slot a listing shows
# varies, and a 6.9" image is rejected outright by a 6.5" slot, so both sizes
# are captured. Override any of them if the simulator is not installed:
#
#   IPHONE_69="iPhone 16 Plus" ./tool/capture_store_screenshots.sh
IPHONE_65="${IPHONE_65:-iPhone 11 Pro Max}"
IPHONE_69="${IPHONE_69:-iPhone 16 Pro Max}"
IPAD_13="${IPAD_13:-iPad Pro 13-inch (M4)}"

output_dir="$repo_root/build/screenshots"
rm -rf "$output_dir"
mkdir -p "$output_dir"

device_udid() {
  local name="$1"
  xcrun simctl list devices available --json \
    | python3 -c "
import json, sys
name = sys.argv[1]
devices = json.load(sys.stdin)['devices']
for runtime in sorted(devices, reverse=True):
    for device in devices[runtime]:
        if device['name'] == name:
            print(device['udid'])
            raise SystemExit
raise SystemExit('not found')
" "$name" 2>/dev/null || true
}

capture() {
  local label="$1" name="$2" udid
  udid="$(device_udid "$name")"

  if [[ -z "$udid" ]]; then
    echo "Simulator '$name' is not installed." >&2
    echo "Pick one from: xcrun simctl list devices available" >&2
    echo "then re-run with, for example: $label=\"iPhone 16 Plus\" $0" >&2
    exit 1
  fi

  echo "==> $label: $name ($udid)"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true

  SCREENSHOT_DIR="$output_dir" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/store_screenshots_test.dart \
    --dart-define=DEVICE="$label" \
    -d "$udid"

  xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
}

capture iphone65 "$IPHONE_65"
capture iphone69 "$IPHONE_69"
capture ipad13 "$IPAD_13"

# Sort what came out into the per-slot folders the store metadata uses.
python3 - "$output_dir" "$repo_root/store-assets/app-store" <<'PY'
import pathlib, shutil, sys

source, destination = (pathlib.Path(argument) for argument in sys.argv[1:3])
languages = {'pt': 'pt-BR', 'en': 'en-US', 'es': 'es'}
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
for folder in sorted(destination.glob('*/*/')):
    sizes = set()
    for image in folder.glob('*.png'):
        header = image.read_bytes()[16:24]
        sizes.add(
            f'{int.from_bytes(header[:4], "big")}x{int.from_bytes(header[4:], "big")}'
        )
    print(f'  {folder.relative_to(destination)}: '
          f'{len(list(folder.glob("*.png")))} images, {", ".join(sorted(sizes))} px')
PY

"$script_dir/verify_app_store_assets.sh"

cat <<'EOF'

Next: in App Store Connect, upload each folder to the slot it is named after.
The listing shows one iPhone slot — 6,5" or 6,9" — and it takes only its own
size; the other folder is there for whichever one that turns out to be.
EOF
