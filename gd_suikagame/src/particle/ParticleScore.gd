extends Node2D
# ============================================================
# スコア演出.
# ============================================================
class_name ParticleScore

# ------------------------------------------------------------
# const.
# ------------------------------------------------------------
const TIMER_MAIN = 2.0 # 表示時間.
const TIMER_VANISH = 0.5 # フェードアウト時間.
const MOVE_SPEED = 10.0 # 移動速度.

## 状態.
enum eState {
	MAIN, # メイン.
	VANISH, # フェードアウトで消える.
}
# ------------------------------------------------------------
# onready.
# ------------------------------------------------------------
@onready var _label = $Label

# ------------------------------------------------------------
# var.
# ------------------------------------------------------------
## スコア.
var _score:int = 0
## 時間.
var _timer:float = 0.0
## 状態.
var _state = eState.MAIN

# ------------------------------------------------------------
# public function.
# ------------------------------------------------------------
## セットアップ.
func setup(pos:Vector2, score:int) -> void:
	position = pos
	_score = score
	_label.text = "+%d"%_score
	_timer = 0

# ------------------------------------------------------------
# private function.
# ------------------------------------------------------------
## 開始.
func _ready() -> void:
	pass

## 更新.
func _process(delta: float) -> void:
	_timer += delta
	position.y -= MOVE_SPEED * delta
	match _state:
		eState.MAIN: # メイン.
			if _timer >= TIMER_MAIN:
				# 消滅処理へ.
				_timer = 0.0
				_state = eState.VANISH
		eState.VANISH: # 消滅.
			var rate = 1.0 - (_timer / TIMER_VANISH)
			modulate.a = rate
			if _timer >= TIMER_VANISH:
				# 消滅.
				queue_free()
