class_name DamagePoints
extends Node2D

@export var label:Label
@export var tween_time:float = 0.5
@export var distance:float = 20.0
@export var pool_node:PoolNode


func set_displayed_points(points:int, is_critical:bool, damage_type: DamageTypeResource.DamageType = DamageTypeResource.DamageType.PHYSICAL)->void:
	label.modulate = Color.WHITE
	match damage_type:
		DamageTypeResource.DamageType.PHYSICAL:
			if is_critical:
				label.modulate = Color.YELLOW
		DamageTypeResource.DamageType.FIRE: # 火焰（持续灼烧，可引燃环境）
			label.modulate = Color.SANDY_BROWN
		DamageTypeResource.DamageType.ICE: # 冰霜（减速目标移动速度）
			pass
		DamageTypeResource.DamageType.LIGHTNING: # 雷电（连锁攻击多个目标）
			pass
		DamageTypeResource.DamageType.POISON: # 毒素（持续生命流失）
			label.modulate = Color.LIME
		DamageTypeResource.DamageType.CURSE: # 诅咒（目标立即死亡）
			pass
		
	var text: String = str(points)
	if points == 0:
		text = "MISS"
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER,Control.PRESET_MODE_MINSIZE)

func _ready()->void:
	var _angle:float = randf_range(0.6, 0.9) * TAU
	var _offset:Vector2 = Vector2.RIGHT.rotated(_angle) * distance
	var tween:Tween = create_tween()
	tween.tween_method(tween_move.bind(global_position, global_position + _offset), 0.0, 1.0, tween_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(pool_node.pool_return)

func tween_move(t:float, from:Vector2, to:Vector2)->void:
	global_position = from.lerp(to, t)
