extends Node2D
# ===============================================
# メインシーン.
# ===============================================

# -----------------------------------------------
# const.
# -----------------------------------------------
const FRUIT_OBJ = preload("res://src/fruit/Fruit.tscn")

## NEXT抽選用テーブル.
const NEXT_TBL = [
	Fruit.eFruit.BULLET, # 0:敵弾.
	Fruit.eFruit.CARROT, # 1:人参.
	Fruit.eFruit.RADISH, # 2:大根.
	Fruit.eFruit.POCKY, # 3:ポッキー.
	Fruit.eFruit.BANANA, # 4:バナナ.
]

# -----------------------------------------------
# onready.
# -----------------------------------------------
@onready var _fruit_layer = $FruitLayer
@onready var _ui_layer = $UILayer

# -----------------------------------------------
# var.
# -----------------------------------------------
## 現在のフルーツ.
var _now_fruit = Fruit.eFruit.BULLET
## 次のフルーツ.
var _next_fruit = Fruit.eFruit.BULLET

# -----------------------------------------------
# private function.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	# レイヤーテーブル.
	var layers = {
		"fruit": _fruit_layer,
		"ui": _ui_layer,
	}
	# セットアップ.
	Common.setup(layers)

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		# @note 生成すると内部でレイヤーへの追加もしてくれる.
		var fruit = Common.create_fruit(Fruit.eFruit.BULLET)
		fruit.position = get_global_mouse_position()

	_update_ui()
	_update_debug()

## 更新 > UI.
func _update_ui() -> void:
	pass
	
## 更新 > デバッグ.
func _update_debug() -> void:
	if Input.is_action_just_pressed("reset"):
		# リセット.
		get_tree().change_scene_to_file("res://Main.tscn")
