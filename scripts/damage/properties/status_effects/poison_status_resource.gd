## 中毒效果资源脚本
class_name PoisonStatusResource
extends DamageStatusResource

## 传播半径
@export var speard_radius: float = 30.0

func tick(resource_node:ResourceNode, damage_resource:DamageResource, remaining_ticks:float)->void:
	var _health_resource:HealthResource = resource_node.get_resource("health")
	assert(_health_resource != null, "HealthResource not found")
	if _health_resource.is_dead || remaining_ticks < 0.0:
		tick_finished.emit(self)
		return
	
	var total_dmg: float = calculate_value(damage_resource)
	_health_resource.add_hp(total_dmg)
	if total_dmg < 0.0:
		# show damage points but as positive numbers
		damage_resource.receive_points(-total_dmg)
	
	var offset: float = randf_range(-0.2, 0.2)
	remaining_ticks -= interval
	tick_tween = damage_resource.owner.create_tween()
	tick_tween.tween_callback(tick.bind(resource_node, damage_resource, remaining_ticks)).set_delay(interval + offset)


func _on_actor_died() -> void:
	if tick_tween:
		tick_tween.kill()
