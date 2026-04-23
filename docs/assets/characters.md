# キャラクター素材

`02_Assets_Source/Characters/` に女性キャラクターの元データを置く。

## 入手先の候補

### 無料

- **VRoid Studio** (<https://vroid.com/studio>)
    - アニメ調、自分で細かくカスタマイズ可能
    - VRM 形式で出力 → UniVRM で Unity に入れる
- **Mixamo** (<https://www.mixamo.com/>)
    - Adobe 無料アカウントで使える
    - リアル調、ボクシングモーション込みで入手可能

### 有料・高品質

- **Character Creator 4 (Reallusion)**
    - リアル系女性、体型・顔を自由に調整
- **Booth** (<https://booth.pm/>)
    - VRChat 用アバターだが単体利用も可（ライセンスを必ず確認）
- **Unity Asset Store**
    - キーワード: "female character", "woman", "boxer"

## 保存方法

キャラごとにフォルダを作る：

```
Characters/
├── Character_01_Mika/
│   ├── source.vrm         ← 元ファイル
│   ├── LICENSE.txt        ← ライセンス情報
│   └── notes.md           ← このキャラのメモ
├── Character_02_Yuki/
│   └── ...
```

## Unity への取り込み時の注意

- **VRM** → UniVRM パッケージが必要
- **FBX** → そのままインポートできるが、マテリアルやシェーダーは調整が必要なことが多い
- 取り込む際は `03_Unity_Project` 側にコピーして、元ファイルはここに残す
