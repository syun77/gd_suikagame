extends Node
# ===============================================
# 共通スクリプト.
# ===============================================
# -----------------------------------------------
# preload.
# -----------------------------------------------
## フルーツ登場タイマー.
const TIMER_FRUIT_APPEAR = 1.0

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
## CanvasLayer.
var _layers = {}

## フルーツのスケールテーブル.
var _scale_tbl = {}

## フルーツの登場タイマーテーブル.
var _fruit_timers = {}

# -----------------------------------------------
# public function.
# -----------------------------------------------
## セットアップ.
func setup(layers) -> void:
	# フルーツタイマー初期化.
	_fruit_timers.clear()
	_layers = layers

## レイヤーの取得.
func get_layer(layer_name:String) -> CanvasLayer:
	return _layers[layer_name]

## フルーツの生成.
func create_fruit(id:Fruit.eFruit, is_deferred:bool=false) -> Fruit:
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
	
# -----------------------------------------------
# private function.
# -----------------------------------------------
