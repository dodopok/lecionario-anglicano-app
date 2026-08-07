#!/usr/bin/env bash
#
# Checks the Play listing's graphics are present, in every language, and shaped
# the way the Play Console accepts them — before an upload finds out.
#
# The launcher icons that go inside the bundle are a different set, checked by
# tool/verify_android_release.sh.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

python3 - "$repo_root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
store = root / 'store-assets' / 'play-store'
languages = ['pt-BR', 'en-US', 'es']
slots = ['phone', 'tablet-7', 'tablet-10']

# Play does not name exact pixel sizes the way App Store Connect does. It
# gives rules, and the rules are what a rejection quotes back:
#   * every side between 320 and 3840 px;
#   * no more than twice as tall as it is wide, or as wide as it is tall;
#   * at least two per slot — but four, each at least 1080 px on its long
#     side, is the bar for the app to be shown on the store's own featured
#     surfaces, and the renderer produces exactly that.
MINIMUM_SIDE = 320
MAXIMUM_SIDE = 3840
MAXIMUM_ASPECT = 2.0
WANTED_PER_SLOT = 4
FEATURED_LONG_SIDE = 1080
MAXIMUM_BYTES = 8 * 1024 * 1024


def size_of(png: pathlib.Path) -> tuple[int, int]:
    header = png.read_bytes()[:24]
    if header[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'{png} is not a PNG')
    return (
        int.from_bytes(header[16:20], 'big'),
        int.from_bytes(header[20:24], 'big'),
    )


def has_alpha(png: pathlib.Path) -> bool:
    return png.read_bytes()[25] in (4, 6)


problems = []

# The store listing icon: one for the whole listing, not one per language.
icon = store / 'icon.png'
if not icon.is_file():
    problems.append('icon.png: missing — run ./tool/generate_android_assets.py')
else:
    if size_of(icon) != (512, 512):
        width, height = size_of(icon)
        problems.append(f'icon.png: {width}x{height} px, and Play asks for 512x512')
    if not has_alpha(icon):
        problems.append('icon.png: Play asks for a 32-bit PNG, and this one '
                        'has no alpha channel')
    if icon.stat().st_size > 1024 * 1024:
        problems.append('icon.png: over the 1 MB the console accepts')

for language in languages:
    folder = store / language
    if not folder.is_dir():
        problems.append(f'{language}: nothing at all — run '
                        './tool/render_store_screenshots.sh')
        continue

    # The banner above the listing. Required to publish, one per language,
    # and the one graphic Play refuses with an alpha channel.
    graphic = folder / 'feature-graphic.png'
    if not graphic.is_file():
        problems.append(f'{language}/feature-graphic.png: missing, and Play '
                        'will not publish a listing without one')
    else:
        if size_of(graphic) != (1024, 500):
            width, height = size_of(graphic)
            problems.append(
                f'{language}/feature-graphic.png: {width}x{height} px, and '
                'Play asks for exactly 1024x500'
            )
        if has_alpha(graphic):
            problems.append(
                f'{language}/feature-graphic.png: has an alpha channel, and '
                'Play takes the feature graphic without one'
            )

    for slot in slots:
        images = sorted((folder / slot).glob('*.png'))
        if len(images) < WANTED_PER_SLOT:
            problems.append(
                f'{language}/{slot}: {len(images)} screenshot(s), wanted '
                f'{WANTED_PER_SLOT} — run ./tool/render_store_screenshots.sh'
            )

        for image in images:
            width, height = size_of(image)
            short, long = min(width, height), max(width, height)
            where = image.relative_to(root)

            if short < MINIMUM_SIDE or long > MAXIMUM_SIDE:
                problems.append(
                    f'{where}: {width}x{height} px is outside the '
                    f'{MINIMUM_SIDE}–{MAXIMUM_SIDE} px Play accepts'
                )
            if long > short * MAXIMUM_ASPECT:
                problems.append(
                    f'{where}: {width}x{height} px is more than twice as long '
                    'as it is wide, which Play rejects'
                )
            if long < FEATURED_LONG_SIDE:
                problems.append(
                    f'{where}: {width}x{height} px is under the '
                    f'{FEATURED_LONG_SIDE} px Play wants before it will show '
                    'the app on its featured surfaces'
                )
            if image.stat().st_size > MAXIMUM_BYTES:
                problems.append(f'{where}: over the 8 MB per screenshot')

    loose = sorted(
        image for image in folder.glob('*.png')
        if image.name != 'feature-graphic.png'
    )
    if loose:
        problems.append(
            f'{language}: {len(loose)} image(s) sit outside a slot folder, so '
            'nothing checks their size'
        )

    for extra in sorted(entry for entry in folder.iterdir()
                        if entry.is_dir() and entry.name not in slots):
        problems.append(f'{extra.relative_to(root)}: not a slot Play offers')

if problems:
    print('Play listing graphics are not ready:', file=sys.stderr)
    for problem in problems:
        print(f'  - {problem}', file=sys.stderr)
    raise SystemExit(1)

print('Play listing graphics are present for every slot in every language, '
      'within the sizes the console accepts.')
PY
