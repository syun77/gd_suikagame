extends Node

# =======================================================
# パーティクルユーティリティ.
# =======================================================
class_name ParticleUtil

# -------------------------------------------------------
# const.
# -------------------------------------------------------
const PARTICLE_SCORE = preload("res://src/particle/ParticleScore.tscn")

# -------------------------------------------------------
# static public function.
# -------------------------------------------------------
## スコア演出を生成.
static func add_score(pos:Vector2, score:int) -> ParticleScore:
	var layer = _get_layer()
	var p = PARTICLE_SCORE.instantiate()
	layer.add_child(p)
	p.setup(pos, score)
	return p

# -------------------------------------------------------
# static private function.
# -------------------------------------------------------
static func _get_layer() -> CanvasLayer:
	return Common.get_layer("particle")
