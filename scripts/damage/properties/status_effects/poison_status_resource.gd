## 中毒效果资源脚本
class_name PoisonStatusResource
extends DamageStatusResource

## 传播半径
@export var speard_radius: float = 30.0


## 初次应用时触发（子类必须实现）
func _on_apply() -> void:
	push_warning("Unimplemented _on_apply() in status: %s" % status_name)


## 每次间隔触发（子类必须实现）
func _on_tick() -> void:
	var total_dmg: float = _calculate_final_value()
	_health_resource.add_hp(total_dmg)
	if total_dmg < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive_points(-total_dmg, false, status_damage_type)


## 效果移除时触发（子类可选实现）
func _on_remove() -> void:
	pass

## 效果传播时触发（子类可选实现）
func _on_spread() -> void:
	pass
