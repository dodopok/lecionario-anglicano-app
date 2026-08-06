#!/usr/bin/env bash
#
# Checks the App Store screenshots are present, for both device families the
# app ships for, at a size the store accepts.
#
# The app icons are checked by `flutter test test/app_icon_test.dart`, which
# runs anywhere; an icon with an alpha channel is rejected at upload.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

python3 - "$repo_root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
store = root / 'store-assets' / 'app-store'
languages = ['pt-BR', 'en-US', 'es']

# One folder per App Store Connect slot, and the sizes that slot accepts.
# Which iPhone slot a listing offers varies, and a 6.9" image is rejected by a
# 6.5" slot, so both are kept.
accepted = {
    'iphone-6.5': {(1242, 2688), (1284, 2778), (2688, 1242), (2778, 1284)},
    'iphone-6.9': {(1290, 2796), (1320, 2868), (2796, 1290), (2868, 1320)},
    'ipad-13': {(2064, 2752), (2048, 2732), (2752, 2064), (2732, 2048)},
}


def size_of(png: pathlib.Path) -> tuple[int, int]:
    header = png.read_bytes()[16:24]
    return (
        int.from_bytes(header[:4], 'big'),
        int.from_bytes(header[4:], 'big'),
    )


problems = []
for language in languages:
    folder = store / language
    if not folder.is_dir():
        problems.append(f'{language}: no screenshots at all')
        continue

    for device, sizes in accepted.items():
        images = sorted((folder / device).glob('*.png'))
        if not images:
            problems.append(
                f'{language}/{device}: missing — run '
                './tool/render_store_screenshots.sh'
            )
            continue
        for image in images:
            size = size_of(image)
            if size not in sizes:
                problems.append(
                    f'{image.relative_to(root)}: {size[0]}x{size[1]} px is not '
                    f'a size the {device} slot accepts'
                )

    loose = sorted(folder.glob('*.png'))
    if loose:
        problems.append(
            f'{language}: {len(loose)} screenshot(s) sit outside a slot '
            'folder, so nothing checks their size'
        )

    for extra in sorted(p for p in folder.iterdir()
                        if p.is_dir() and p.name not in accepted):
        problems.append(
            f'{extra.relative_to(root)}: not a slot the store offers'
        )

if problems:
    print('App Store screenshots are not ready:', file=sys.stderr)
    for problem in problems:
        print(f'  - {problem}', file=sys.stderr)
    raise SystemExit(1)

print('App Store screenshots are present for every slot in every language, '
      'at accepted sizes.')
PY
