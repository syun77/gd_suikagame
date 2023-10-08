extends RigidBody2D
# ===============================================
# フルーツオブジェクト.
# ===============================================
class_name Fruit

# -----------------------------------------------
# const.
# -----------------------------------------------
const TIMER_HIT = 0.5 # ヒット時の点滅時間.
const TIMER_SCALE = 0.3 # 出現時のスケール.

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
var _gameover_timer = 0.0 # ゲームオーバータイマー.
var _hit_count = 0 # 他のオブジェクトと衝突した回数.
var _scale_timer = 0.0 # 拡大縮小タイマー.

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

## 出現時のスケール開始.
func start_scale() -> void:
	_scale_timer = TIMER_SCALE

## ゲームオーバーのラインを超えているかどうか.
func check_gameover(delta:float) -> bool:
	_gameover_timer += (delta * 2)
	if _gameover_timer > 2.0:
		# _progress()で減算されるので実質1秒.
		# ライン超え.
		return true
	
	# セーフ.
	return false

# -----------------------------------------------
# private functions.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	# 基準のスケール値を保存.
	_base_scale = get_sprite_scale()

## 更新.
func _physics_process(delta: float) -> void:
	
	# 拡大縮小演出.
	_spr.scale = _base_scale
	if _scale_timer > 0:
		_scale_timer -= delta
		var rate = _scale_timer / TIMER_SCALE
		rate = 1 + 0.1 * Ease.back_out(1 - rate)
		_spr.scale *= Vector2(rate, rate)
	
	# ゲームオーバー赤点滅演出.
	_spr.modulate = Color.WHITE
	if _gameover_timer > 0:
		var rate = 1 - (_gameover_timer / TIMER_HIT)
		_gameover_timer -= delta
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
		fruit.start_scale()
	else:
		# XBox同士は消滅するので何もしない.
		pass
	
	# お互いに消滅する.
	queue_free()
	other.queue_free()
