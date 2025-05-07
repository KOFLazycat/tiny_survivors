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
	var total_dmg: float = _calculate_final_value(status_value)
	_health_resource.add_hp(total_dmg)
	if total_dmg < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive_points(-total_dmg, false, status_damage_type)


## 效果移除时触发（子类可选实现）
func on_remove() -> void:
	pass

## 效果传播时触发（子类可选实现）
## 一次性伤害
func on_spread() -> void:
	var total_dmg: float = _calculate_final_value(fire_explosion_damage)
	print(total_dmg)
	_health_resource.add_hp(total_dmg)
	if total_dmg < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive_points(-total_dmg, false, status_damage_type)
