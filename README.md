# QuickPNG-To256Permill

PSD画像（72dpi）をカンバスpx数25.6%の透過PNG（350dpiメタデータ）へクイック変換する、Claude（Cowork / Claude Code）向けパイプライン設定。

## 使い方

1. `input-PSD/` に変換したいPSDを置く
2. Claude Desktop（Cowork）または Claude Code（VS Code）でこのフォルダを開く
3. 「input-PSDのファイルをoutput-PNGへ変換して」と依頼する
   — Claudeが `CLAUDE.md` の手順（Adobeハイブリッドパイプライン）に従って処理する
4. 結果は `output-PNG/` に出力される

## 前提

- **Adobe for creativity コネクタ**が接続・認証済みであること（縮小処理に使用）
- Claude Desktopのドメイン許可リストに `*.adobe.com` / `*.adobe.io` / `*.amazonaws.com` を追加済みであること（詳細は `CLAUDE.md`）
- Adobe不通時は ImageMagick のみのフォールバック（`scripts/local_fallback.sh`）で代替可能

## 構成

```
CLAUDE.md                 # Claude向けパイプライン定義（本体）
scripts/local_fallback.sh # ImageMagickのみのフォールバック
input-PSD/                # 入力（git管理外）
output-PNG/               # 出力（git管理外）
```

## ライセンス

設定・スクリプト・ドキュメントは [MIT License](LICENSE)。
