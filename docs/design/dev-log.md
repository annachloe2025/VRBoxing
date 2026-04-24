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

---

## 2026-04-24（その2）— 演出フェーズ1日目

### やったこと

- **サンプル部屋をボクシングリングに置き換え** 🥊
    - `Assets/Editor/BoxingRingCreator.cs` を実装
    - Unity メニュー `VRBoxing > Create Boxing Ring` で一発生成
    - 6m × 6m のキャンバス + 4本のポスト + 12本のロープ（3段 × 4辺）
    - URP / Built-in 両対応のマテリアルを自動生成（`Assets/Materials/Ring/`）
    - `Delete Boxing Ring` メニューも用意（やり直し可）
- **ヒット音のバリエーション化**:
    - `HitReceiver.GenerateHitSoundPool()` で 5 種類の被弾音をパラメータ（基音周波数 70〜110Hz、減衰速度、ノイズ量、長さ）をランダムに振って生成
    - 直前と違うインデックスを優先して選ぶ「同音連続回避」ロジック
    - 再生時にピッチを ±0.12 半音揺らし + 強く殴るほど少し高めに（毎回音が違って聞こえる）
- **ヒットエフェクト（パーティクル）**:
    - `Assets/Scripts/HitEffect.cs` を実装
    - `HitReceiver.Awake()` で `AddComponent<HitEffect>()` するので、ユーザー操作は完全に不要
    - `PunchDetector` が `other.ClosestPoint(拳の位置)` で命中座標を計算し、`HitReceiver.TakeHit(vel, speed, hitPoint)` に渡す
    - 命中位置で **小さい白い丸粒が 50〜120個ランダムに弾ける**
    - ParticleSystem / マテリアル / テクスチャを全て実行時に自動生成（事前セットアップゼロ）

### 詰まったところ

- **AddComponent 直後の ParticleSystem は自動再生中**
    - `Setting the duration while system is still playing` エラーが出て一部設定が弾かれる
    - 解決: `ps.Stop(true, StopEmittingAndClear)` を直後に呼んで完全停止してから設定変更
- **`Resources.GetBuiltinResource<Texture2D>("Default-Particle.psd")` が返ってこない**
    - Unity バージョン・パッケージ構成で取れないことがある
    - 解決: 64×64 の柔らかい円テクスチャを `SetPixel` で実行時自作
- **URP でパーティクルが四角く表示される**
    - `_Surface = 1` にするだけでは透過モードに入らない
    - 解決: `_SURFACE_TYPE_TRANSPARENT` キーワードを `EnableKeyword` + `_SrcBlend` / `_DstBlend` / `_ZWrite` を明示

### 最終的な HitEffect パラメータ（VR 内の手応えで決めた）

- 粒数: 50〜120 のランダム
- 大きさ: 5〜13mm（かなり細かい）
- 初速: 1.5 m/s（広がりすぎない）
- 寿命: 0.1〜0.22 秒（短くシャープに）

### メモ

- 3 つの「演出」（リング・音バリエーション・パーティクル）が揃って、**VR 内での「殴ってる感」がぐっと本物に近づいた**
- すべて自動生成 or メニューから1クリックで済む設計。ユーザーの Unity Editor 操作は最小限

### 次やること

- **拳の見た目（グローブ化）**: 今はコントローラー素のままなので、赤いボクシンググローブっぽい形に差し替え
- 待機アニメ（Mixamo）
- パンチカウンター UI

---

## 2026-04-24（その3: グローブ装着の仕組み）

### やったこと

- **ボクシンググローブの装着システム**を実装
    - `GloveProfile` (ScriptableObject): モデルごとの装着設定（スケール・回転・位置・メッシュ選択・左右振り分け）を1アセットに収めた
    - `GloveEquipper` (Editor): 両手の `PunchDetector` を自動検出して、プロファイルに従ってグローブをインスタンス化
    - `GloveEquipperWindow` (Editor): メニュー `VRBoxing > Equip Gloves From Profile...` で GUI から装着・取り外し
    - 片手（Lのみ）モデルを右手にも使えるよう、**負スケール鏡映モード**を実装
    - **左右別回転モード**を追加（鏡映だけでは向きが揃わないモデル向け、1段目 → 2段目の順で世界座標回転を適用）
    - 使っているモデル: Sketchfab の無料ボクシンググローブ（片手の L.fbx、赤いレザー系）

### 詰まったところ

- **装着してもグローブが見えない**: Frustum culling で描画されていなかった
    - 原因: FBX 由来メッシュの `bounds.size` がほぼ 0（sqrMagnitude ≈ 1.24e-05）
    - 解決: `FixSourceMeshBoundsIfNeeded` でインポート時に `isReadable = true` にして `RecalculateBounds()`、さらに manual で 1m 立方に bounds を拡張（カリング回避）
- **グローブが頭の上に出る**: モデルのピボットと頂点中心がズレていた（スケール 100 倍かけた分、小さなズレが大きく効いた）
    - 最初の試み: `Renderer.bounds.center` を使った自動センタリング → 失敗（前段で bounds を (0,0,0) center に上書きしてた）
    - 最終解決: `ComputeMeshVertexCenterWorld` で頂点データから直接センターを計算するよう変更
- **手の向きが合わない**: 初期の共通 `rotationEuler = (-90, 0, 0)` では両手がおかしな向きに
    - 解決: `useHandedRotation` フラグ + 左右別の2段階回転に変更
    - 最終: **右手 Y+90°, 左手 Y-90°**（第2回転は無しでOKだった）
- **positionOffset が効かない**: `AutoCenterOnFist` が offset を相殺していた
    - 解決: 自動センタリングを先に実行 → そのあと positionOffset を `+=` で乗せる順序に変更

### 最終設定（赤グローブ プリセット）

- `scale = 100.0`（FBX が mm 単位級で小さすぎた）
- `mirrorLeftFromSingleMesh = true`（片手 L モデルから右手を鏡映生成）
- `useHandedRotation = true`
- `rightRotationFirstEuler = (0, 90, 0)` / second 無し
- `leftRotationFirstEuler = (0, -90, 0)` / second 無し
- `positionOffset = (0, 0, -0.1)` — グローブを手首側に 10cm 引く

### メモ

- 新しいグローブを追加しても、このシステム（GloveProfile）で吸収できる設計にしてある
- ただし「別モデルでも 0 コンフィグ」ではなく、スケール・回転・位置は毎回ある程度調整が必要
- 一度プリセットを作ってしまえば、Remove → Equip のサイクルで即テスト可能

### 次やること

- 待機アニメ（キャラが立ちっぱなしで寂しい）
- パンチカウンター / カロリー表示（UI）
- 拳が空を切るときの音（スッ、ヒュッ）
- のけぞり方向の改良（部位で変える）

---

## 2026-04-24（その3）— 待機アニメ適用

### やったこと

- VRoid キャラに Mixamo の Idle アニメを適用するパイプラインを構築
    - **VRoid (VRM)** → Blender（VRM Addon for Blender）で読み込み
    - Body/Face/Hair のみ選択 → **メッシュ限定 FBX** 書き出し（スケール 1.0, -Z Forward / Y Up）
    - Mixamo にアップロード → Auto-Rigger（5マーカー配置）でリギング
    - Idle アニメ選択 → **FBX for Unity / Without Skin / 30fps** で DL
    - Unity の `Assets/_Project/Animations/` に配置（旧 xbot アニメは削除）
- Unity 側でアニメ Clip を調整して**正面向き＋その場待機**に
    - `boxing_Idle.fbx` → Inspector → Animation タブ
    - Root Transform Rotation: ✅ Bake Into Pose / Based Upon: **Original**
    - Root Transform Position (Y) / (XZ): ✅ Bake Into Pose
    - Apply

### 詰まったところ

- **Blender 5.0 で VRM Addon のインポート時 TypeError**
    - Extensions.blender.org 版が Blender 5.0 未対応（承認ラグ）
    - 解決: Extensions 版を無効化 → GitHub から最新 zip をレガシー Add-on として導入
- **Unity FBX Exporter での書き出しが Mixamo で Auto-Rig エラー**
    - `ERROR occured on animate: Unknown error while generating motion`
    - 原因: VRoid 由来の余計なボーンがアーマチュアに残って Mixamo が混乱
    - 解決: Unity ルートを捨て、Blender でメッシュ限定 FBX にする方式へ切替
- **Mixamo Auto-Rig の「Please place all markers」**
    - 原因: 5つのマーカー（あご / 手首 L / R / ひじ L / R）全部をキャラに配置する前に Next を押していた
- **Unity でキャラが横を向く**
    - 原因: Mixamo 出力 FBX のルートに Y 回転が乗っていた
    - 解決: Root Transform Rotation を Original + Bake Into Pose（上記の通り）

### メモ

- 微妙にまだ体軸が傾いてるが、演出調整フェーズで詰まっても困るので **ここでは妥協**
    - 後で気になれば Animation の Offset 値で微調整可能（0 → ±数度）
- Characters フォルダのファイル役割を整理：`.blend`（編集用）/ `.fbx`（Mixamo 再アップ用）/ `.vrm`（Unity 取り込み）/ `.vroid`（VRoid 編集用）
- `.blend1`（Blender 自動バックアップ）は `.gitignore` に追加済みだが、ディスク上のゴミは手動削除した

### 参考URL

- [Mixamoのアニメーションの挙動がおかしくなる時の解決方法 - Zenn](https://zenn.dev/daichi_gamedev/articles/feec966b92d59a)
- [MixamoのアニメーションをUnityに取り込んで動きが変だった時の対処 - Qiita](https://qiita.com/kazuma_f/items/76686bc5b23ffd8f75ca)
- [VroidアバターにMixamoアニメーションを適用する - Zenn](https://zenn.dev/omini/articles/b8218b83b18b41)

### 次やること

- パンチカウンター / カロリー表示（UI）← 次
- 拳が空を切るときの音（スッ、ヒュッ）
- のけぞり方向の改良（部位で変える）
- 傾きが気になるようなら Offset 微調整でリトライ
