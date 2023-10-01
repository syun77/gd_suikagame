extends Node2D

# -----------------------------------------------
# const.
# -----------------------------------------------
const FRUIT_OBJ = preload("res://Fruit.tscn")

# -----------------------------------------------
# onready.
# -----------------------------------------------
@onready var _fruit_layer = $FruitLayer

# -----------------------------------------------
# private function.
# -----------------------------------------------
## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var fruit = FRUIT_OBJ.instantiate()
		fruit.position = get_global_mouse_position()
		_fruit_layer.add_child(fruit)
