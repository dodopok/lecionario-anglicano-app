#!/usr/bin/env python3
"""Draws the Android launcher icons and the Play listing icon from the mark
the app already ships on iOS.

    ./tool/generate_android_assets.py

The source is the 1024 px App Store icon, so the two stores cannot drift
apart: whatever is regenerated for iOS is what Android gets. Everything here
runs on the standard library alone — see tool/png.py — because the Android
assets are the ones most likely to be rebuilt on a machine that is not a Mac.

Three things come out of it:

  * the legacy square launcher icons, used below Android 8;
  * the adaptive icon's foreground layer, plus the background colour it sits
    on, used from Android 8 up;
  * the 512 px icon the Play Console asks for on the store listing.
"""

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

from png import Image  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png'
RESOURCES = ROOT / 'android/app/src/main/res'
PLAY = ROOT / 'store-assets/play-store'

# A launcher icon is 48dp; the adaptive icon hands over a 108dp layer of which
# only the middle 72dp is ever shown, and only the middle 66dp is guaranteed.
DENSITIES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
LAUNCHER_DP = 48
ADAPTIVE_DP = 108

# How much of the 108dp foreground the full square mark takes. At 0.75 the
# square covers 81dp, so it still runs past the 72dp the launcher shows
# whatever mask it uses, while the medallion inside lands near 55dp — close to
# the proportion the icon has on iOS, and well inside the 66dp safe zone.
MARK_SCALE = 0.75


def main() -> int:
    if not SOURCE.exists():
        print(f'Source icon missing: {SOURCE.relative_to(ROOT)}', file=sys.stderr)
        return 1

    source = Image.load(SOURCE)
    if source.width != source.height:
        print(f'The source icon is {source.width}x{source.height}, not square.',
              file=sys.stderr)
        return 1

    for density, factor in DENSITIES.items():
        folder = RESOURCES / f'mipmap-{density}'
        folder.mkdir(parents=True, exist_ok=True)

        launcher = round(LAUNCHER_DP * factor)
        source.resized(launcher, launcher).save(folder / 'ic_launcher.png')
        print(f'  mipmap-{density}/ic_launcher.png            {launcher}x{launcher}')

        adaptive = round(ADAPTIVE_DP * factor)
        source.centred_on(adaptive, MARK_SCALE).save(
            folder / 'ic_launcher_foreground.png'
        )
        print(f'  mipmap-{density}/ic_launcher_foreground.png {adaptive}x{adaptive}')

    # The background layer is a flat fill of the colour the mark already sits
    # on, so the seam between the two layers never shows through a mask.
    background = _corner_colour(source)
    (RESOURCES / 'values').mkdir(parents=True, exist_ok=True)
    (RESOURCES / 'values/ic_launcher_background.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<!-- Written by tool/generate_android_assets.py, sampled from the app\n'
        '     icon so the adaptive icon\'s two layers stay the same colour. -->\n'
        '<resources>\n'
        f'    <color name="ic_launcher_background">{background}</color>\n'
        '</resources>\n'
    )
    print(f'  values/ic_launcher_background.xml         {background}')

    PLAY.mkdir(parents=True, exist_ok=True)
    # 32-bit, which is what the Play Console asks for — the opposite of the
    # App Store, where an alpha channel is what gets the upload rejected.
    source.resized(512, 512).save(PLAY / 'icon.png', alpha=True)
    print('  store-assets/play-store/icon.png          512x512')

    print('\nAndroid launcher icons and the Play listing icon are up to date.')
    return 0


def _corner_colour(image: Image) -> str:
    """The colour the mark is drawn on, read from a corner the mark never
    reaches rather than hard-coded, so a redrawn icon carries its own."""
    red, green, blue = image.pixels[0:3]
    return f'#{red:02X}{green:02X}{blue:02X}'


if __name__ == '__main__':
    raise SystemExit(main())
