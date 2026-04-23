# TASKS — VRBoxing

アクティブなタスクと完了したタスクを追跡するファイル。
`01_Docs/step1_plan.md` の全体計画に対して、**今まさに手を付けているタスク**をここに抜き出す。

---

## 🟢 アクティブ（現在取り組んでいる）

### 事前準備フェーズ

- [ ] **Unity Hub をダウンロード・インストール**
  - URL: https://unity.com/download
  - 優先度: 高（これがないと始まらない）
  - 所要時間: 30分〜1時間（ダウンロード含む）

- [ ] **Unity エディタ（2022.3 LTS or Unity 6 LTS）をインストール**
  - Unity Hub から入れる
  - オプション: Windows Build Support、Visual Studio Community
  - 所要時間: 1〜2時間（ダウンロードが大きい）

- [ ] **Valve Index + SteamVR の動作確認**
  - SteamVR が起動して Index が正常にトラッキングされるか
  - Knuckles コントローラーが認識されるか

- [ ] **Knuckles 用の手首ストラップを用意**
  - 優先度: 高（安全のため、ボクシングは激しく振る）
  - 純正ストラップ＋サードパーティの「Knuckle Straps」などが安心

- [ ] **女性キャラを1体用意する**
  - 選択肢A: VRoid Studio でアニメ調を自作
  - 選択肢B: Mixamo でリアル調をダウンロード
  - まず1体だけ。好みの方向性を見極めるため

### 次にやる（上記が終わったら）

- [ ] Unity 新規プロジェクト作成（場所: `03_Unity_Project/VRBoxing`）
- [ ] XR Plugin Management + OpenXR Plugin + XR Interaction Toolkit をインストール
- [ ] Valve Index Controller Profile を OpenXR 設定に追加
- [ ] シーンに XR Origin を配置、VR で立てる状態を確認

### GitHub / ドキュメントサイト

- [ ] **GitHub アカウント確認／作成**（まだの場合）
- [ ] **Git をインストール**（まだの場合）
- [ ] **VRBoxing リポジトリを GitHub に作成（Public）**
- [ ] **ローカルから初回プッシュ**
- [ ] **GitHub Pages を有効化** → ドキュメントサイトのURLが発行される
- [ ] ローカルで `python -m http.server 3000` または VS Code Live Server で動作確認

詳細手順: [GitHub セットアップガイド](01_Docs/github_setup.md)

---

## ✅ 完了

- [x] **2026-04-23** プロジェクトフォルダ構成の決定と作成
- [x] **2026-04-23** README.md、step1_plan.md、design_notes.md 等のドキュメント整備
- [x] **2026-04-23** CLAUDE.md と TASKS.md のセットアップ
- [x] **2026-04-23** Docsify によるドキュメントサイト化（index.html, _sidebar.md, _coverpage.md）
- [x] **2026-04-23** .gitignore（Unity用）の作成
- [x] **2026-04-23** GitHub セットアップガイド、ドキュメントサイト運用ガイドの作成

---

## 💡 アイデア保管庫（いつかやりたい）

- キャラクターの衣装チェンジ機能
- 複数の相手キャラ（体格・スタイル違い）
- パンチ数・消費カロリー推定の可視化
- BGM を好きな曲に差し替える機能
- 日本語ボイス／かけ声
- ジム背景の切り替え（本格ジム／ファンタジー空間）
- オンライン対戦（遠い将来）

---

## 📝 使い方

- タスクを始めるとき: そのタスクを上の方に移す or 印を付ける
- 完了したとき: 「✅ 完了」セクションに日付付きで移す
- 新しいアイデアは一旦「💡 アイデア保管庫」に入れる（いま追うと散る）
- 週1くらいで棚卸しして、古いタスクや不要なアイデアを整理する
