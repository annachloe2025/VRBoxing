# VRBoxing

Valve Index 向けの VR ボクシング／フィットネスゲームの個人開発プロジェクト。

## 🎯 現在のステータス

| 項目 | 内容 |
|---|---|
| **フェーズ** | ステップ1 / 事前準備 |
| **最終更新** | 2026-04-23 |
| **直近の動き** | プロジェクト土台とドキュメントサイトの整備完了 |
| **次のアクション** | Unity Hub + Unity LTS のインストール、VRoid Studio でキャラ作り開始 |

---

## 🚀 はじめに見るべき3つ

1. **[📋 いまのタスク](TASKS.md)** — 次に何をやればいいか一覧
2. **[🥊 ステップ1の詳細計画](01_Docs/step1_plan.md)** — 殴れる女性キャラまでの工程
3. **[🛠 GitHub セットアップ](01_Docs/github_setup.md)** — GitHub に上げてサイト公開する手順

---

## 💡 このプロジェクトの目的

- **フィットネスとして続けられる** VR ボクシング体験を作る
- **女性キャラクターと対戦できる**（モチベーション維持の核心）
- Unity + VR 開発の学習も兼ねる
- 参考作品: [Thrill of the Fight](https://store.steampowered.com/app/651900/)（Ian Fitz 開発）

## 🎮 開発環境

| 項目 | 内容 |
|---|---|
| VRデバイス | Valve Index（Knuckles コントローラー） |
| エンジン | Unity 2022.3 LTS または Unity 6 LTS |
| VR SDK | OpenXR + XR Interaction Toolkit |
| 言語 | C# |

## 🗺 ロードマップ

| ステップ | 内容 | 期間目安 | ステータス |
|---|---|---|---|
| 1 | 殴れる女性サンドバッグ | 2週間 | 🔵 進行中 |
| 2 | 軽く動く／殴り返す相手 | 1〜2ヶ月 | ⚪ 未着手 |
| 3 | 見た目・演出の作り込み | - | ⚪ 未着手 |
| 4 | 本格的な対戦AI | 将来 | ⚪ 未着手 |

---

## 📁 プロジェクト構造

### ルートファイル

| ファイル | 用途 |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Claudeがプロジェクトに入るとき最初に読むコンテキスト |
| [TASKS.md](TASKS.md) | 現在アクティブなタスク管理 |
| [index.html](index.html) | Docsify ドキュメントサイトのエントリ |
| [_sidebar.md](_sidebar.md) | サイドバー設定 |
| [.gitignore](.gitignore) | Git から除外するファイル設定 |

### フォルダ

| フォルダ | 用途 |
|---|---|
| [01_Docs](01_Docs/README.md) | 設計メモ、進捗日記、学習ノート |
| [02_Assets_Source](02_Assets_Source/README.md) | 素材の元データ（Unity外保管） |
| [03_Unity_Project](03_Unity_Project/README.md) | Unity プロジェクト本体 |
| [04_Builds](04_Builds/README.md) | ビルド済みの実行ファイル |
| [05_Reference](05_Reference/README.md) | 参考資料（他人のもの） |
| [06_Backups](06_Backups/README.md) | 定期バックアップ |

---

## 📘 ドキュメントサイトとして見る

このプロジェクトのMDファイルは **Docsify** で整理されていて、サイトっぽく閲覧できます。

### ローカルで見る
PowerShell で：
```bash
cd C:\Users\hoeho\Documents\Claude\VRBoxing
python -m http.server 3000
```
→ ブラウザで http://localhost:3000 を開く

または VS Code の **Live Server** 拡張で `index.html` を開く。

### GitHub Pages で公開する
[GitHub セットアップガイド](01_Docs/github_setup.md) に手順あり。公開すればどこからでもURLで見られる。

詳しくは [ドキュメントサイト運用ガイド](01_Docs/docs_site_guide.md) を参照。
