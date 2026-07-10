# QuickPNG-To256Permill

PSD画像（72dpi）をカンバスpx数256‰（25.6%）の透過PNG（350dpiメタデータ）へクイック変換する、Claude（Cowork / Claude Code）向けパイプライン設定。

## 使い方

1. `input-PSD/` に変換したいPSDを置く
2. `.env.example` を `.env` にリネームコピーする（必要に応じてパラメータを変更）
3. Claude Desktop（Cowork）または Claude Code（VS Code）でこのフォルダを開く
4. 「input-PSDのファイルをoutput-PNGへ変換して」と依頼する
   — Claudeが `CLAUDE.md` の手順（Adobeハイブリッドパイプライン）に従って処理する
5. 結果は `output-PNG/` に出力される

## 前提

- **Adobe for creativity コネクタ**が接続・認証済みであること（縮小処理に使用）
- Claude Desktopのドメイン許可リストに `*.adobe.com` / `*.adobe.io` / `*.amazonaws.com` を追加済みであること（詳細は `CLAUDE.md`）
- Adobe不通時は ImageMagick のみのフォールバック（`scripts/local_fallback.sh`）で代替可能

## 構成

```
CLAUDE.md                 # Claude向けパイプライン定義（本体）
.env                      # 変換パラメータ（入出力dpi・縮小率）
scripts/local_fallback.sh # ImageMagickのみのフォールバック
input-PSD/                # 入力（git管理外）
output-PNG/               # 出力（git管理外）
```

## 設定（.env）

| 変数            | 既定値 | 意味                               |
| --------------- | ------ | ---------------------------------- |
| `INPUT_DPI`     | `72`   | 入力PSDの想定dpi（不一致なら警告） |
| `OUTPUT_DPI`    | `350`  | 出力PNGへ付与するdpiメタデータ     |
| `SCALE_PERCENT` | `25.6` | カンバスpx縮小率(%)。25.6 = 256‰   |

Claudeへの依頼・フォールバックスクリプトの両方がこの値を参照します。

## ライセンス

設定・スクリプト・ドキュメントは [MIT License](LICENSE)。
