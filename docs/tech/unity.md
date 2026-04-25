# Unity プロジェクト

Unity プロジェクト本体のセットアップ手順。本体は `unity/` フォルダに置く。

## セットアップ手順

1. Unity Hub を起動
2. 「New project」→ **3D (Core)** テンプレートを選択
3. プロジェクト名: `VRBoxing`
4. **Location を必ずこのフォルダ** (`C:\Users\hoeho\Documents\Claude\VRBoxing\unity`) にする
5. Unity バージョンは **2022.3 LTS** または **Unity 6 LTS** を推奨

## 作成後にやること

### VR 環境構築

1. `Window > Package Manager` を開く
2. 以下をインストール:
    - **XR Plugin Management**
    - **OpenXR Plugin**
    - **XR Interaction Toolkit**（Samples もインポート推奨）
3. `Edit > Project Settings > XR Plug-in Management` で **OpenXR** にチェック
4. OpenXR の設定で **Valve Index Controller Profile** を追加
5. `Edit > Project Settings > XR Plug-in Management > Project Validation` でエラーを解消

### Git 管理（推奨）

- Unity プロジェクト直下に `.gitignore` を置く（Unity 用テンプレートを GitHub から拾う）
- `Library/`, `Temp/`, `Build/` などは除外する

## フォルダ構成（Assets 配下の推奨）

Unity 側の `Assets/` はこう整理すると後で迷わない：

```
Assets/
├── _Project/              ← 自分で作ったもの全部ここに
│   ├── Scenes/
│   ├── Scripts/
│   ├── Prefabs/
│   ├── Materials/
│   ├── Characters/        ← 取り込んだキャラ
│   ├── Animations/
│   └── Audio/
├── Plugins/               ← サードパーティのパッケージ（VRM など）
└── ...（Unity 標準のフォルダ）
```

!!! tip "命名のコツ"

    アンダースコア `_` を頭に付けると一番上に表示されて探しやすい。
