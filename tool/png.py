"""Just enough PNG to resize the app mark, with nothing but the standard library.

The repository has to produce Android launcher icons and store graphics on
whatever machine runs the release, and neither Pillow nor ImageMagick nor
`sips` can be assumed to be there — `sips` in particular is macOS only, and
the Android assets are the ones that most need to be reproducible elsewhere.

Only what the project's own PNGs use is supported: 8 bits per channel, no
interlacing. That covers the icon sources and everything Flutter writes as a
golden. Anything else raises rather than guessing.
"""

from __future__ import annotations

import pathlib
import struct
import zlib

_SIGNATURE = b'\x89PNG\r\n\x1a\n'

# Bytes per pixel for each PNG colour type, once a palette is expanded.
_CHANNELS = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}


class Image:
    """An 8-bit RGBA bitmap, one row after another, four bytes per pixel."""

    def __init__(self, width: int, height: int, pixels: bytearray):
        if len(pixels) != width * height * 4:
            raise ValueError(
                f'{width}x{height} needs {width * height * 4} bytes, '
                f'got {len(pixels)}'
            )
        self.width = width
        self.height = height
        self.pixels = pixels

    # -- reading ----------------------------------------------------------

    @classmethod
    def load(cls, path) -> 'Image':
        data = pathlib.Path(path).read_bytes()
        if data[:8] != _SIGNATURE:
            raise ValueError(f'{path} is not a PNG')

        header = None
        palette = b''
        transparency = b''
        compressed = bytearray()

        offset = 8
        while offset < len(data):
            (length,) = struct.unpack('>I', data[offset:offset + 4])
            kind = data[offset + 4:offset + 8]
            chunk = data[offset + 8:offset + 8 + length]
            offset += 12 + length

            if kind == b'IHDR':
                header = struct.unpack('>IIBBBBB', chunk)
            elif kind == b'PLTE':
                palette = chunk
            elif kind == b'tRNS':
                transparency = chunk
            elif kind == b'IDAT':
                compressed += chunk
            elif kind == b'IEND':
                break

        if header is None:
            raise ValueError(f'{path} has no IHDR')
        width, height, depth, colour, compression, filtering, interlace = header
        if depth != 8:
            raise ValueError(f'{path}: only 8 bits per channel, not {depth}')
        if interlace:
            raise ValueError(f'{path}: interlaced PNGs are not supported')
        if compression or filtering:
            raise ValueError(f'{path}: unexpected compression or filter method')
        if colour not in _CHANNELS:
            raise ValueError(f'{path}: unknown colour type {colour}')

        channels = _CHANNELS[colour]
        raw = _unfilter(
            zlib.decompress(bytes(compressed)), width, height, channels
        )
        return cls(
            width, height, _to_rgba(raw, width, height, colour, palette,
                                    transparency)
        )

    # -- writing ----------------------------------------------------------

    def save(self, path, *, alpha: bool = True) -> None:
        """Writes the bitmap out, as RGBA or — flattened onto white — as RGB.

        The Play Console wants the launcher icon 32-bit and the feature
        graphic without an alpha channel at all, so both spellings are needed.
        """
        channels = 4 if alpha else 3
        source = self.pixels if alpha else _flatten(self.pixels)
        stride = self.width * channels

        rows = bytearray()
        previous = bytes(stride)
        for y in range(self.height):
            row = bytes(source[y * stride:(y + 1) * stride])
            rows += _best_filter(row, previous, channels)
            previous = row

        header = struct.pack(
            '>IIBBBBB', self.width, self.height, 8, 6 if alpha else 2, 0, 0, 0
        )
        pathlib.Path(path).write_bytes(
            _SIGNATURE
            + _chunk(b'IHDR', header)
            + _chunk(b'IDAT', zlib.compress(bytes(rows), 9))
            + _chunk(b'IEND', b'')
        )

    # -- transforming -----------------------------------------------------

    def resized(self, width: int, height: int) -> 'Image':
        """Area-averaged resample, which is what keeps a downscaled mark from
        breaking up along its strokes the way nearest-neighbour would."""
        horizontal = _resample_rows(
            self.pixels, self.width, self.height, width
        )
        # Resampling columns is the same pass over the transpose, so the
        # bitmap is turned on its side, run through again, and turned back.
        turned = _transpose(horizontal, width, self.height)
        vertical = _resample_rows(turned, self.height, width, height)
        return Image(width, height, _transpose(vertical, height, width))

    def centred_on(self, size: int, scale: float) -> 'Image':
        """Places the image, scaled, in the middle of a transparent square.

        An adaptive icon hands the launcher a 108dp layer whose mark has to
        live inside the middle 66dp: everything outside that can be masked
        away, and a full-bleed mark loses its edges to whatever shape the
        launcher happens to use.
        """
        inner = round(size * scale)
        source = self.resized(inner, inner)
        canvas = bytearray(size * size * 4)
        left = (size - inner) // 2
        for y in range(inner):
            start = ((y + left) * size + left) * 4
            canvas[start:start + inner * 4] = source.pixels[
                y * inner * 4:(y + 1) * inner * 4
            ]
        return Image(size, size, canvas)


def _chunk(kind: bytes, payload: bytes) -> bytes:
    body = kind + payload
    return struct.pack('>I', len(payload)) + body + struct.pack(
        '>I', zlib.crc32(body) & 0xFFFFFFFF
    )


def _unfilter(raw: bytes, width: int, height: int, channels: int) -> bytearray:
    """Undoes the per-scanline filter each row carries as its first byte."""
    stride = width * channels
    out = bytearray(height * stride)
    previous = bytearray(stride)
    position = 0

    for y in range(height):
        method = raw[position]
        position += 1
        row = bytearray(raw[position:position + stride])
        position += stride

        if method == 1:  # Sub
            for i in range(channels, stride):
                row[i] = (row[i] + row[i - channels]) & 0xFF
        elif method == 2:  # Up
            for i in range(stride):
                row[i] = (row[i] + previous[i]) & 0xFF
        elif method == 3:  # Average
            for i in range(stride):
                left = row[i - channels] if i >= channels else 0
                row[i] = (row[i] + ((left + previous[i]) >> 1)) & 0xFF
        elif method == 4:  # Paeth
            for i in range(stride):
                left = row[i - channels] if i >= channels else 0
                up = previous[i]
                corner = previous[i - channels] if i >= channels else 0
                row[i] = (row[i] + _paeth(left, up, corner)) & 0xFF
        elif method != 0:
            raise ValueError(f'unknown row filter {method}')

        out[y * stride:(y + 1) * stride] = row
        previous = row

    return out


def _paeth(left: int, up: int, corner: int) -> int:
    estimate = left + up - corner
    da, db, dc = (
        abs(estimate - left),
        abs(estimate - up),
        abs(estimate - corner),
    )
    if da <= db and da <= dc:
        return left
    return up if db <= dc else corner


def _best_filter(row: bytes, previous: bytes, channels: int) -> bytes:
    """Picks a filter per scanline by the sum-of-absolute-differences rule the
    PNG specification suggests, which is what keeps the committed icons small."""
    candidates = [bytes([0]) + row]

    sub = bytearray(len(row))
    for i, value in enumerate(row):
        sub[i] = (value - (row[i - channels] if i >= channels else 0)) & 0xFF
    candidates.append(bytes([1]) + bytes(sub))

    up = bytearray(len(row))
    for i, value in enumerate(row):
        up[i] = (value - previous[i]) & 0xFF
    candidates.append(bytes([2]) + bytes(up))

    paeth = bytearray(len(row))
    for i, value in enumerate(row):
        left = row[i - channels] if i >= channels else 0
        corner = previous[i - channels] if i >= channels else 0
        paeth[i] = (value - _paeth(left, previous[i], corner)) & 0xFF
    candidates.append(bytes([4]) + bytes(paeth))

    return min(candidates, key=lambda c: sum(min(b, 256 - b) for b in c[1:]))


def _to_rgba(raw: bytes, width: int, height: int, colour: int, palette: bytes,
             transparency: bytes) -> bytearray:
    out = bytearray(width * height * 4)
    count = width * height

    if colour == 6:
        return bytearray(raw)
    if colour == 2:
        for i in range(count):
            out[i * 4:i * 4 + 3] = raw[i * 3:i * 3 + 3]
            out[i * 4 + 3] = 255
    elif colour == 0:
        for i in range(count):
            grey = raw[i]
            out[i * 4:i * 4 + 4] = bytes((grey, grey, grey, 255))
    elif colour == 4:
        for i in range(count):
            grey = raw[i * 2]
            out[i * 4:i * 4 + 4] = bytes((grey, grey, grey, raw[i * 2 + 1]))
    elif colour == 3:
        for i in range(count):
            index = raw[i]
            out[i * 4:i * 4 + 3] = palette[index * 3:index * 3 + 3]
            out[i * 4 + 3] = (
                transparency[index] if index < len(transparency) else 255
            )
    return out


def _flatten(pixels: bytearray) -> bytearray:
    """Composites onto white and drops the alpha channel."""
    out = bytearray(len(pixels) // 4 * 3)
    for i in range(len(pixels) // 4):
        alpha = pixels[i * 4 + 3]
        for channel in range(3):
            value = pixels[i * 4 + channel]
            out[i * 3 + channel] = (
                value if alpha == 255
                else (value * alpha + 255 * (255 - alpha) + 127) // 255
            )
    return out


def _resample_rows(pixels: bytearray, width: int, height: int,
                   target: int) -> bytearray:
    """Averages each row down (or up) to `target` pixels, weighting the two
    partial pixels at the ends of each window by how much of them is covered."""
    if target == width:
        return bytearray(pixels)

    out = bytearray(target * height * 4)
    step = width / target

    # The window each output pixel averages over, worked out once for the
    # whole bitmap rather than per row.
    windows = []
    for x in range(target):
        start, end = x * step, (x + 1) * step
        first, last = int(start), min(int(-(-end // 1)), width)
        weights = []
        for source in range(first, last):
            covered = min(end, source + 1) - max(start, source)
            if covered > 0:
                weights.append((source, covered))
        total = sum(weight for _, weight in weights) or 1
        windows.append([(source, weight / total) for source, weight in weights])

    for y in range(height):
        row = y * width * 4
        destination = y * target * 4
        for x, window in enumerate(windows):
            for channel in range(4):
                value = 0.0
                for source, weight in window:
                    value += pixels[row + source * 4 + channel] * weight
                out[destination + x * 4 + channel] = min(255, int(value + 0.5))

    return out


def _transpose(pixels: bytearray, width: int, height: int) -> bytearray:
    out = bytearray(len(pixels))
    for y in range(height):
        row = y * width * 4
        for x in range(width):
            source = row + x * 4
            destination = (x * height + y) * 4
            out[destination:destination + 4] = pixels[source:source + 4]
    return out
