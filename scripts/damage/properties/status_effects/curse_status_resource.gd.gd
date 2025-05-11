## 诅咒效果资源脚本
class_name CurseStatusResource
extends DamageStatusResource

@export_group("Curse Settings", "curse_")
## 物理抗性降低百分比，物理抗性最低为0
@export_range(0.0, 1.0) var curse_physical_resistance_percent: float = 0.1

## 主处理入口（由StatusSetup调用）
func process(delta: float) -> bool:
	# 血量管理
	if _health_resource.is_dead:
		_trigger_remove()
		return false
	# 持续时间管理
	if status_duration > 0:
		_current_duration += delta
		if _current_duration >= status_duration + randf_range(-0.2, 0.2):
			on_tick(status_spreadable)
			status_ticked.emit(self)
			_trigger_remove()
			return true
	
	return true


## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	status_damage_type = DamageTypeResource.DamageType.CURSE
	var rv: float = _damage_resource.resistance_value_list[DamageTypeResource.DamageType.PHYSICAL]
	_damage_resource.resistance_value_list[DamageTypeResource.DamageType.PHYSICAL] = clampf(rv * (1 - curse_physical_resistance_percent), 0.0, 1.0)


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
	initialize(obj_rn, status_spreadable)
