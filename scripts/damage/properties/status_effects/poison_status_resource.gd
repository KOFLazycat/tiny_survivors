## 中毒效果资源脚本
class_name PoisonStatusResource
extends DamageStatusResource

@export_group("Poison Settings", "poison_")
## 传播半径
@export var poison_speard_radius: float = 30.0


## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	status_damage_type = DamageTypeResource.DamageType.POISON


## 每次间隔触发（子类必须实现）
func on_tick() -> void:
	var total_dmg: float = _calculate_final_value(status_value)
	_health_resource.add_hp(total_dmg)
	if total_dmg < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive_points(-total_dmg, false, status_damage_type)


## 效果移除时触发（子类可选实现）
func on_remove() -> void:
	pass

## 效果传播时触发（子类可选实现）
func on_spread(obj_rn: ResourceNode) -> void:
	pass
