extends Node2D
# ===============================================
# メインシーン.
# ===============================================

# -----------------------------------------------
# const.
# -----------------------------------------------
## フルーツ落下の高さ.
const DROP_POS_Y = 120.0

## NEXT抽選用テーブル.
const NEXT_TBL = [
	Fruit.eFruit.BULLET, # 0:敵弾.
	Fruit.eFruit.CARROT, # 1:人参.
	Fruit.eFruit.RADISH, # 2:大根.
	Fruit.eFruit.POCKY, # 3:ポッキー.
	Fruit.eFruit.BANANA, # 4:バナナ.
]

## 状態.
enum eState {
	INIT, # 初期化.
	MAIN, # メイン.
	DROP_WAIT, # 落下完了待ち.
	GAME_OVER, # ゲームオーバー.
}

# -----------------------------------------------
# onready.
# -----------------------------------------------
@onready var _fruit_layer = $FruitLayer
@onready var _ui_layer = $UILayer
@onready var _ui_now_fruit = $UILayer/NowFruit

# -----------------------------------------------
# var.
# -----------------------------------------------
## 状態.
var _state := eState.INIT
## 現在のフルーツ.
var _now_fruit = Fruit.eFruit.BULLET
## 次のフルーツ.
var _next_fruit = Fruit.eFruit.BULLET
## 落下させたフルーツ.
var _fruit:Fruit = null

# -----------------------------------------------
# private function.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	# レイヤーテーブル.
	var layers = {
		"fruit": _fruit_layer,
		"ui": _ui_layer,
	}
	# セットアップ.
	Common.setup(layers)
	
# 次のフルーツを抽選する.
# ※正確には次の次のフルーツ.
func _lot_fruit() -> void:
	_now_fruit = _next_fruit
	# コピー.
	var tbl = NEXT_TBL.duplicate()
	# シャッフル.
	tbl.shuffle()
	# 設定.
	_next_fruit = tbl[0]
	
	_ui_now_fruit.texture = Fruit.get_fruit_tex(_now_fruit)	
	_ui_now_fruit.scale = Common.get_fruit_scale(_now_fruit)
	_ui_now_fruit.modulate.a = 0.5

## 更新.
func _process(delta: float) -> void:
	match _state:
		eState.INIT:
			_update_init()
		eState.MAIN:
			_update_main()
		eState.DROP_WAIT:
			_update_drop_wait()
		eState.GAME_OVER:
			_update_game_over()

	_update_ui()
	_update_debug()

## 更新 > 初期化.
func _update_init() -> void:
	# フルーツを抽選.
	_lot_fruit()
	_state = eState.MAIN

## 更新 > メイン.	
func _update_main() -> void:
	_ui_now_fruit.visible = true
	_ui_now_fruit.position.x = get_global_mouse_position().x
	_ui_now_fruit.position.y = DROP_POS_Y
	
	if Input.is_action_just_pressed("click"):
		# UIとしてのフルーツを非表示.
		_ui_now_fruit.visible = false
		
		# @note 生成すると内部でレイヤーへの追加もしてくれる.
		var fruit = Common.create_fruit(_now_fruit)
		fruit.position = _ui_now_fruit.position
		
		# 落下中のフルーツを保持 (落下完了判定用).
		_fruit = fruit
		print(fruit)
		# 落下完了待ち.
		_state = eState.DROP_WAIT

## 更新 > 落下完了待ち.
func _update_drop_wait() -> void:
	if _is_dropped(_fruit) == false:
		return # 落下完了待ち.
	
	# 落下完了した.
	_fruit = null # 参照を消しておく.
	# フルーツを抽選.
	_lot_fruit()
	_state = eState.MAIN

## 更新 > ゲームオーバー.
func _update_game_over() -> void:
	pass

## 指定のフルーツが落下完了したかどうか.
## @note 引数の型を指定するとnullのときに実行時エラーとなる.
func _is_dropped(node) -> bool:
	if is_instance_valid(node) == false:
		return true # 無効なインスタンスであれば完了したことにする.
		
	var fruit = node as Fruit
	if fruit.is_hit_even_once():
		return true # 一度でも他のオブジェクトに接触した.
	
	# 落下完了していない.
	return false

## 更新 > UI.
func _update_ui() -> void:
	pass
	
## 更新 > デバッグ.
func _update_debug() -> void:
	if Input.is_action_just_pressed("reset"):
		# リセット.
		get_tree().change_scene_to_file("res://Main.tscn")
