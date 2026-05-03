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

## 2026-05-03（その2）— 敵AI（パンチ撃ち返し） + プレイヤー被弾フィードバック

### やったこと

このセッションで「**プレイヤーが殴る → 敵が殴り返す → プレイヤー被弾 → ダメージ・揺れ・赤ビネット**」の双方向ループを完成。

#### 1. Mixamo アニメインポートの自動化
- `jab.fbx` / `hook.fbx` / `straight.fbx` を Mixamo からダウンロードして `Assets/_Project/Animations/` に配置
- **`Assets/Editor/MixamoAnimImporter.cs`** 新規 — メニュー [VRBoxing > Configure Mixamo Animations]
    - 4FBX 一括設定: Humanoid + Avatar Definition (boxing_Idle.fbx の Avatar をコピー)
    - Loop Time: idle=ON、パンチ=OFF
    - Root Transform 全 Bake Into Pose（その場再生）

#### 2. EnemyAnimator Controller の自動生成
- **`Assets/Editor/EnemyPunchAnimatorCreator.cs`** 新規
    - メニュー [VRBoxing > Create Enemy Punch Animator] で Controller を1クリック生成
    - パラメータ: Trigger "Punch" + Int "PunchType" (0=Jab, 1=Hook, 2=Straight)
    - 構造: Idle (default) / Jab / Hook / Straight、Any State → 各 Punch、Punch → Idle (Exit Time 0.9)
    - **重要**: Base Layer の `iKPass = true` を設定（HeadLookAtPlayer の OnAnimatorIK が呼ばれるように）
    - メニュー [VRBoxing > Assign Enemy Animator] でキャラの Animator にアサイン

#### 3. EnemyPunchController（敵 AI）
- **`Assets/Scripts/EnemyPunchController.cs`** 新規
    - 1.5〜3.5 秒ランダム間隔でパンチ発射、Jab/Hook/Straight を重み付き抽選
    - スタミナ: max 100、1パンチ -20、毎秒 +15 回復、25未満で休憩
    - KO 中（EnemyHealth.IsKnockedOut）はパンチ停止
    - Editor [VRBoxing > Add Enemy Punch Controller] で1クリックアタッチ

#### 4. プレイヤー側被弾判定
- **`Assets/Scripts/PlayerHealth.cs`** — HP 200 デフォルト、TakeDamage で減算、KO 判定
- **`Assets/Scripts/PlayerHitZone.cs`** — マーカー（Head / Body）
- **`Assets/Editor/PlayerHitZoneSetup.cs`** — メニュー一発で Camera.main に PlayerHealth + 子に Sphere(Head)/Capsule(Body) 配置

#### 5. 敵の拳（攻撃側コライダー）
- **`Assets/Scripts/EnemyFist.cs`** — 拳ボーン追従の Trigger コライダー
    - 速度ベースのダメージ（base 8 + speed×4、max 30）
    - 1サイクルで1回しかヒットしない仕組み（hitThisCycle フラグ + Coordinator がリセット）
- **`Assets/Scripts/EnemyFistsCoordinator.cs`** — Animator のステート見て、Punch (Jab/Hook/Straight) の進行度 0.15〜0.55 だけ拳を有効化
    - Animation Event を仕込まずに「振り中だけ判定」を実現
- **`Assets/Editor/EnemyFistsSetup.cs`** — 敵キャラの LeftHand/RightHand ボーンを名前検出 → 子に EnemyFist + BoneFollower 配置 + Coordinator アタッチ

#### 6. 被弾フィードバック3点セット
- **`Assets/Scripts/PlayerHealthBoard.cs`** — プレイヤーHP表示ボード（PunchCounter Billboard の左隣 -4,3,7）
- **`Assets/Scripts/HMDShake.cs`** — 被弾時のカメラ揺れ
- **`Assets/Scripts/HitVignette.cs`** — 視界の縁が赤くフェード（中央透明・外周赤の円形テクスチャ実行時生成）
- **`Assets/Editor/HitFeedbackSetup.cs`** — 3つ一括メニュー [VRBoxing > Setup Hit Feedback (Board + Shake + Vignette)]

#### 7. 表情リアクション（追加）
- 既存の `HitFaceReaction.cs` に `baseExpression` (常時オン表情) フィールド追加 → 戦闘中の Angry 顔を実現

### 詰まったところ

- **被弾ログが出ない問題**: Console に `💢 プレイヤー被弾!` が出ない
    - 原因1: ユーザーがシーン保存していなかった（Ctrl+S 押し忘れで .unity に書き戻されてなかった）→ シーンファイル直接 grep で確認
    - 原因2: **Trigger イベントは「片方に Rigidbody」が必要**。EnemyFist と PlayerHitZone のどちらにも Rigidbody が無く、OnTriggerEnter が発火しなかった
    - 解決: EnemyFist.Awake で Kinematic Rigidbody を自動付与（isKinematic=true, useGravity=false, ContinuousSpeculative）
- **HMDShake で「被弾後にプレイヤーが空中に移動」する問題**
    - 原因: Camera の親（Camera Offset）の localPosition を直接書き換えていた → VR Locomotion システムと競合してプレイヤー位置が浮く
    - 解決: `Application.onBeforeRender` で **Camera 自身**に一時オフセットを加算する方式に変更
        - HMD トラッキングが Camera を毎フレーム上書きするため、加算しても累積しない
        - Camera Offset には一切手を出さないので Locomotion と完全に独立
- **「軽く触れた」ログのスパム**: プレイヤーの拳が敵の拳コライダーに触れて誤判定
    - 解決: PunchDetector で `other.GetComponent<EnemyFist>() != null` なら早期 return
- **Animator Controller 自動生成で IK Pass が OFF だった**: HeadLookAtPlayer の OnAnimatorIK が呼ばれず、頭がプレイヤーを向かなくなった
    - 解決: EnemyPunchAnimatorCreator で `controller.layers[0].iKPass = true` を明示

### 双方向のループが完成

| プレイヤー → 敵 | 敵 → プレイヤー |
|---|---|
| パンチ判定 (PunchDetector) | EnemyPunchController が定期発射 |
| 部位別ダメージ (HitZone) | プレイヤー部位判定 (PlayerHitZone) |
| 敵 HP 減算 (EnemyHealth) | プレイヤー HP 減算 (PlayerHealth) |
| ボード表示 (EnemyHealthBoard) | ボード表示 (PlayerHealthBoard) |
| のけぞり + 表情変化 | HMDシェイク + 赤ビネット |

### 主要な追加スクリプト

- `Assets/Scripts/PlayerHealth.cs`
- `Assets/Scripts/PlayerHitZone.cs`
- `Assets/Scripts/PlayerHealthBoard.cs`
- `Assets/Scripts/EnemyPunchController.cs`
- `Assets/Scripts/EnemyFist.cs`
- `Assets/Scripts/EnemyFistsCoordinator.cs`
- `Assets/Scripts/HMDShake.cs`
- `Assets/Scripts/HitVignette.cs`
- `Assets/Editor/MixamoAnimImporter.cs`
- `Assets/Editor/EnemyPunchAnimatorCreator.cs`
- `Assets/Editor/PlayerHitZoneSetup.cs`
- `Assets/Editor/EnemyFistsSetup.cs`
- `Assets/Editor/EnemyPunchControllerSetup.cs`
- `Assets/Editor/HitFeedbackSetup.cs`

### デバッグ手法のメモ

- 「シーンに保存されているコンポーネント」を確認するには、`.unity` ファイルを GUID で grep するのが速い
- スクリプトの GUID は `.cs.meta` の `guid:` 行から取得できる
- 今回は `e7ec493d93c4e75449267fa8d8280838` (PlayerHealth) などで grep して、シーン未保存の状態を即特定できた

### 次やること

- **ガード判定**（プレイヤーの拳/前腕で敵パンチをブロック → ダメージ減）
- **Hapticフィードバック**（Knuckles 振動、被弾時 + ヒット時）
- **KO演出**（プレイヤー or 敵がKO時の処理。リセットUI）
- **AI の高度化**（プレイヤー位置でステップイン、距離による狙い分け）
- **拳に IK 補正**（プレイヤー頭部を狙う、Animation Rigging）
- **キャロリー表示** UI

### 参考

- [Thrill of the Fight - Punch Power](https://steamcommunity.com/app/494150/discussions/0/1326718197225193613/) — 速度+方向補正+mass 倍率の元ネタ
- Unity Trigger イベントの「片方に Rigidbody 必要」は VRゲーム系トラブルでよく遭遇

---

## 2026-05-03 — HP/ダメージ + ヒットFX強弱 + Thrill of the Fight 風速度計算

### やったこと

- **EnemyHealth システム**（`Assets/Scripts/EnemyHealth.cs` 新規）
    - Head HP / Body HP を別々に保持（デフォルト 500 / 800）
    - PunchEvents 購読でダメージ計算: `speed × damagePerSpeed`（min/max でクランプ）
    - 部位倍率は最終的に **両方 1.0 に統一**（読みやすさ優先、ユーザー要望）
    - 自分宛のパンチか `receiverName` で判定（複数敵対応）
    - KO 判定（Head と Body 両方0で発火）、static event で疎結合に通知
- **EnemyHealthBoard**（`Assets/Scripts/EnemyHealthBoard.cs` 新規）
    - HUD/ビルボード/固定壁の3モード（PunchCounter と同じ流儀）
    - Head/Body の HP数値 + ASCII バー（■□で描画）+ 直近ダメージ表示（2秒フェード）
    - KO になったら赤字で "K.O." 表示（直近ダメージより優先）
    - リング後方の **PunchCounter Billboard の右隣** (+4, 3, 7) に固定壁配置
- **`Assets/Editor/EnemyHealthSetup.cs` 新規**
    - メニュー `VRBoxing > Setup Enemy Health` で「キャラに HP 追加 + シーンに Board 配置」を1クリック
    - 既存 EnemyHealth がある時は「リセット」ダイアログで HP値と部位倍率を一括復元
- **ヒットFX に強弱を追加**（`HitReceiver.cs` 改修）
    - PlayHitFx に bodyPart を渡し、部位倍率と速度から「ダメージ相当値 (dmgEq)」を計算
    - 音量・ピッチ・パーティクル強度を全て dmgEq ベースに切替
    - 部位倍率は最終的に全部1.0統一（ユーザーが混乱しないように）
- **HitEffect の色段階化**（`HitEffect.cs` 改修）
    - intensity に応じて 🟢緑 → 🟡黄 → 🟠橙 → 🔴赤
    - しきい値型（1=緑, 2=黄, 4=橙, 6=赤）で線形補間。Inspector で各しきい値・色を編集可能
    - ParticleSystem.EmitParams.startColor で1ヒット分の粒色を一括指定（過去の粒に影響しない）
    - 粒数の最大を 120 → 180 に増量
- **拳のヒット後クールダウン**（`PunchDetector.cs` 改修）
    - ヒット成立後、その拳のコライダーを 0.5 秒間 enabled=false に
    - 1発のパンチで連続ヒット → ダメージ二重計上を防止
    - 左右独立（左右別 PunchDetector インスタンスなので自然に独立）
- **Thrill of the Fight 風の速度計算**（`PunchDetector.cs` 改修）
    - **ピーク速度方式**: 直近6フレーム（約120ms）の最大速度ベクトルを採用 → 「全力で振った感」が出る
    - **方向補正**: 拳の前方向(+Z) と速度ベクトルの角度差で減衰
        - 0〜45° → ×1.0（補正なし）
        - 45〜90° → ×1.0 → ×0.33 線形補間
        - 90°以上 → ×0.33（最大減衰）
    - 実効速度 = ピーク速度 × 角度補正 を HitReceiver / EnemyHealth / PunchEvents に渡す
    - 「ちゃんと突き出した」パンチが評価され、「振り回し」だけは弱判定になる
- **体の向きをプレイヤーに追従**（`Assets/Scripts/BodyFaceAtPlayer.cs` 新規 + `Editor/BodyFaceAtPlayerSetup.cs`）
    - `LateUpdate` で Camera.main 方向に Yaw だけ回転
    - デッドゾーン 5°、回転スピード 90°/秒、KeepTurningUntilFacing で「回り始めたら正対するまで止まらない」
    - HeadLookAtPlayer (IK LookAt) は視線追従にとどまるので、体軸ごとに向き直すのは別コンポーネントに分離

### 詰まったところ

- **EnemyHealthBoard の位置調整**: 最初は左 (-4, 3, 7) に置いたが、ユーザーから「右に」要望
    - 解決: (+4, 3, 7) に。Editor の Setup を「既存ボードがあっても位置だけ再設定」する処理に改修
- **エフェクト色の補間範囲**: 線形 0〜1 だと「弱パンチでも黄」になりがち
    - 解決: しきい値型に変更（1, 2, 4, 6）。値域も Inspector でユーザーが調整可能
- **回転が逆向き**: 腹ヒット時の Spine 回転、当初は同方向に折れる動きになっていた
    - 解決: `Quaternion.AngleAxis(-maxAngle, axis)` で符号反転して、押される側にのけぞるように

### 最終的な調整値（VR内の手応えで決定）

- パンチクールダウン: 0.5秒
- 速度計算: ピーク速度 + 方向補正（TotF風、45°/90°/×0.33）
- HP: Head 500 / Body 800
- ダメージ: speed × 4（min 1, max 40）、部位倍率なし
- エフェクト色しきい値: intensity 1=緑, 2=黄, 4=橙, 6=赤
- 部位リアクション:
    - 頭ヒット → Head ボーン回転 12°
    - 腹ヒット → Spine ボーン回転 -3° + 位置移動 10cm
- ボード配置:
    - PunchCounter Billboard: (0, 3, 7) 中央
    - EnemyHealthBoard: (+4, 3, 7) 右

### 主要な追加スクリプト

- `Assets/Scripts/EnemyHealth.cs` — HP管理 + ダメージ計算
- `Assets/Scripts/EnemyHealthBoard.cs` — HP表示UI（3モード）
- `Assets/Scripts/BodyFaceAtPlayer.cs` — 体軸追従
- `Assets/Editor/EnemyHealthSetup.cs` — メニュー配置
- `Assets/Editor/BodyFaceAtPlayerSetup.cs` — メニュー配置

### 既存スクリプトの大きな変更

- `PunchDetector.cs` — Thrill of the Fight 風速度（ピーク + 方向補正）、ヒット後クールダウン、velocityHistory
- `HitReceiver.cs` — bodyPart を PlayHitFx に渡し、dmgEq ベースで音とエフェクト強度を変える、部位倍率フィールド
- `HitEffect.cs` — 色しきい値、damage 強度ベースの粒色（緑→黄→橙→赤）
- `EnemyHealthBoard.cs` — 直近ダメージ表示（2秒フェード）追加

### 次やること

- 拳が空を切る音（スゴ味）
- 消費カロリー表示（PPM ベース推定）
- Mixamoでボクシング系アニメをDL → NLA束ねスクリプトでまとめる（前回からの宿題）
- 振動 (Haptic Feedback) — Step 1-5 の積み残し
- KO 後のリトライUI（現状は KO 表示するだけで何も起きない）

### 参考

- ネット調査の結果、Thrill of the Fight 方式（ピーク速度 + 方向補正 + 角度減衰）を採用
- 業界では他に「複数フレーム平均」（VRTK / SteamVR / XR Interaction Toolkit）も標準
- 詳しくは [Thrill of the Fight - New punch force calculations](https://steamcommunity.com/app/494150/discussions/0/1326718197225193613/) などを参照

---

## 2026-05-02（その4）— 部位別ヒット判定 + ボーン追従 + のけぞり

### やったこと

- **パンチカウンター UI をビルボード化**
    - HUD（HMD追従）だと視線移動で揺れて気が散るため、リング奥の **固定壁ビルボード** に変更
    - `PunchCounter.DisplayMode` enum を追加（HudFollowHmd / WorldBillboard / WorldFixed）
    - ビルボード設定: 位置 (0, 3.0, 7.0) / サイズ 4.8m × 3.4m / フォントサイズ4倍 / 完全固定壁モード
    - エディタメニュー `VRBoxing > Create Punch Counter Billboard` を追加
    - HUDモードのメニューも残してあるので、後でHUDに別情報（タイマー等）を出せる
- **当たり判定を頭部 / 腹部に分割**
    - `Assets/Scripts/HitZone.cs` 新規（`enum BodyPart { Unknown, Head, Body }` を持つマーカー）
    - `Assets/Editor/HitZoneSetup.cs` 新規（メニュー `VRBoxing > Setup Hit Zones (Head + Body)`）
    - 既存の全身 Capsule Collider は無効化、頭/腹の2つの子オブジェクトコライダーに置換
    - `PunchEventData` に `bodyPart` フィールドを追加、Console ログにも部位を表示
- **コライダーをボーンに追従**
    - `Assets/Scripts/BoneFollower.cs` 新規（`LateUpdate` で `targetBone.TransformPoint(localOffset)` を毎フレーム適用）
    - `[DefaultExecutionOrder(100)]` で Animator (デフォルト 0) より後に実行
    - HitZoneSetup でボーン名パターン検索（VRoid: `J_Bip_C_*`, Mixamoリギング: `mixamorig:*`）
    - 「完全一致 → 部分一致」の優先度検索で、`mixamorig:Spine` と `mixamorig:Spine1` を取り違えない
- **部位別のけぞりリアクション**
    - **頭部ヒット**: Head ボーンを当たった方向に最大12° **回転**（首が振れる感触）
    - **腹部ヒット**: Spine ボーンに「**回転 + 位置移動**」を同時適用（上半身が押される感触）
    - LateUpdate でAnimator出力に上乗せする方式（`bone.rotation = offset * bone.rotation` / `bone.position += offset`）
    - イージング: 倒し EaseOut（衝撃）、戻し EaseIn（ゆっくり）

### 詰まったところ

- **コライダーがボーン追従しない問題**: 単に GameObject を子にするだけでは Animator がボーン回転を上書きしてしまう
    - 解決: BoneFollower を別 GameObject に持たせ、LateUpdate で位置を上書き
- **Spineボーンの混同**: `IndexOf("Spine")` だと `mixamorig:Spine1` も `Spine` を含むのでマッチしてしまう
    - 解決: 完全一致 → 部分一致の2段階検索
- **「Hipsを動かすと くの字 にならない」問題**: Hips はスケルトンルートなので、回転すると足ごと動く（前傾になるだけ）
    - 解決: 「くの字」演出には Spine（腰直上）の回転が正解。Hips追従と Spine回転を分離
- **回転方向が逆**: 殴られて押される側に倒れるべきなのに、なぜか同方向に折れていた
    - 解決: `Quaternion.AngleAxis(-maxAngle, ...)` で符号反転

### 最終的な調整値（VR内の手応えで決定）

- 頭コライダー: SphereCollider radius=0.10, center=(0, 0.05, 0)、`J_Bip_C_Head` 追従
- 腹コライダー: CapsuleCollider radius=0.10, height=0, center=(0, 0, 0)、`J_Bip_C_Hips` 追従
- 頭リアクション: Head ボーン 最大12° 回転
- 腹リアクション: Spine ボーン 最大-5° 回転 + 最大10cm 移動

### 主要な追加スクリプト

- `Assets/Scripts/PunchEvents.cs` — 静的イベントハブ + `PunchEventData`
- `Assets/Scripts/PunchCounter.cs` — UIランタイム自動生成、3モード切替
- `Assets/Scripts/HitZone.cs` — 部位マーカー
- `Assets/Scripts/BoneFollower.cs` — ボーン追従
- `Assets/Editor/PunchCounterCreator.cs` — メニュー配置
- `Assets/Editor/HitZoneSetup.cs` — メニュー配置 + ボーン自動検出

### 既存スクリプトの変更

- `PunchDetector.cs` — HitZone の bodyPart を取得、`PunchEvents.RaisePunch(...)` を発火、`receiver.TakeHit(.., part)` を呼ぶ
- `HitReceiver.cs` — 部位別 TakeHit オーバーロード追加、`headBone` / `bodyReactionBone` フィールド、LateUpdate でAnimator出力に上乗せ

### 次やること

- まだ未対応: パンチカウンター/カロリー UI の「カロリー推定」表示
- 拳が空を切る音
- Mixamo でボクシング系アニメをDL → NLA束ねスクリプトでまとめる（前回からの宿題）
- 振動 (Haptic Feedback) — Step 1-5 の積み残し

---

## 2026-05-02（その3）— パンチカウンタ HUD 実装

### やったこと

- **イベント基盤**: `Assets/Scripts/PunchEvents.cs` を新規作成
    - 静的 `event Action<PunchEventData> OnPunch` だけのシンプルなハブ
    - `PunchEventData` に velocity / speed / hitPoint / handName / 左右判定 / receiverName / time を持たせた
    - `RuntimeInitializeOnLoadMethod` でプレイ毎にリスナーを掃除（Domain Reload 無効環境で残らないように）
- **PunchDetector に発火を追加**: `receiver.TakeHit(...)` の直後に `PunchEvents.RaisePunch(...)` を呼ぶように改修
    - 左右の判定は `transform.parent.name` に "Left" / "Right" が含まれるかでざっくり（XR Interaction Toolkit の `LeftHand Controller` / `RightHand Controller` 命名を前提）
- **HUD 本体**: `Assets/Scripts/PunchCounter.cs` を新規作成
    - 起動時に World Space Canvas + TMP テキストを実行時自動生成（プレハブ不要）
    - HMD（Main Camera）に滑らかに追従する HUD として動作（`hmdLocalOffset` で配置調整）
    - 表示項目: 総数（特大）／ 左右別 / 直近速度 / 最大速度 / 平均速度 / 直近5発の平均 / 経過時間 / PPM(パンチ毎分)
    - R キーでセッションリセット
- **配置メニュー**: `Assets/Editor/PunchCounterCreator.cs` を新規作成
    - `VRBoxing > Create Punch Counter HUD` で1クリック配置
    - `VRBoxing > Delete Punch Counter HUD` で取り外しもできる

### ユーザーの操作

1. Unity の上部メニューから **`VRBoxing > Create Punch Counter HUD`** を1回クリック
2. ▶ Play して VR をかぶる → 視界の右下にカウンタが浮く

### メモ

- 既存の `PunchDetector` / `HitReceiver` には触らずに増設できる設計（イベントハブ経由）
- TextMeshPro 前提（VR テンプレートなら標準で入ってる）
- 「ユーザーが見たい所」より「デバッグしたい所」を優先して情報量を多めに。慣れてきたら `detailText` の出力を整理予定
- ハンド判定は親オブジェクト名のヒューリスティック。違う命名にしてある場合はカウンタの「L/R」が両方0になるが、総数はちゃんと数える

---

## 2026-05-02（その2）— ドキュメント整合性チェック

### やったこと

- 久々にプロジェクトに戻ったタイミングで、ドキュメントと実装の進捗ズレを棚卸し
- 3ファイルを実態に同期：
    - `docs/steps/step1.md` — 事前準備〜Task 1-5 を `[x]` に。Task 1-6（フィットネスUI）と Haptic Feedback だけ残タスクに整理。冒頭にステータス admonition を追加
    - `docs/tasks.md` — 「ボクシング実装フェーズ（完了 ✅）」セクションの中身が `[ ]` のままだった矛盾を解消
    - `docs/index.md` — ダッシュボードを最新化（最終更新2026-05-02 / 直近の動き = Mixamo用FBX自動エクスポート / 次のアクション = ボクシング系アニメDL）

### メモ

- 実装は進んでいるのにドキュメントが追いついていない、というのが地味に積もる。dev-logは粒度細かく書けてたが、step1.md と tasks.md のチェックボックス更新が抜けがちだった
- 認知負荷を下げる仕組みとして、節目で実装と docs を機械的にチェックする運用にしたい

---

## 2026-05-02

### やったこと

- **Blender MCP × VRoidの練習セッション**
    - Blender 5.1.1 起動済み + MCP接続済みの状態で、`Character_01_練習用.blend` をAI側からロード→中身を分析
    - 構造把握: メッシュ3つ（Body 7,170v / Face 4,305v / Hair 18,690v）、アーマチュア94本（VRM 0.x命名: `J_Bip_*`）、表情シェイプキー58個
    - Pythonスクリプト経由でポーズ操作・表情シェイプキー操作・カメラ自動配置・Eeveeレンダリングを実演（Neutral/Joy/Angry/Surprised の表情4枚を生成）
- **VRM Add-on for Blender v3.26.8 を Blender 5.1.1 にインストール**
    - Blender 4.2+ 用の **Extension版** ZIP を `bpy.ops.extensions.package_install_files` で導入
    - `import_scene.vrm` / `export_scene.vrm` オペレータが使える状態に
    - インストールパス: `%APPDATA%\Blender Foundation\Blender\5.1\extensions\user_default\vrm`
- **Mixamo用 FBX 自動エクスポート機構を作成**（認知負荷削減）
    - `scripts/export_for_mixamo.py` — `.blend` または `.vrm` を引数に取り、メッシュ＋アーマチュアのみ Mixamo互換設定（-Z forward / Y up / Leafボーン無し / テクスチャ同梱）でFBX出力
    - `scripts/export_for_mixamo.bat` — ダブルクリックで練習用キャラを書き出し、ファイルをドラッグ&ドロップで他キャラも処理可
    - 動作確認: `Character_01_練習用_for_mixamo.fbx` (3.62 MB) が正しく生成されることを確認
- **役割分担の整理**（議論の結果として残しておく）
    - **Blender が担当**: モデル形状・表情シェイプキー・FBX書き出し・ゲーム固有のシェイプキー量産（被弾顔等）
    - **Blender が担当しない**: 体のアニメーション制作（Idle / Jab / Hook / 被弾 / KO 等）
    - **Unity が担当**: ランタイムのIK・追従・ブレンディング（VR対戦相手は事前録画アニメだけだと無理。Unity Animation Rigging が主役）
    - 結論: 当面 Blender アニメーション学習は不要。Mixamo + Unity Animation Rigging で進める

### 詰まったところ

- **`bpy.ops.export_scene.fbx(use_selection=True)` が `'Context' object has no attribute 'selected_objects'` で失敗**
    - 原因: `wm.open_mainfile` 直後のコンテキストで `selected_objects` 属性が未定義になることがある（headless 寄りの状態）
    - 解決: `bpy.context.temp_override(selected_objects=targets, active_object=arm, ...)` で明示的にコンテキストを上書きしてからオペレータ実行

### 次やること（ユーザー側）

1. Mixamo を開いて、前回アップロード済みのキャラクターを選択
2. **boxing 系のアニメを 5〜8 本** Without Skin / FBX Binary / 60FPS でダウンロード
3. 1ヶ所のフォルダにまとめて、そのフォルダパスをClaudeに渡す

### 次やること（AI側、ユーザーから合図があったら）

- 落としてきた anim FBX 群を Blender に一括インポート → 各 Action を NLA に Push → 全アクション入りの1個のFBXとして再エクスポートするスクリプトを作成・実行
- これで Unity 側では `Character.fbx` 1つに `jab / hook / hit_react / idle` 等の AnimationClip がまとまった状態になる

### メモ

- Mixamo は公式の一括ダウンロードAPIなし。手作業 or ブラウザ自動操作（Claude in Chrome）の二択。今回は手作業推奨（プレビューで動きを確認しながら選んだ方が後悔が少ない）
- 現フェーズ（ステップ1演出調整 → ステップ2前半）では Blender×MCP の出番は限定的。**ステップ2でキャラ追加 / 被弾シェイプキー量産 / リング・ジム環境のプロシージャル生成**などになると一気に効いてくる、という温度感
- 試し書きしたVRMアドオンv3.26.8のリリースノート: VRM0/VRM1 のシェーダーノード周りバグ修正（2026-04-27 リリース）

### 参考URL

- VRM Add-on for Blender: https://github.com/saturday06/VRM-Addon-for-Blender
- 今回入れたバージョン: https://github.com/saturday06/VRM-Addon-for-Blender/releases/tag/v3.26.8

---

## 2026-04-27

### やったこと

- プロジェクトアイコン（ボクシンググローブ）を作成
    - テイスト: アニメ調・かわいい（ハート＆キラキラ装飾）
    - カラー: クラシック赤 × ピンク背景グラデ
    - 出力: SVG 原本 / iOS 180×180 PNG / favicon (16/32/48/192/512 PNG + .ico)
- `docs/assets/icons/` に格納し、`mkdocs.yml` の `theme.logo` と `theme.favicon` に紐付けた
    - 公開サイトのナビバーに自動でロゴ表示、ブラウザタブにファビコン表示

### 次やること

- パンチカウンター／カロリー UI（演出フェーズの本命）
- iPhone のホーム画面追加用に `overrides/main.html` で `<link rel="apple-touch-icon">` を追加し、`mkdocs.yml` に `theme.custom_dir: overrides` を設定済み

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
