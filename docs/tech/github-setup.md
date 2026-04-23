# GitHub セットアップ

このプロジェクトは GitHub リポジトリ `annachloe2025/VRBoxing` にアップ済み。ドキュメントサイトは `gh-pages` ブランチで公開される（MkDocs 方式）。

!!! info "現状"

    - リポジトリ: <https://github.com/annachloe2025/VRBoxing>
    - ドキュメントサイト: <https://annachloe2025.github.io/VRBoxing/>
    - ソース管理: `main` ブランチ
    - サイト公開: `gh-pages` ブランチ（`mkdocs gh-deploy` で自動更新）

## 日々の更新のしかた

**`update.bat` をダブルクリックするだけ。** それだけで：

1. 必要な Python パッケージを自動で入れる
2. 変更をステージング
3. コミット（メッセージはEnterでデフォルト）
4. GitHub に push
5. MkDocs でサイトをビルドして `gh-pages` に push
6. GitHub Pages が自動で反映（1〜2分）

## GitHub Pages の branch 設定（初回のみ）

MkDocs は `gh-pages` ブランチを自動で作ってビルド結果を push します。GitHub Pages 側の設定でこのブランチを公開対象にする必要があります。

1. <https://github.com/annachloe2025/VRBoxing/settings/pages> を開く
2. **Source**: `Deploy from a branch`
3. **Branch**: `gh-pages` を選択、フォルダは `/ (root)`
4. `Save`

この設定は **1回やれば以降は自動**。

## 詰まったとき用メモ

### `git push` で認証エラー

ユーザー名とパスワードで弾かれるとき → **Personal Access Token** が必要：

1. <https://github.com/settings/tokens> へ
2. 「Generate new token (classic)」
3. Note: `VRBoxing push`
4. Scopes: **`repo`** にチェック
5. Generate → 表示トークンをコピー
6. PowerShell の「パスワード」欄にトークンを貼り付け

### `mkdocs gh-deploy` が失敗する

- `pip install mkdocs mkdocs-material` し直してみる
- `mkdocs.yml` の YAML に誤りがないか（インデントや `: ` の空白）
- Python 3.8 以上が入っているか（`python --version` で確認）

### 日本語ファイル名が化ける

今回のプロジェクトはファイル名を全部英数字にしているので基本大丈夫。もし日本語ファイル名を追加した場合は、`update.bat` 冒頭の `chcp 65001` が効いているはず。

## 公開してOK／NG の整理

Public リポジトリなので誰でも見られます。

!!! success "公開してOK"

    - 自分で書いたドキュメント・設計メモ
    - 自作コード
    - CC0 / MIT / 商用OK ライセンスの素材への参照メモ

!!! danger "公開NG（.gitignoreで除外 or Private分離）"

    - 有料素材の元データ（Character Creator 4 出力、Booth 購入モデル等）
    - ライセンスが「再配布禁止」のもの
    - パスワード、APIキー、個人情報
    - Unity の `Library/`、`Temp/` フォルダ（サイズが大きく無意味）

`.gitignore` で Unity 用の除外設定をしてあるので、基本的に安全。

## コミットメッセージの型（慣れてきたら）

- `feat:` 新機能
- `fix:` バグ修正
- `docs:` ドキュメント
- `chore:` 雑多（整理・設定変更など）

例: `feat: サンドバッグの当たり判定を追加`
