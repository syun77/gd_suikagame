extends Node
# ===============================================
# 共通スクリプト.
# ===============================================
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
var _layers = {}

## セットアップ.
func setup(layers) -> void:
	_layers = layers

## レイヤーの取得.
func get_layer(layer_name:String) -> CanvasLayer:
	return _layers[layer_name]

## フルーツの生成.
func create_fruit(id:Fruit.eFruit) -> Fruit:
	# シーンを読み込む.
	var packed = FRUIT_TBL[id]
	var fruit = packed.instantiate()
	var layer = get_layer("fruit")
	# ここでadd_child()するとエラーとなる.
	#layer.add_child(fruit)
	# 遅延処理しなければならない...
	layer.call_deferred("add_child", fruit)
	return fruit
