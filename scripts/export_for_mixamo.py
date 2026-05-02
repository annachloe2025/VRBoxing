# -*- coding: utf-8 -*-
"""
Mixamo用 FBX エクスポートスクリプト

呼び出し方:
    blender --background --python export_for_mixamo.py -- <input.blend or input.vrm> [<output.fbx>]

Mixamo に上げるための要件:
- メッシュ＋アーマチュアのみ書き出し（カメラ・ライト・空オブジェクトは除外）
- 単位は メートル
- アーマチュアスケール 1.0
- Tポーズが望ましい（このスクリプトはポーズに触らない / 必要なら別スクリプトで）

Blender 4.2+ / VRM Add-on Extension v3.x 対応
"""

import bpy
import sys
import os


def parse_argv():
    """`--` 以降の引数を取り出す"""
    argv = sys.argv
    if "--" not in argv:
        return []
    return argv[argv.index("--") + 1:]


def load_input(input_path):
    """.blend なら open、.vrm なら新規シーンに import"""
    ext = os.path.splitext(input_path)[1].lower()
    if ext == ".blend":
        bpy.ops.wm.open_mainfile(filepath=input_path)
        print(f"[load] opened blend: {input_path}")
    elif ext == ".vrm":
        # 新規シーンを開いて VRM をインポート
        bpy.ops.wm.read_homefile(use_empty=True)
        bpy.ops.import_scene.vrm(filepath=input_path)
        print(f"[load] imported vrm: {input_path}")
    else:
        raise RuntimeError(f"対応していない拡張子: {ext}（.blend か .vrm を渡してください）")


def collect_mesh_and_armature():
    """メッシュとアーマチュアの一覧を返す（書き出し対象）"""
    arm = None
    targets = []
    for o in bpy.data.objects:
        if o.type in ("MESH", "ARMATURE"):
            targets.append(o)
            if o.type == "ARMATURE":
                arm = o
    if arm is None:
        raise RuntimeError("アーマチュアが見つかりません。VRoidキャラが入っていますか？")
    n_mesh = sum(1 for o in targets if o.type == "MESH")
    print(f"[collect] meshes={n_mesh}  armature='{arm.name}'")
    return arm, targets


def export_fbx(output_path, targets, armature):
    """Mixamo 互換の設定で FBX 書き出し
    selected_objects コンテキストエラーを避けるため temp_override で選択状態を渡す"""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # 一旦シーン上でも選択しておく（保険）
    bpy.ops.object.select_all(action="DESELECT")
    for o in targets:
        o.select_set(True)
    bpy.context.view_layer.objects.active = armature

    override = {
        "selected_objects": targets,
        "selected_editable_objects": targets,
        "active_object": armature,
        "object": armature,
    }
    with bpy.context.temp_override(**override):
        bpy.ops.export_scene.fbx(
            filepath=output_path,
            use_selection=True,                      # 選択したものだけ
            object_types={"MESH", "ARMATURE"},
            # 軸まわり: Mixamo は -Z forward, Y up を期待
            axis_forward="-Z",
            axis_up="Y",
            global_scale=1.0,
            apply_scale_options="FBX_SCALE_NONE",
            apply_unit_scale=True,
            bake_space_transform=False,
            # メッシュ
            mesh_smooth_type="FACE",
            use_subsurf=False,
            use_mesh_modifiers=True,
            use_mesh_edges=False,
            use_tspace=False,
            use_triangles=False,
            # アーマチュア / アニメーション
            add_leaf_bones=False,                    # Mixamoでは不要
            primary_bone_axis="Y",
            secondary_bone_axis="X",
            armature_nodetype="NULL",
            bake_anim=False,                         # アニメはMixamoで付ける
            # テクスチャ
            path_mode="COPY",
            embed_textures=True,
        )
    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"[export] {output_path}  ({size_mb:.2f} MB)")


def main():
    args = parse_argv()
    if not args:
        print("[error] 入力ファイルが指定されていません")
        print("usage: blender --background --python export_for_mixamo.py -- <input.blend or input.vrm> [<output.fbx>]")
        sys.exit(2)

    input_path = os.path.abspath(args[0])
    if not os.path.isfile(input_path):
        print(f"[error] ファイルが見つかりません: {input_path}")
        sys.exit(2)

    if len(args) >= 2:
        output_path = os.path.abspath(args[1])
    else:
        # デフォルト: 同じフォルダに <basename>_for_mixamo.fbx
        base = os.path.splitext(os.path.basename(input_path))[0]
        out_dir = os.path.dirname(input_path)
        output_path = os.path.join(out_dir, f"{base}_for_mixamo.fbx")

    print(f"=== Mixamo用 FBX エクスポート ===")
    print(f"input : {input_path}")
    print(f"output: {output_path}")

    load_input(input_path)
    arm, targets = collect_mesh_and_armature()
    export_fbx(output_path, targets, arm)
    print(f"=== 完了 ===")


if __name__ == "__main__":
    main()
