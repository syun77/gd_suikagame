extends Node
# ===============================================
# 共通スクリプト.
# ===============================================

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
	var tscn = load(Fruit.TSCN_TBL[id])
	var fruit = tscn.instantiate()
	var layer = get_layer("fruit")
	layer.add_child(fruit)
	return fruit
