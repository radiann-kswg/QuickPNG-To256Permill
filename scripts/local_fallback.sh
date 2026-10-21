#!/usr/bin/env bash
# Adobe不通時のフォールバック:
# ImageMagickのみで input-PSD/*.psd → SCALE_PERCENT%縮小・OUTPUT_DPI付与・透過PNG → output-PNG/
#
# 設定はリポジトリ直下の .env から読み込む（無ければ既定値）。
#
# 注意:
#  - "[0]" はPSDのコンポジット（全カンバス）フレーム。-flatten は透過を壊すため使用禁止
#  - PNG32 でアルファチャンネルを確実に保持する
set -euo pipefail
cd "$(dirname "$0")/.."

# 既定値
INPUT_DPI=72
OUTPUT_DPI=350
SCALE_PERCENT=25.6

# .env 読み込み（KEY=VALUE 形式のみ。コメント・空行・未知キーは無視）
if [ -f .env ]; then
  while IFS='=' read -r k v; do
    v=${v%%#*}
    v=${v//[[:space:]]/}
    case "$k" in
      INPUT_DPI | OUTPUT_DPI | SCALE_PERCENT) printf -v "$k" '%s' "$v" ;;
    esac
  done < <(grep -E '^[A-Z_]+=' .env)
fi

echo "settings: INPUT_DPI=${INPUT_DPI} OUTPUT_DPI=${OUTPUT_DPI} SCALE_PERCENT=${SCALE_PERCENT}%"
mkdir -p output-PNG
shopt -s nullglob
count=0
for f in input-PSD/*.psd input-PSD/*.PSD; do
  base=$(basename "$f")
  base=${base%.*}
  # 入力dpiの検証（想定と異なれば警告のみ）
  src_dpi=$(magick identify -units PixelsPerInch -format "%x" "${f}[0]" 2>/dev/null | cut -d. -f1 || true)
  if [ -n "${src_dpi}" ] && [ "${src_dpi}" != "${INPUT_DPI}" ]; then
    echo "warn: ${base}: 入力dpi=${src_dpi}（想定 INPUT_DPI=${INPUT_DPI}）"
  fi
  magick "${f}[0]" -resize "${SCALE_PERCENT}%" -units PixelsPerInch -density "${OUTPUT_DPI}" "PNG32:output-PNG/${base}.png"
  magick identify -units PixelsPerInch -format "%f | %wx%h | alpha=%A | %x PPI\n" "output-PNG/${base}.png"
  count=$((count + 1))
done
# 後段: iLoveAPI 圧縮（.env で有効時のみ。python3 が無ければ python）
(command -v python3 >/dev/null && python3 scripts/iloveapi_compress.py) || python scripts/iloveapi_compress.py || true
echo "done: ${count} file(s)"
