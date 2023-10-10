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
# ゲームオーバーの線.
@onready var _deadline = $DeadLine
# 左右の移動可能範囲.
@onready var _marker_left = $Marker/Left
@onready var _marker_right = $Marker/Right
# 補助線.
@onready var _spr_line = $Line
# CanvasLayer.
@onready var _wall_layer = $WallLayer
@onready var _fruit_layer = $FruitLayer
@onready var _particle_layer = $ParticleLayer
@onready var _ui_layer = $UILayer
# UI.
@onready var _ui_now_fruit = $UILayer/NowFruit
@onready var _ui_dbg_label = $UILayer/DbgLabel
@onready var _ui_evolution_label = $UILayer/Evolution/Label
@onready var _ui_caption = $UILayer/Caption
@onready var _ui_gauge = $UILayer/ProgressBar
@onready var _ui_next = $UILayer/Next/Sprite2D
@onready var _ui_score = $UILayer/Score
@onready var _ui_score_sub = $UILayer/Score/SubLabel
@onready var _ui_hi_score = $UILayer/HiScore
# サウンド.
@onready var _bgm = $Bgm

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
## BGMの状態.
var _bgm_id = 0
## 進化の環.
var _evolution_sprs = {}
## 進化の環のスケール.
var _evolution_scales = {}

# -----------------------------------------------
# private function.
# -----------------------------------------------
## 開始.
func _ready() -> void:
	# レイヤーテーブル.
	var layers = {
		"wall": _wall_layer,
		"fruit": _fruit_layer,
		"particle": _particle_layer,
		"ui": _ui_layer,
	}
	# セットアップ.
	Common.setup(layers)

	# 進化画像のセットアップ.
	_setup_evolution()
	
	# BGM再生.
	_bgm.play()

## 進化画像のセットアップ.
func _setup_evolution() -> void:
	# 進化画像.
	_evolution_sprs[Fruit.eFruit.BULLET] = $UILayer/Evolution/Bullet
	_evolution_sprs[Fruit.eFruit.CARROT] = $UILayer/Evolution/Carrot
	_evolution_sprs[Fruit.eFruit.RADISH] = $UILayer/Evolution/Radish
	_evolution_sprs[Fruit.eFruit.POCKY] = $UILayer/Evolution/Pocky
	_evolution_sprs[Fruit.eFruit.BANANA] = $UILayer/Evolution/Banana
	_evolution_sprs[Fruit.eFruit.NASU] = $UILayer/Evolution/Nasu
	_evolution_sprs[Fruit.eFruit.TAKO] = $UILayer/Evolution/Tako
	_evolution_sprs[Fruit.eFruit.NYA] = $UILayer/Evolution/Nya
	_evolution_sprs[Fruit.eFruit.FIVE_BOX] = get_node("UILayer/Evolution/5Box")
	_evolution_sprs[Fruit.eFruit.MILK] = $UILayer/Evolution/Milk
	_evolution_sprs[Fruit.eFruit.PUDDING] = $UILayer/Evolution/Pudding
	_evolution_sprs[Fruit.eFruit.XBOX] = $UILayer/Evolution/Xbox
	# 基準スケール値を保持.
	for id in _evolution_sprs.keys():
		_evolution_scales[id] = _evolution_sprs[id].scale

# 次のフルーツを抽選する.
func _lot_fruit() -> void:
	_now_fruit = _next_fruit
	# コピー.
	var tbl = NEXT_TBL.duplicate()
	# シャッフル.
	tbl.shuffle()
	# 設定.
	_next_fruit = tbl[0]
	_ui_next.texture = Fruit.get_fruit_tex(_next_fruit)
	_ui_next.scale = Common.get_fruit_scale(_next_fruit)
	
	_ui_now_fruit.texture = Fruit.get_fruit_tex(_now_fruit)	
	_ui_now_fruit.scale = Common.get_fruit_scale(_now_fruit)
	_ui_now_fruit.modulate.a = 0.5

## 更新.
func _process(delta: float) -> void:
	match _state:
		eState.INIT:
			_update_init()
		eState.MAIN:
			_update_main(delta)
		eState.DROP_WAIT:
			_update_drop_wait(delta)
		eState.GAME_OVER:
			_update_game_over()

	_update_ui(delta)
	_update_debug()

## 更新 > 初期化.
func _update_init() -> void:
	# フルーツを抽選.
	_lot_fruit()
	_state = eState.MAIN

## 更新 > メイン.	
func _update_main(delta) -> void:
	# ゲームオーバーチェック.
	if _is_gameoveer(delta):		
		# ゲームオーバー処理へ.
		_start_gameover()
		_state = eState.GAME_OVER
		return
	
	# カーソルの更新.
	_update_cursor()
	
	if Input.is_action_just_pressed("click"):
		Common.play_se("drop", 1)
		# UIとしてのフルーツを非表示.
		_ui_now_fruit.visible = false
		_spr_line.visible = false
		
		# @note 生成すると内部でレイヤーへの追加もしてくれる.
		var fruit = Common.create_fruit(_now_fruit)
		fruit.position = _ui_now_fruit.position
		
		# 落下中のフルーツを保持 (落下完了判定用).
		_fruit = fruit
		# 落下完了待ち.
		_state = eState.DROP_WAIT

## 更新 > 落下完了待ち.
func _update_drop_wait(delta:float) -> void:
	# ゲームオーバーチェック.
	if _is_gameoveer(delta):		
		# ゲームオーバー処理へ.
		_start_gameover()
		_state = eState.GAME_OVER
		return	
	
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

## 更新 > カーソル.
func _update_cursor() -> void:
	# カーソル位置の計算.
	var px = get_global_mouse_position().x
	# 移動可能範囲でclamp.
	px = clamp(px, _marker_left.position.x, _marker_right.position.x)
	
	# フルーツカーソルを表示.
	_ui_now_fruit.visible = true
	_ui_now_fruit.position.x = px	
	_ui_now_fruit.position.y = DROP_POS_Y
	# 落下補助線を表示.
	_spr_line.visible = true
	_spr_line.position.x = px
	_spr_line.modulate.a = 0.5

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

## ゲームオーバーかどうか.
func _is_gameoveer(delta:float) -> bool:
	var max_rate = 0.0
	var max_obj:Fruit = null
	_ui_gauge.visible = false
	
	for obj in _fruit_layer.get_children():
		var fruit = obj as Fruit
		if fruit.check_gameover(_deadline.position.y, delta):
			return true
		# 少し強引だけれどもゲームオーバータイマーが最大のオブジェクトにゲージをつける.
		var rate = fruit.get_gameover_timer_rate()
		if rate > max_rate:
			# 最大時間の更新.
			max_rate = rate
			max_obj = fruit
	
	if max_obj:
		# ゲームオーバーゲージの表示.
		_bgm.pitch_scale = 0.75
		AudioServer.set_bus_effect_enabled(1, 0, true) # ローパスフィルタを有効にする.
		_ui_gauge.visible = true
		_ui_gauge.value = 100 * max_rate
		_ui_gauge.position = max_obj.position
	else:
		AudioServer.set_bus_effect_enabled(1, 0, false) # ローパスフィルタを無効にする.
		_bgm.pitch_scale = 1.0
		
	return false

## ゲームオーバー開始処理.
func _start_gameover() -> void:
	# BGMを止める.
	#_bgm.stop()
	# 物理挙動を止める.
	PhysicsServer2D.set_active(false)
	for obj in _fruit_layer.get_children():
		# フルーツの更新をすべて止める.
		obj.set_physics_process(false)
	
	# キャプション表示.
	_ui_caption.visible = true
	# カーソルを非表示.
	_spr_line.visible = false
	_ui_now_fruit.visible = false


## 更新 > UI.
func _update_ui(delta:float) -> void:
	# スコア更新.
	_ui_score.text = "SCORE: %d"%Common.score
	_ui_hi_score.text = "HI-SCORE: %d"%Common.hi_score
	
	if _count_score_particle() == 0:
		# スコア演出が消えたらリセット.
		Common.disp_add_score = 0
		_ui_score_sub.visible = false
	if Common.disp_add_score > 0:
		_ui_score_sub.visible = true
		_ui_score_sub.text = "(+%d)"%Common.disp_add_score
	
	# フルーツ登場タイマー反映.
	Common.update_fruit_timer(delta)
	for id in _evolution_sprs.keys():
		var t = Common.get_fruit_timer(id)
		var scale = _evolution_scales[id]
		if t > 0:
			var rate = 1 + Ease.elastic_out(1 - t)
			scale *= (Vector2.ONE * rate)
		_evolution_sprs[id].scale = scale
	
	# フルーツの生成数をカウントする.
	var tbl = {}
	var max_id = Fruit.eFruit.BULLET
	for obj in _fruit_layer.get_children():
		var fruit = obj as Fruit
		var id = fruit.id
		if id in tbl:
			tbl[id] += 1 # 登録済みならカウントアップ.
		else:
			tbl[id] = 1 # 未登録なら登録する.
		if max_id < id:
			# 最のIDを更新.
			max_id = id
	
	if max_id >= Fruit.eFruit.XBOX:
		if _bgm_id < 2:
			# XBOXが出たらBGM変更.
			_bgm.stream = load("res://assets/sound/bgm/bgm03_140.mp3")
			_bgm.play()
			_bgm_id = 2
	elif max_id >= Fruit.eFruit.MILK:
		if _bgm_id < 1:
			# 牛乳が出たらBGM変更.
			_bgm.stream = load("res://assets/sound/bgm/bgm02_140.mp3")
			_bgm.play()
			_bgm_id = 1
	
	_ui_evolution_label.text = ""
	var values = Fruit.eFruit.values()
	values.reverse()
	for id in values:
		var s = Fruit.get_fruit_name(id)
		if id in tbl:
			_ui_evolution_label.text += s + ":%d\n"%tbl[id]
		else:
			_ui_evolution_label.text += "\n"

## スコア演出オブジェクトをカウントする.
func _count_score_particle() -> int:
	var ret = 0
	for obj in _particle_layer.get_children():
		if obj is ParticleScore:
			ret += 1
	return ret

## 更新 > デバッグ.
func _update_debug() -> void:
	if Input.is_action_just_pressed("reset"):
		# リセット.
		# 物理を有効に戻す.
		PhysicsServer2D.set_active(true)
		get_tree().change_scene_to_file("res://Main.tscn")
