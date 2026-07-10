#!/usr/bin/env bash
# Adobe不通時のフォールバック:
# ImageMagickのみで input-PSD/*.psd → 25.6%縮小・350dpi・透過PNG → output-PNG/
#
# 注意:
#  - "[0]" はPSDのコンポジット（全カンバス）フレーム。-flatten は透過を壊すため使用禁止
#  - PNG32 でアルファチャンネルを確実に保持する
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p output-PNG
shopt -s nullglob
count=0
for f in input-PSD/*.psd input-PSD/*.PSD; do
  base=$(basename "$f")
  base=${base%.*}
  convert "${f}[0]" -resize 25.6% -units PixelsPerInch -density 350 "PNG32:output-PNG/${base}.png"
  identify -units PixelsPerInch -format "%f | %wx%h | alpha=%A | %x PPI\n" "output-PNG/${base}.png"
  count=$((count + 1))
done
echo "done: ${count} file(s)"
