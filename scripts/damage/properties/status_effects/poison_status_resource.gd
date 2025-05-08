## 中毒效果资源脚本
class_name PoisonStatusResource
extends DamageStatusResource

## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	status_damage_type = DamageTypeResource.DamageType.POISON


## 每次间隔触发（子类必须实现）
func on_tick() -> void:
	var ddr: DamageDataResource = DamageDataResource.new()
	ddr.total_damage = _calculate_final_value(status_value)
	_health_resource.add_hp(ddr.total_damage)
	ddr.is_kill = _health_resource.is_dead
	if ddr.total_damage < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive(ddr, status_damage_type)


## 效果移除时触发（子类可选实现）
func on_remove() -> void:
	pass

## 效果传播时触发（子类可选实现）
func on_spread(_obj_rn: ResourceNode) -> void:
	pass
