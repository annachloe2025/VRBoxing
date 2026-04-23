# 開発ログ

日々の作業を書き留める場所。詰まったところと解決策をセットで残すと、未来の自分が助かる。

!!! tip "書き方テンプレート"

    ```
    ## YYYY-MM-DD
    
    ### やったこと
    -
    
    ### 詰まったところ
    -
    
    ### 解決策 / 次やること
    -
    
    ### 参考URL
    -
    ```

---

## 2026-04-23

### やったこと

- プロジェクトのフォルダ構成を決めた
- VRBoxing/ 以下にフォルダを作成
- README.md とステップ1計画書を作成
- CLAUDE.md（Claude用コンテキストファイル）を追加
- TASKS.md（アクティブタスク管理）を追加
- **Docsifyでドキュメントサイト化**（index.html, _sidebar.md, _coverpage.md）
- .gitignore（Unity用）を追加
- GitHubセットアップガイド、ドキュメントサイト運用ガイドを作成
- README.md をダッシュボード形式にリファクタ
- GitHub リポジトリ `annachloe2025/VRBoxing` を作成、初回 push
- GitHub Pages を main ブランチで公開
- `update.bat` を作成（`git add` → `commit` → `push` を自動化）
- **Docsify → MkDocs + Material テーマへ移行**
- docs/ フォルダを切って既存の MD を整理移動
- `update.bat` に MkDocs のインストール・デプロイ・旧ファイル削除まで組み込み

### メモ

- 認知負荷対策として、作業フローを「`update.bat` ダブルクリックだけ」にまとめた
- Docsify のカバーページがうまく表示されず、MkDocs Material の方が読みやすかったため切り替え
- MkDocs は `mkdocs gh-deploy` で `gh-pages` ブランチに静的サイトがビルド＆デプロイされる
- 新しい設定メモは `docs/` 下に MD を追加し、`mkdocs.yml` の `nav` に一行足すだけで反映される

### 次やること

- Unity Hub と Unity LTS をインストール
- Valve Index 用の OpenXR 設定を調べる
- VRoid Studio で女性キャラのベースを作り始める
