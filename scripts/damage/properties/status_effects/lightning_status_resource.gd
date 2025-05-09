## 雷电效果资源脚本
class_name LightningStatusResource
extends DamageStatusResource

## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	status_damage_type = DamageTypeResource.DamageType.LIGHTNING


## 每次间隔触发（子类必须实现）
func on_tick(is_spreadable: bool = false) -> void:
	var ddr: DamageDataResource = DamageDataResource.new()
	ddr.total_damage = _calculate_final_value(status_value)
	_health_resource.add_hp(ddr.total_damage, is_spreadable)
	ddr.is_kill = _health_resource.is_dead
	if ddr.total_damage < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive(ddr, status_damage_type)

## 效果移除时触发（子类可选实现）
func on_remove() -> void:
	pass

## 效果传播时触发（子类可选实现）
## 一次性伤害， obj_rn 需要传染对象的ResourceNode
func on_spread(obj_rn: ResourceNode) -> void:
	# 对自身不能传染
	if obj_rn == _resource_node:
		return
	initialize(obj_rn, false)
