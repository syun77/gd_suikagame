extends Node2D
# ===============================================
# メインシーン.
# ===============================================

# -----------------------------------------------
# const.
# -----------------------------------------------
const FRUIT_OBJ = preload("res://src/fruit/Fruit.tscn")

# -----------------------------------------------
# onready.
# -----------------------------------------------
@onready var _fruit_layer = $FruitLayer

# -----------------------------------------------
# private function.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	var layers = {
		"fruit": _fruit_layer,
	}
	# セットアップ.
	Common.setup(layers)

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		#var fruit = FRUIT_OBJ.instantiate()
		var fruit = Common.create_fruit(Fruit.eFruit.BULLET)
		fruit.position = get_global_mouse_position()
		_fruit_layer.add_child(fruit)
