# QuickPNG-To256Permill

PSD画像（72dpi）をカンバスpx数256‰（25.6%）の透過PNG（350dpiメタデータ）へクイック変換する、Claude（Cowork / Claude Code）向けパイプライン設定。

姉妹リポジトリ:

- [QuickPNG-SmartObjectExport](https://github.com/radiann-kswg/QuickPNG-SmartObjectExport) — PSD埋め込みスマートオブジェクトの変形初期化PNG抽出
- [QuickPNG-Tinize4Web](https://github.com/radiann-kswg/QuickPNG-Tinize4Web) — Web公開用の高圧縮PNG変換

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
- macOS では `brew install imagemagick` で ImageMagick を導入し、フォールバックは `bash scripts/local_fallback.sh` で実行する

## 構成

```
CLAUDE.md                 # Claude向けパイプライン定義（本体）
README.md                 # 本ファイル
.env.example              # 変換パラメータのテンプレート
.env                      # 実際の変換パラメータ（git管理外・要作成）
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

## 出力の検証

Claudeは変換後、全件について次を確認します（詳細は `CLAUDE.md`）。

- PILで開けること（ダウンロード切断・破損の検出。ヘッダ確認だけでは検出できない）
- `mode=RGBA` かつ元PSDが透過なら角ピクセルの alpha=0
- 寸法が `round(SCALE_PERCENT/100 × 元px)` ±1px
- DPIメタデータ ≈ `OUTPUT_DPI`

## ライセンス

設定・スクリプト・ドキュメントは [MIT License](LICENSE)。
`input-PSD/`・`output-PNG/` の画像アセットは**ライセンス対象外かつgit管理外**。
