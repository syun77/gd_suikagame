extends Node
# ===============================================
# 共通スクリプト.
# ===============================================
# ----------------------------------------
# consts
# ----------------------------------------
## 同時再生可能なサウンドの数.
const MAX_SOUND = 8

## フルーツ登場タイマー.
const TIMER_FRUIT_APPEAR = 1.0

### SEテーブル.
var _snd_tbl = {
	"drop": "res://assets/sound/se/drop.wav",
	"merge": "res://assets/sound/se/merge.wav",
}

# -----------------------------------------------
# preload.
# -----------------------------------------------
## フルーツテーブル.
const FRUIT_TBL = {
	Fruit.eFruit.BULLET: preload("res://src/fruit/FruitBullet.tscn"),
	Fruit.eFruit.CARROT: preload("res://src/fruit/FruitCarrot.tscn"),
	Fruit.eFruit.RADISH: preload("res://src/fruit/FruitRadish.tscn"),
	Fruit.eFruit.POCKY: preload("res://src/fruit/FruitPocky.tscn"),
	Fruit.eFruit.BANANA: preload("res://src/fruit/FruitBanana.tscn"),
	Fruit.eFruit.NASU: preload("res://src/fruit/FruitNasu.tscn"),
	Fruit.eFruit.TAKO: preload("res://src/fruit/FruitTako.tscn"),
	Fruit.eFruit.NYA: preload("res://src/fruit/FruitNya.tscn"),
	Fruit.eFruit.FIVE_BOX: preload("res://src/fruit/Fruit5Box.tscn"),
	Fruit.eFruit.MILK: preload("res://src/fruit/FruitMilk.tscn"),
	Fruit.eFruit.PUDDING: preload("res://src/fruit/FruitPudding.tscn"),
	Fruit.eFruit.XBOX: preload("res://src/fruit/FruitXBox.tscn"),	
}

# -----------------------------------------------
# var.
# -----------------------------------------------
var _snds:Array = []

## CanvasLayer.
var _layers = {}

## フルーツのスケールテーブル.
var _scale_tbl = {}

## フルーツの登場タイマーテーブル.
var _fruit_timers = {}

## スコア.
var score:int = 0
## ハイスコア.
var hi_score:int = 0

# -----------------------------------------------
# public function.
# -----------------------------------------------
## セットアップ.
func setup(layers) -> void:
	# スコア初期化.
	score = 0
	# フルーツタイマー初期化.
	_fruit_timers.clear()
	_layers = layers
	
	# AudioStreamPlayerをあらかじめ作っておく.
	## SE.
	for i in range(MAX_SOUND):
		var snd = AudioStreamPlayer.new()
		snd.bus = "SE"
		#snd.volume_db = -4
		add_child(snd)
		_snds.append(snd)

## レイヤーの取得.
func get_layer(layer_name:String) -> CanvasLayer:
	return _layers[layer_name]
	
## スコア加算.
## @return 加算したスコアの値.
func add_score(id:Fruit.eFruit) -> int:
	# スコアの式は Σ(n-1)らしい....
	var v = 0
	for i in range(id, 0, -1):
		v += i
	score += v
	if score > hi_score:
		hi_score = score
	
	return v

## フルーツの生成.
## @note ※遅延生成をする場合のみスコアが加算されます.
## @param id フルーツID.
## @param is_deferred 遅延生成するかどうか.
## @param particle/pos スコアパーティクルを生成するときの座標.
func create_fruit(id:Fruit.eFruit, is_deferred:bool=false, particle_pos:Vector2=Vector2.ZERO) -> Fruit:
	# PackedSceneを取得.
	var packed = FRUIT_TBL[id]
	var fruit = packed.instantiate()
	var layer = get_layer("fruit")
	if is_deferred:
		# RigidBody2D の body_entered シグナルで
		# add_child()するとエラーとなるっぽい.
		# そのため遅延処理で対処する.
		layer.call_deferred("add_child", fruit)
		# フルーツタイマー設定.
		_fruit_timers[id] = TIMER_FRUIT_APPEAR
		# スコア加算.
		var score = add_score(id)
		# スコア演出生成.
		ParticleUtil.add_score(particle_pos, score)
		# マージSE.
		Common.play_se("merge", 2)
	else:
		layer.add_child(fruit)
	
	return fruit
	
## フルーツ登場タイマーの更新.
func update_fruit_timer(delta:float) -> void:
	for id in _fruit_timers.keys():
		if _fruit_timers[id] > 0:
			_fruit_timers[id] -= delta
## フルーツ登場タイマーの取得.
func get_fruit_timer(id:Fruit.eFruit) -> float:
	var ret = 0.0
	if id in _fruit_timers:
		ret = _fruit_timers[id]
	return max(ret, 0)

## フルーツの基準スケール値を取得する.
func get_fruit_scale(id:Fruit.eFruit) -> Vector2:
	if id in _scale_tbl:
		# すでに登録済みならその値を使う.
		return _scale_tbl[id]
	
	# PackedSceneを取得.
	var packed:PackedScene = FRUIT_TBL[id]
	var fruit = packed.instantiate()
	# 登録してすぐに消す.
	add_child(fruit)
	fruit.queue_free()
	var scale = fruit.get_sprite_scale()
	# テーブルに登録.
	_scale_tbl[id] = scale
	return scale

## SEの再生.
## @note _sndsに事前登録が必要.
## @param 再生するSEの名前
func play_se(key:String, id:int=0) -> void:
	if id < 0 or MAX_SOUND <= id:
		push_error("不正なサウンドID %d"%id)
		return
	
	if not key in _snd_tbl:
		push_error("存在しないサウンド %s"%key)
		return
	
	var snd = _snds[id]
	snd.stream = load(_snd_tbl[key])
	snd.play()

# -----------------------------------------------
# private function.
# -----------------------------------------------
