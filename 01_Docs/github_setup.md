# GitHub セットアップガイド

このプロジェクトを GitHub にアップロードして、ドキュメントを GitHub Pages で公開する手順。

## 1. 事前準備

- [ ] **GitHub アカウントを作成**（まだの場合）: https://github.com/signup
- [ ] **Git をインストール**（まだの場合）: https://git-scm.com/
- [ ] コマンドラインの基本操作がわかる（不安なら GitHub Desktop が簡単: https://desktop.github.com/）

## 2. リポジトリを作る

### GitHub Web 上で
1. https://github.com/new を開く
2. Repository name: `VRBoxing`
3. Description: `Valve Index 向け VR ボクシング／フィットネスゲーム（個人開発）`
4. **Public** を選択（GitHub Pages 無料枠のため）
5. 「Add a README file」は**チェックしない**（ローカルに既にあるので）
6. 「Create repository」を押す

## 3. ローカルからプッシュする

プロジェクトフォルダ（`C:\Users\hoeho\Documents\Claude\VRBoxing`）で PowerShell または Git Bash を開いて：

```bash
cd C:\Users\hoeho\Documents\Claude\VRBoxing

# Git を初期化
git init
git branch -M main

# 全ファイル追加
git add .
git commit -m "Initial commit: プロジェクト土台とドキュメント"

# GitHub のリポジトリと紐付け（URLは自分のものに置き換える）
git remote add origin https://github.com/あなたのユーザー名/VRBoxing.git
git push -u origin main
```

**`git push` で認証を求められたら**、ブラウザが開いて GitHub にログインする形で認証できます。もしくは Personal Access Token を使う方式もあります。

## 4. GitHub Pages を有効にする

1. GitHub のリポジトリページを開く
2. `Settings` タブ → 左メニューの `Pages`
3. **Source**: `Deploy from a branch` を選択
4. **Branch**: `main` / `/ (root)` を選択
5. `Save` を押す
6. 1〜5分待つと、上部に公開URLが表示される
   - 例: `https://あなたのユーザー名.github.io/VRBoxing/`

このURLを開くと、Docsify がサイドバー付きのドキュメントサイトを表示してくれます。

## 5. 以降の更新

何か書き足したとき：

```bash
cd C:\Users\hoeho\Documents\Claude\VRBoxing
git add .
git commit -m "開発ログ追加: Unityのインストール完了"
git push
```

push すると自動で GitHub Pages にも反映されます（1〜2分）。

## 6. 便利な Tips

### GitHub Desktop を使う場合
コマンドラインが苦手なら、GitHub Desktop（https://desktop.github.com/）がおすすめ。クリック操作で add / commit / push ができる。

### コミットメッセージのコツ
- `feat: Unityプロジェクト作成` ← 新機能
- `docs: 設計メモ追加` ← ドキュメント
- `fix: OpenXR設定の誤記修正` ← 修正
- `chore: フォルダ整理` ← 雑多なもの

慣れてきたら上記のような接頭辞をつけると、あとで「いつ何を変えたか」が追いやすい。

## 7. 公開して大丈夫なもの／いけないもの

Public リポジトリなので**誰でも見られます**。以下には気をつける：

### 公開してOK
- 自分で書いたドキュメント・設計メモ
- 自作コード
- CC0 / MIT / 商用OKライセンスの素材への参照メモ

### 公開NG（.gitignore で除外するか Private リポジトリに分ける）
- **有料素材の元データ**（Character Creator 4 の出力、Booth で購入したモデル等）
- **ライセンスが「再配布禁止」のもの**
- パスワード、APIキー、個人情報
- Unity の `Library/`、`Temp/` フォルダ（サイズが大きく無意味）

この後 `.gitignore` で Unity 用の除外設定をしてあるので、それに従えば基本的に安全です。
