extends RigidBody2D
# -----------------------------------------------
# フルーツオブジェクト.
# -----------------------------------------------
class_name Fruit

# -----------------------------------------------
# const.
# -----------------------------------------------
const TIMER_HIT = 0.5 # ヒット時の点滅時間.

# -----------------------------------------------
# onready.
# -----------------------------------------------
@onready var _spr = $Sprite

# -----------------------------------------------
# var.
# -----------------------------------------------
var _hit_timer = 0.0 # 衝突タイマー.

# -----------------------------------------------
# private functions.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	pass

## 更新.
func _physics_process(delta: float) -> void:
	_spr.modulate = Color.WHITE
	if _hit_timer > 0:
		# ヒット点滅.
		var rate = 1 - (_hit_timer / TIMER_HIT)
		_hit_timer -= delta
		var color = Color.RED
		_spr.modulate = color.lerp(Color.WHITE, rate)
		
# -----------------------------------------------
# signal.
# -----------------------------------------------

## 他の剛体と衝突した.
func _on_body_entered(body: Node) -> void:
	if body is Fruit:
		# フルーツとヒットした.
		_hit_timer = TIMER_HIT
