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

## 名前テーブル.
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

## テクスチャテーブル.
const TEXTURES = {
	eFruit.BULLET: "res://assets/images/fruits/bullet.png", # 0:敵弾.
	eFruit.CARROT: "res://assets/images/fruits/carrot.png", # 1:人参.
	eFruit.RADISH: "res://assets/images/fruits/radish.png", # 2:大根.
	eFruit.POCKY: "res://assets/images/fruits/pocky.png", # 3:ポッキー.
	eFruit.BANANA: "res://assets/images/fruits/banana.png", # 4:バナナ.
	eFruit.NASU: "res://assets/images/fruits/nasu.png", # 5:なす.
	eFruit.TAKO: "res://assets/images/fruits/tako.png", # 6:たこ焼き.
	eFruit.NYA: "res://assets/images/fruits/nya.png", # 7:えぐぜりにゃ〜.
	eFruit.FIVE_BOX: "res://assets/images/fruits/5box.png", # 8:5箱.
	eFruit.MILK: "res://assets/images/fruits/milk.png", # 9:牛乳.
	eFruit.PUDDING: "res://assets/images/fruits/pudding.png", # 10:プリン.
	eFruit.XBOX: "res://assets/images/fruits/xbox.png", # 11:XBox.
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
var _base_scale:Vector2
var _hit_timer = 0.0 # 衝突タイマー.
var _hit_count = 0 # 他のオブジェクトと衝突した回数.

# -----------------------------------------------
# static functions.
# -----------------------------------------------
## フルーツの名前を取得.
static func get_fruit_name(id:eFruit) -> String:
	return NAMES[id]

## フルーツの画像を取得.
static func get_fruit_tex(id:eFruit) -> Texture:
	return load(TEXTURES[id])

# -----------------------------------------------
# public functions.
# -----------------------------------------------
## スプライトのスケール値を取得する.
func get_sprite_scale() -> Vector2:
	return _spr.scale

## 一度でもヒットしたかどうか.
func is_hit_even_once() -> bool:
	return _hit_count > 0

# -----------------------------------------------
# private functions.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	# 基準のスケール値を保存.
	_base_scale = get_sprite_scale()

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
	# ヒット回数をカウント.
	_hit_count += 1
	
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
		return # 一致していないので何も起こらない.
	
	# IDが一致していたら合成可能.
	if id < eFruit.XBOX:
		# とりあえず中間地点にフルーツを生成する.
		var pos = (position + other.position)/2
		# このシグナル内で生成する場合は
		# 遅延処理をしなければならない.
		var is_deferred = true
		# 進化するのでid+1
		var fruit = Common.create_fruit(id+1, is_deferred)
		fruit.position = pos
	else:
		# XBox同士は消滅するので何もしない.
		pass
	
	# お互いに消滅する.
	queue_free()
	other.queue_free()
