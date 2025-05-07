## 火焰效果资源脚本
class_name FireStatusResource
extends DamageStatusResource

@export_group("Fire Settings", "fire_")
## 敌人死亡后的爆炸半径
@export var fire_explosion_radius: float = 40.0
## 敌人死亡后的爆炸产生的一次性伤害
@export var fire_explosion_damage: float = -20.0

## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	status_damage_type = DamageTypeResource.DamageType.FIRE


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
## 一次性伤害， obj_rn 需要传染对象的ResourceNode
func on_spread(obj_rn: ResourceNode) -> void:
	var ddr: DamageDataResource = DamageDataResource.new()
	ddr.total_damage = _calculate_final_value(fire_explosion_damage)
	var obj_dr: DamageResource = obj_rn.get_resource("damage")
	var obj_hr: HealthResource = obj_rn.get_resource("health")
	obj_hr.add_hp(ddr.total_damage)
	ddr.is_kill = obj_hr.is_dead
	if ddr.total_damage < 0.0:
		# show damage points but as positive numbers
		obj_dr.receive(ddr, status_damage_type)
