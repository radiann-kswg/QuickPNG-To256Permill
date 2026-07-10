# QuickPNG-To256Permill — 256‰縮小PNGクイック出力パッチ

## 目的

`input-PSD/` の PSD（72dpi）を、カンバスpx数を元の **25.6%** に縮小した**透過PNG（350dpiメタデータ付き）**として `output-PNG/` へ出力する。

## 返答言語

チャットでの返答は必ず日本語。

## 出力要件（すべて必須）

- 寸法: `round(0.256 × 元のW/H)` px（±1pxの丸め差は許容）
- アルファ: RGBA透過を必ず保持（背景が白に合成されていたら失敗 → やり直し）
- DPI: 350 PixelsPerInch のメタデータ
- ファイル名: 元PSDのベース名を維持（`.psd` → `.png`）

## 推奨パイプライン: Adobeハイブリッド（2026-07-10 全11件で検証済み）

縮小処理は Adobe for creativity コネクタ（MCP）の `image_crop_and_resize` で行う。
**PSDを直接Adobeに渡すと白背景にフラット化されアルファが失われる**（検証済み）ため、等倍ラスタライズのみローカルの ImageMagick で行う。

1. `adobe_mandatory_init` を呼び、`get_account_type` が `auth` であることを確認
2. ローカル: `convert "input.psd[0]" PNG32:full.png`
   （リサイズなし・アルファ保持。`[0]`=コンポジット。**`-flatten` 禁止**）
3. アップロード:
   - `asset_initialize_file_upload({path, file_size, media_type: "image/png"})`
   - 返却された transfer URL へ `curl -s -L -X PUT -H "Content-Type: image/png" --data-binary @full.png`（`-L` 必須: 308リダイレクトされる）
   - `asset_finalize_file_upload`（`transfer_document` は返却値を**丸ごと**渡す）
4. `image_crop_and_resize({imageURI: presignedAssetUrl, options: {fit: "pad", output: {width, height}}, outputFileType: "png"})`
   - width/height = `round(0.256 × 元px)`
5. 出力URL（`photoshop-api.adobe.io/v2/short-url/...`）をダウンロード
6. ローカル: `convert out.png -units PixelsPerInch -density 350 PNG32:final.png` → `output-PNG/` へ
7. 検証チェックリスト（下記）を全件実施

複数ファイルはステップ3〜5の各段階を並列バッチで実行（11件同時まで実績あり）。20件超の大量バッチはAdobeコネクタ非対応。

## ネットワーク許可（Claude Desktop: 設定→機能→ドメイン許可リスト）

サンドボックスegressで必要なドメイン:

| ドメイン          | 用途                                                                                |
| ----------------- | ----------------------------------------------------------------------------------- |
| `*.adobe.com`     | `at.adobe.com`: presigned短縮URL（転送/確定/取得）                                  |
| `*.adobe.io`      | `acp-aep-cs-blobstore-*.adobe.io`: 実ストレージ / `photoshop-api.adobe.io`: 出力URL |
| `*.amazonaws.com` | `cis-utils-storage-prod.s3-accelerate.amazonaws.com`: 出力ファイルの実体            |

- 許可リストは**アプリ/セッション再起動後に反映**される（ホットリロードされない）
- ブロック時は curl が `403` + `X-Proxy-Error: blocked-by-allowlist` を返す
- S3がブロックされている場合のCowork迂回: desktop-commander の PowerShell から
  `curl.exe -s -L -o "D:\...\output-PNG\名前.png" <出力URL>` でPC側ダウンロード → サンドボックスからマウント経由でDPIスタンプ

## 検証チェックリスト（毎回・全件）

- PIL で `Image.open(f); im.load()` が通る（**ダウンロード切断の検出**。identify/fileのヘッダ確認では検出不可）
- `mode=RGBA` かつ、元PSDの背景が透明なら角ピクセルの alpha=0
- 寸法が `round(0.256×元)` ±1px
- DPIメタデータ ≈ 350

## 既知の落とし穴

- Adobe `image_crop_and_resize` はアスペクト保持丸めで指定値と±1pxずれることがある。**metadataの報告値と実ファイルが異なる場合がある**ため、必ず実ファイルで検証する
- Coworkのマウント同期: サンドボックスが書いたファイルをPC側で上書きすると、サンドボックスから古い内容が見え続けることがある → **新しいファイル名**でダウンロードし直してからコピーで差し替える
- Adobeトークン失効（エラー: "session token is about to expire"）の再認証手順:
  claude.ai → 設定 → **カスタマイズ→コネクタ** → Adobe for creativity → 「切断する」→「連携させる」
  （「接続済み」表示中は再認証ボタンが存在しない。旧「設定→コネクタ」は移動案内ページのみで操作不可。ブラウザにAdobeセッションが残っていればサインイン画面なしで完了する）

## フォールバック: ImageMagickのみ（Adobe不通時）

`scripts/local_fallback.sh` を実行。中身は実質:

```bash
convert "input.psd[0]" -resize 25.6% -units PixelsPerInch -density 350 "PNG32:output.png"
```

## ライセンス

このリポジトリの設定・スクリプト・ドキュメントは MIT（`LICENSE` 参照）。
`input-PSD/`・`output-PNG/` の画像アセットは**ライセンス対象外かつgit管理外**。
