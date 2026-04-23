# バックアップ

`06_Backups/` に定期バックアップを置く場所。

## バックアップ対象の優先順位

### 最重要（絶対に失いたくない）

- `docs/` のドキュメント
- `03_Unity_Project/Assets/_Project/` の自作スクリプトとシーン
- `02_Assets_Source/` の有料素材と自作素材

### 重要

- `03_Unity_Project` 全体（ただし `Library/` と `Temp/` は除外していい）

### 低優先

- `04_Builds/`（再ビルドできるので最悪消えてもOK）

## バックアップ方法の推奨

手軽な順：

1. **このフォルダに ZIP を置く**（日付付き）
    - 例: `VRBoxing_backup_2026-04-30.zip`
    - 週1回くらいのペースで
2. **外付けHDD / USB メモリ**
3. **クラウド**（Google Drive, OneDrive, Dropbox）
4. **Git + GitHub**（ベストだが慣れが必要 → 既にこのプロジェクトで採用済み）

## バックアップ命名規則

```
VRBoxing_backup_YYYY-MM-DD_vX.X.zip
```

例：

- `VRBoxing_backup_2026-04-30_v0.1.zip`
- `VRBoxing_backup_2026-05-15_v0.2.zip`

## バックアップの罠

!!! danger "やりがちなミス"

    - **「同じPC内だけ」のバックアップは半分の安心感**（HDD故障で全滅する）
    - **「一度作ったら放置」のバックアップは古すぎる**（作り直したデータは守れない）
    - **重要な区切りの前には必ずバックアップ**（Unity バージョンアップ前など）
