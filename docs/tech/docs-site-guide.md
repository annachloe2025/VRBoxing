# ドキュメントサイト運用ガイド

このプロジェクトは **MkDocs + Material テーマ**を使って、MD ファイルをサイトとして公開しています。

## 仕組み

- `docs/` フォルダ以下に MD ファイルを書く
- `mkdocs.yml` に設定（テーマ、ナビゲーション、プラグイン）
- `mkdocs gh-deploy` でビルド → `gh-pages` ブランチへ push → GitHub Pages が反映
- この一連の流れは **`update.bat` で全部自動化**されている

## 新しいページを追加する方法

### 1. MD ファイルを作る

例: 「OpenXR 設定のメモ」を作りたい場合

ファイルを作る → `docs/tech/openxr.md`

### 2. `mkdocs.yml` の `nav:` にリンクを追加

```yaml
nav:
  ...
  - 技術・環境構築:
      - Unity プロジェクト: tech/unity.md
      - GitHub セットアップ: tech/github-setup.md
      - ドキュメントサイト運用: tech/docs-site-guide.md
      - OpenXR 設定: tech/openxr.md    # ← これを追加
```

### 3. `update.bat` をダブルクリック

これだけ。サイトに反映される。

## ローカルでプレビューする方法

公開前にローカルで見たいとき：

```powershell
cd C:\Users\hoeho\Documents\Claude\VRBoxing
python -m mkdocs serve
```

→ ブラウザで `http://127.0.0.1:8000` を開く。ファイルを編集すると自動で再読み込みされる。

## Material テーマの便利な書き方

### 注意・メモ系（Admonition）

```markdown
!!! note "タイトル"
    本文

!!! tip "コツ"
    本文

!!! warning "注意"
    本文

!!! danger "NG"
    本文

!!! success "できた"
    本文
```

### チェックリスト

```markdown
- [ ] 未完了タスク
- [x] 完了済みタスク
```

### コードブロック（コピーボタン付き）

````markdown
```csharp
void Start() {
    Debug.Log("Hello");
}
```
````

### タブ

```markdown
=== "Windows"
    Windows用の手順

=== "Mac"
    Mac用の手順
```

## 認知負荷を下げる書き方のコツ

!!! tip "書くときのルール"

    1. **1ページ = 1トピック**にする（長くなったら分割）
    2. **先頭に目的と結論**を書く（何のためのページか3秒で分かる）
    3. **箇条書きとテーブル多め**（文章を追わなくてもスキャンできる）
    4. **見出しレベルは3までに抑える**（深いと迷子になる）
    5. **リンクは惜しまず張る**（「詳しくは〇〇」で横展開できる）

## まとめ

設定が増えてきても、**MD を書き足す → `mkdocs.yml` の nav に一行足す → update.bat ダブルクリック** の3手順で完了。情報のホームポジションがここになるので、「あの設定どこにメモしたっけ」がなくなります。
