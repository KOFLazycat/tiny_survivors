## 中毒效果资源脚本
class_name PoisonStatusResource
extends DamageStatusResource

## 传播半径
@export var speard_radius: float = 30.0

func tick(resource_node:ResourceNode, delta: float)->void:
	current_duration += delta
	if current_duration > base_duration:
		tick_finished.emit(self)
		return
	
	if current_duration > current_interval:
		current_interval += interval + randf_range(-0.2, 0.2)
		
		var _health_resource:HealthResource = resource_node.get_resource("health")
		var _damage_resource:DamageResource = resource_node.get_resource("damage")
		assert(_health_resource != null, "HealthResource not found")
		assert(_damage_resource != null, "DamageResource not found")
		if _health_resource.is_dead:
			tick_finished.emit(self)
			return
		
		var total_dmg: float = calculate_value(_damage_resource)
		_health_resource.add_hp(total_dmg)
		if total_dmg < 0.0:
			# show damage points but as positive numbers
			_damage_resource.receive_points(-total_dmg)
