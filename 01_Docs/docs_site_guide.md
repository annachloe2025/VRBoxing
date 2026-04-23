# ドキュメントサイト運用ガイド

このプロジェクトは **Docsify** を使って、MD ファイルをそのままサイトっぽく表示できるようにしてあります。

認知負荷を減らすために**「書くのは今まで通り MD、見るときはサイトっぽく」**を実現する仕組みです。

## どういう仕組みか

- `index.html` を開くと Docsify が起動する
- Docsify が `_sidebar.md` を読んでサイドバーを作る
- 各 MD ファイルがページとして表示される（リアルタイムでHTMLに変換）
- 検索機能・ページカウント・ページ遷移などが自動で付く
- **ビルド不要**。MD を書き足すだけで反映される

## ローカルで確認する方法

`index.html` を直接ダブルクリックでは動かない（CORS の関係）。以下のいずれかの方法で見る：

### 方法 A: VS Code の Live Server（おすすめ）
1. VS Code に「Live Server」拡張をインストール
2. `index.html` を右クリック → `Open with Live Server`
3. ブラウザが自動で開く

### 方法 B: Python のお手軽サーバ
PowerShell で：

```powershell
cd C:\Users\hoeho\Documents\Claude\VRBoxing
python -m http.server 3000
```

ブラウザで `http://localhost:3000` を開く。

### 方法 C: Docsify CLI
```powershell
npm install -g docsify-cli
cd C:\Users\hoeho\Documents\Claude\VRBoxing
docsify serve .
```

## 新しいページを追加する方法

### 1. MD ファイルを書く
例: `01_Docs/openxr_settings.md` を作る。

### 2. `_sidebar.md` にリンクを足す
```markdown
* **🛠 技術・環境構築**
  * [Unity プロジェクト](03_Unity_Project/README.md)
  * [GitHub セットアップ](01_Docs/github_setup.md)
  * [OpenXR 設定](01_Docs/openxr_settings.md)  ← これを追加
```

### 3. ブラウザをリロード
それだけ。ビルド不要。

## カテゴリを増やしたい場合

`_sidebar.md` にグループを足すだけ：

```markdown
* **🎛 VR設定詳細**
  * [コントローラー設定](01_Docs/vr/controllers.md)
  * [トラッキング調整](01_Docs/vr/tracking.md)
```

## 画像を貼る

MD の中に画像が入れられます：

```markdown
![Unity画面のスクショ](../images/unity_setup.png)
```

画像は `05_Reference/images/` や `01_Docs/images/` に置くと整理しやすい。

## 図・ダイアグラム

Docsify は Mermaid 記法もプラグインで使える（必要になったら後で足す）。例：

```mermaid
graph LR
    A[プレイヤーのパンチ] --> B{速度判定}
    B -->|閾値以上| C[有効ヒット]
    B -->|閾値未満| D[無効]
    C --> E[効果音＋振動]
```

こういうフローチャートも MD に書けるようになります。

## 認知負荷を下げる書き方のコツ

1. **1ページ = 1トピック**にする（長くなったら分割）
2. **先頭に目的と結論**を書く（何のためのページか3秒で分かる）
3. **箇条書きとテーブル多め**（文章を追わなくてもスキャンできる）
4. **見出しレベルは3までに抑える**（深いと迷子になる）
5. **リンクは惜しまず張る**（「詳しくは〇〇」で横展開できる）

## まとめ

設定が増えてきても、MD を書き足す → `_sidebar.md` に一行足す、だけでサイトに反映される。**情報のホームポジション**がここになるので、「あの設定どこにメモしたっけ」がなくなります。
