extends RigidBody2D
# ===============================================
# フルーツオブジェクト.
# ===============================================
class_name Fruit

# -----------------------------------------------
# const.
# -----------------------------------------------
const TIMER_HIT = 0.5 # ヒット時の点滅時間.

## フルーツの種類.
## このIDの並び＝進化テーブル
enum eFruit {
	BULLET, # 0:敵弾.
	CARROT, # 1:人参.
	RADISH, # 2:大根.
	POCKY, # 3:ポッキー.
	BANANA, # 4:バナナ.
	NASU, # 5:なす.
	TAKO, # 6:たこ焼き.
	NYA, # 7:えぐぜりにゃ〜.
	FIVE_BOX, # 8:5箱.
	MILK, # 9:牛乳.
	PUDDING, # 10:プリン.
	XBOX, # 11:XBox.
}

# 名前テーブル.
const NAMES = {
	eFruit.BULLET: "のどあめ", # 0:敵弾.
	eFruit.CARROT: "にんじん", # 1:人参.
	eFruit.RADISH: "大根", # 2:大根.
	eFruit.POCKY: "ポッキー", # 3:ポッキー.
	eFruit.BANANA: "バナナ", # 4:バナナ.
	eFruit.NASU: "なす", # 5:なす.
	eFruit.TAKO: "たこ焼き", # 6:たこ焼き.
	eFruit.NYA: "にゃ〜", # 7:えぐぜりにゃ〜.
	eFruit.FIVE_BOX: "5箱", # 8:5箱.
	eFruit.MILK: "牛乳", # 9:牛乳.
	eFruit.PUDDING: "プリン", # 10:プリン.
	eFruit.XBOX: "XBox", # 11:XBox.
}

# -----------------------------------------------
# export.
# -----------------------------------------------
## フルーツID.
@export var id:eFruit

# -----------------------------------------------
# onready.
# -----------------------------------------------
@onready var _spr = $Sprite

# -----------------------------------------------
# var.
# -----------------------------------------------
var _hit_timer = 0.0 # 衝突タイマー.

# -----------------------------------------------
# static functions.
# -----------------------------------------------
static func get_fruit_name(id:eFruit) -> String:
	return NAMES[id]

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
	if not body is Fruit:
		return # フルーツでない
	if self.is_queued_for_deletion():
		return # すでに破棄要求されている.
	if body.is_queued_for_deletion():
		return # すでに破棄要求されている.
		
	# フルーツとヒットした.
	var other = body as Fruit
	_hit_timer = TIMER_HIT
	if id != other.id:
		return # 一致していない.
	
	# IDが一致していたら合成可能.
	if id < eFruit.XBOX:
		# とりあえず中間地点にフルーツを生成する.
		var pos = (position + other.position)/2
		var fruit = Common.create_fruit(id+1)
		fruit.position = pos
	else:
		# XBox同士は消滅する
		pass
	queue_free()
	other.queue_free()
