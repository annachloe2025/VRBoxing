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

---

## 2026-04-23（その2）

### やったこと

- MkDocs Material のテーマを調整（ライトモードのヘッダーを深めのローズに、ダークモードの背景をピンク寄りの柔らかいダークに）
- `docs/stylesheets/extra.css` を追加、`mkdocs.yml` に `extra_css` を登録
- Unity 2022.3.62f1 LTS で **VR テンプレート** を使って新規プロジェクト `03_Unity_Project` を作成
- OpenXR + XR Interaction Toolkit が VR テンプレートに含まれていたので手動インストール不要
- OpenXR の Interaction Profiles に **Valve Index Controller Profile が最初から登録済み** だったことを確認
- Project Validation クリア
- SteamVR 起動 → Unity で ▶ Play → **Valve Index で SampleScene に入れることを確認** 🎉

### メモ

- **ここまでで VR 開発の土台は完成**。あとは「殴れる女性キャラ」を実装していくだけ
- VR テンプレートは `OpenXR + XR Interaction Toolkit + Input System + サンプルXR Rig` を全部セットアップしてくれるので、ゼロから手動設定するより圧倒的に早い
- `update.bat` の改行コード問題を修正（LF → CRLF、Python で書き直し）
- `update.bat` 内の `2>/dev/null` を `2>nul` に修正（Windows cmd 用）

### 次やること

- **VRoid Studio をインストール**して最初のキャラを作る（デフォルトのままでもOK、とにかく VRM を吐き出すところまで）
- Unity に UniVRM パッケージを入れて VRM を読み込む
- Step1 の実装: 女性キャラを「殴れるサンドバッグ」として配置、コライダー + リアクション

---

## 2026-04-23（その3）— 大躍進の日

### やったこと

- **VRoid Studio で最初の女性キャラを作成** → VRM エクスポート
    - 最初は VRM 1.0 形式で書き出されてしまい Unity に UniVRM 0.x しか入ってなかったので変換不可 → VRM 0.x 形式で書き出し直した
    - テクスチャサイズを 2048 に落として書き出し直した（デフォルトの 4K だと Unity の上限に引っかかる）
- **Unity に UniVRM 0.x をインストール**（`Assets > Import Package > Custom Package...`）
- **VRM を `Assets/_Project/Characters/` に取り込み**、Prefab 化
- **Prefab をシーンに配置**（Position `(0, 0, 2)`、Rotation Y 軸 180度）
- **VR 内で自作の女性キャラが立っているのを確認** 🎯🎉

### 詰まったところと解決策

- **`RenderTexture.Create failed: requested size is too large.`** が Console にスパム
    - 犯人は `VRMLookAtHeadEditor.OnPreviewGUI`（目線プレビューの描画）
    - Inspector が黒塗りになって Transform が編集できない状態に
    - **解決**: Inspector を **Debug モード** に切り替え（タブ右クリック or `⋮` メニューから）
- **Debug モードだと Rotation が Quaternion（4値）表示**
    - Y軸180度 = `(X=0, Y=1, Z=0, W=0)`
    - もしくは Scene ビューの回転ギズモ（`E` キー）で直感的に回すのが楽

### メモ

- **今日でステップ1の「環境構築〜キャラ配置」までが完了**
- モチベの核になる「自作の女性キャラを自分の空間に置いて立たせる」が達成できた
- 次回からはいよいよ「殴る」仕組みの実装に入れる

### 次やること

- **パンチ判定の実装**: コントローラー（両手）に「拳」コライダー付きの空オブジェクトをアタッチ
- キャラ側にもコライダーを配置（全身ざっくりカプセル1つでも可）
- コントローラーの速度を取ってしきい値以上で「殴った」判定
- 殴った時のリアクション（のけぞりアニメ or ヒットエフェクト + 効果音）
- ここまで出来ると「初めて女性キャラを殴れた」瞬間が来る 🥊

---

## 2026-04-24 — ステップ1 完了の日 🥊🎉

### やったこと

- **コライダーのセットアップ**:
    - キャラのルートに Capsule Collider（Center Y=0.9, Height=1.8, Radius=0.25）
    - 両手の Controller の子に `Fist` という空オブジェクトを作成、Sphere Collider (Trigger, Radius=0.08) + Kinematic Rigidbody
- **`PunchDetector.cs` の実装**（`Assets/Scripts/PunchDetector.cs`）:
    - `FixedUpdate` で前フレームとの位置差から速度を計算（Transform 移動のコントローラーは Rigidbody.velocity 使えないため）
    - `minPunchVelocity`（既定 1.5 m/s）以上の衝突でパンチ判定
    - 最初の1フレームは `prevPosition=(0,0,0)` の影響で速度が爆発するため初期化フラグでスキップ
    - `HitReceiver` を持つ相手だけ有効にして誤検出を排除（自分の XR Rig を殴ってしまう問題の解決）
- **`HitReceiver.cs` の実装**（`Assets/Scripts/HitReceiver.cs`）:
    - `TakeHit(velocity, speed)` でコルーチンののけぞりアニメ起動
    - 水平成分のみ使ってキャラが倒れないように
    - 速度に応じてのけぞり距離をスケール（1.5 m/s 相当で等倍、強く殴るほど大きく反応）
    - `AudioSource` と `hitSound` のフック（音は後で差し替え可能）

### 詰まったところ

- **初期化時に 65 m/s の幻パンチ**が1発出る
    - 原因: `Start()` 前の `prevPosition` が初期値のまま、初回の `FixedUpdate` で一気に吹っ飛ぶ
    - 解決: `initialized` フラグで初回の `FixedUpdate` をスキップする
- **自分の XR Rig (`XR Origin (XR Rig)`) を殴ってしまう誤検出**
    - 原因: XR Origin 自体にコライダーがあり、Fist の Trigger が反応してた
    - 解決: `OnTriggerEnter` で `HitReceiver` を持たない相手は無視するように
- **キャラのルートが一瞬分かりづらい**（VRM は中に `Root` ボーンがあるため）
    - 正解は「Prefab インスタンスのトップ（Capsule Collider を付けた GameObject）」

### VR 内での手応え

- 両手でパンチ連打、速度 1.5〜5.8 m/s のレンジで判定
- 強く殴るほど大きくのけぞる
- 小さい動きは「軽く触れた」扱いになってパンチ扱いされない（リアル挙動）

### メモ

- 認知負荷対策として、スクリプト作成は Claude 側で直接 `Assets/Scripts/` に書き込み、ユーザーは **Inspector にドラッグ or Add Component の1操作のみ**で済むフローにした

### 次やること（演出・調整フェーズ）

- ヒットエフェクト（パーティクル）
- ヒット音（AudioClip を拾ってきて `HitReceiver.hitSound` に設定）
- パンチカウンター／消費カロリー表示（UI）
- キャラの待機アニメ（ブレスとか、立ち姿のリアル感）
- のけぞり方向の改良（殴った部位で方向が変わるように）
- 手を拳の見た目にする（今はコントローラーのまま）
