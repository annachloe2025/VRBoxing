# いまのタスク

アクティブなタスクと完了したタスクを追跡するページ。

## 🟢 アクティブ（現在取り組んでいる）

### 演出・調整フェーズ ← 🎯いまここ

- [x] **2026-04-24** サンプル部屋 → ボクシングリングに置き換え（`BoxingRingCreator.cs`）🥊
- [x] **2026-04-24** ヒット音のバリエーション化（5種ランダム + ピッチ揺らし）
- [x] **2026-04-24** ヒットエフェクト（白い丸粒が命中位置で弾ける `HitEffect.cs`）✨
- [x] **2026-04-24** **拳にボクシンググローブを装着**（`GloveProfile` + `GloveEquipper` で赤いグローブ両手装着）🥊
- [x] **2026-04-24** **キャラクターの待機アニメ適用**（VRoid → Blender でメッシュ書き出し → Mixamo で再リギング＆Idle DL → Unity で `Root Transform Rotation: Original + Bake Into Pose` で正面向き調整）🫁
- [x] **2026-05-02** **VRM Add-on for Blender v3.26.8 を Blender 5.1.1 にインストール**（Extension版）
- [x] **2026-05-02** **Mixamo用 FBX 自動エクスポート機構作成**（`scripts/export_for_mixamo.py` + `.bat`、ダブルクリックで書き出し / D&Dで他キャラ対応）
- [x] **2026-05-03** **Mixamoでボクシング系アニメをDL**（jab / hook / straight の3本、Without Skin / FBX Binary）
- [~] **複数anim FBX → NLA → 1FBXへ統合スクリプト**（不要になった: Editor で Avatar Copy + 個別FBX保持の方式に変更）
- [x] **2026-05-02** **パンチカウンター実装**（`PunchEvents` / `PunchCounter` / `Editor/PunchCounterCreator`、HUD/ビルボード/固定壁の3モード切替、リング後方の固定壁ビルボードを採用）
- [x] **2026-05-02** **当たり判定を頭部・腹部に分割**（`HitZone` / `Editor/HitZoneSetup` でメニュー一発配置、ボーン名から自動検出）
- [x] **2026-05-02** **コライダーをボーン追従**（`BoneFollower` を LateUpdate で適用、Animator 出力後に位置を上書き）
- [x] **2026-05-02** **部位別のけぞり**（頭=Head回転 / 腹=Spine回転+位置移動、LateUpdate で Animator 出力に上乗せ）
- [x] **2026-05-02** **のけぞり方向の改良**（殴られた部位で変わるように）— 頭=Head回転 / 腹=Spine回転+移動 で完了
- [x] **2026-05-03** **体の向きをプレイヤーに追従**（`BodyFaceAtPlayer` で Yaw 回転、HeadLookAtPlayer の IK と並走）
- [x] **2026-05-03** **HP/ダメージシステム**（`EnemyHealth` で Head/Body 別HP、`EnemyHealthBoard` で表示。直近ダメージ・KO 表示）
- [x] **2026-05-03** **拳のヒット後クールダウン**（0.5秒、片手ごとに独立。多重ヒット防止）
- [x] **2026-05-03** **ヒットFXに強弱**（音量・ピッチ・パーティクル粒数を damage 相当値で変える）
- [x] **2026-05-03** **エフェクト色の段階化**（intensity しきい値型 1=緑/2=黄/4=橙/6=赤、線形補間）
- [x] **2026-05-03** **Thrill of the Fight 風速度計算**（ピーク速度 + 方向補正 45°/90°/×0.33）
- [x] **2026-05-03** **Mixamoアニメ取り込み自動化**（`MixamoAnimImporter` で Humanoid + Avatar コピーを一括設定）— jab/hook/straight 取り込み完了
- [x] **2026-05-03** **EnemyAnimator 自動生成**（`EnemyPunchAnimatorCreator`、Idle / Jab / Hook / Straight、IK Pass有効）
- [x] **2026-05-03** **EnemyPunchController（敵AI）**（1.5〜3.5秒で Jab/Hook/Straight ランダム発射、スタミナ管理、KO中停止）
- [x] **2026-05-03** **PlayerHealth + PlayerHitZone**（HMD直結の頭/体被弾判定、HP200）
- [x] **2026-05-03** **EnemyFist + Coordinator**（拳の Trigger Collider を Punchステート進行度 0.15-0.55 で ON、Kinematic Rigidbody で Trigger 発火）
- [x] **2026-05-03** **PlayerHealthBoard**（被弾フィードバックボード、リング左奥）
- [x] **2026-05-03** **HMDシェイク**（`Application.onBeforeRender` で Camera 自身に加算、Locomotion と非競合）
- [x] **2026-05-03** **赤ビネット**（HitVignette、Camera子に円形テクスチャ自動生成）
- [x] **2026-05-03** **HitFaceReaction にベース表情**（戦闘中の Angry 顔常時、被弾で Sorrow が重なる）
- [ ] **消費カロリー表示**（UI、PPMから推定）
- [ ] **パンチ音**（拳が空を切る音、スゴ味）
- [ ] **KO 後のリトライ／リセットUI**（現状は KO 表示だけで何も起きない）
- [ ] **ガード判定**（プレイヤー拳/前腕で敵パンチをブロック、ダメージ減）
- [ ] **拳の IK 補正**（敵パンチがプレイヤーの頭/体を狙う、Animation Rigging）
- [ ] **AI 高度化**（距離管理・ステップイン・コンボ）

### ボクシング実装フェーズ（完了 ✅）

- [x] **2026-04-24** 両手のコントローラーに「拳」コライダーを付ける
- [x] **2026-04-24** パンチ速度を測って、閾値以上で「殴った」判定を出す
- [x] **2026-04-24** キャラ（またはサンドバッグ）を殴った時のリアクション（のけぞり・効果音）
- [x] **2026-04-24** 初めて「女性キャラを殴れた」状態を達成 🎉

### 体のケア（並行）

- [ ] **Knuckles 用の手首ストラップを用意**  
    優先度: 高（安全のため、ボクシングは激しく振る）  
    純正ストラップ＋サードパーティの「Knuckle Straps」などが安心

## ✅ 完了

- [x] **2026-04-23** プロジェクトフォルダ構成の決定と作成
- [x] **2026-04-23** README.md、ステップ1計画書、設計メモ等のドキュメント整備
- [x] **2026-04-23** CLAUDE.md と TASKS.md のセットアップ
- [x] **2026-04-23** Docsify によるドキュメントサイト化
- [x] **2026-04-23** .gitignore（Unity用）の作成
- [x] **2026-04-23** GitHub リポジトリ作成＆初回push（`annachloe2025/VRBoxing`）
- [x] **2026-04-23** GitHub Pages 公開
- [x] **2026-04-23** update.bat で更新を自動化
- [x] **2026-04-23** Docsify → MkDocs + Material へ移行
- [x] **2026-04-23** MkDocs テーマ調整（ヘッダー深めローズ、ダーク背景をピンク寄りの柔らかい色に）
- [x] **2026-04-23** Unity Hub 確認（2022.3 と 6.2 インストール済み）
- [x] **2026-04-23** Unity 2022.3.62f1 LTS で VR テンプレート使って新規プロジェクト作成
- [x] **2026-04-23** OpenXR + XR Interaction Toolkit セットアップ（VR テンプレで自動完了）
- [x] **2026-04-23** Valve Index Controller Profile 追加確認（VR テンプレで自動登録済み）
- [x] **2026-04-23** **SteamVR 起動 → Unity Play → Valve Index で SampleScene に入れることを確認** 🎉
- [x] **2026-04-23** VRoid Studio で最初の女性キャラを作成・VRM エクスポート
- [x] **2026-04-23** UniVRM 0.x インストール、VRM を VRM 0.x 形式（テクスチャ2048）で書き出し直して取り込み成功
- [x] **2026-04-23** キャラを `Assets/_Project/Characters/` に整理、Prefab をシーンに配置
- [x] **2026-04-23** **VR 内で自作の女性キャラを目の前に立たせることに成功** 🎯🎉
- [x] **2026-04-24** キャラに Capsule Collider を配置、Fist GameObject に Sphere Collider + Rigidbody セットアップ
- [x] **2026-04-24** `PunchDetector.cs` 実装（速度計測、しきい値判定、HitReceiver フィルタ）
- [x] **2026-04-24** `HitReceiver.cs` 実装（のけぞりリアクション、音用フック、速度によるスケーリング）
- [x] **2026-04-24** **ステップ1 完了: 女性キャラを VR で殴ってログ＆リアクションが返る状態を達成** 🥊🎉

## 💡 アイデア保管庫（いつかやりたい）

- キャラクターの衣装チェンジ機能
- 複数の相手キャラ（体格・スタイル違い）
- パンチ数・消費カロリー推定の可視化
- BGM を好きな曲に差し替える機能
- 日本語ボイス／かけ声
- ジム背景の切り替え（本格ジム／ファンタジー空間）
- オンライン対戦（遠い将来）

## 📝 使い方

!!! tip "タスク管理のルール"

    - タスクを始めるとき: そのタスクを上の方に移す or 印を付ける
    - 完了したとき: 「✅ 完了」セクションに日付付きで移す
    - 新しいアイデアは一旦「💡 アイデア保管庫」に入れる（いま追うと散る）
    - 週1くらいで棚卸しして、古いタスクや不要なアイデアを整理する
