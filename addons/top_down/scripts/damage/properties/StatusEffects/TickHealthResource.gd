## Attaches to target and ticks value to health.
## Can negative to be damage and positive to heal.
class_name TickHealthResource
extends DamageStatusResource

### 计时结束
#signal tick_finished(ds: DamageStatusResource)
#
#@export_range(0.0, 1.0) var chance:float = 0.75
#
#@export var ticks:int = 3
#
#@export var value:float
#
#func process(resource_node:ResourceNode, damage_resource:DamageResource = null, is_stored:bool = false)->void:
	#if randf() > chance:
		#return
	#
	#if damage_resource == null:
		#damage_resource = resource_node.get_resource("damage")
	#
	#if is_stored:
		#damage_resource.add_status_effect(self)
	#
	#var _health_resource:HealthResource = resource_node.get_resource("health")
	#assert(_health_resource != null)
	#tick(damage_resource, _health_resource, ticks)


#func tick(damage_resource:DamageResource, health_resource:HealthResource, remaining_ticks:int)->void:
	#if health_resource.is_dead || remaining_ticks < 1:
		#tick_finished.emit(self)
		#return
	#
	#health_resource.add_hp(value)
	#if value < 0.0:
		## show damage points but as positive numbers
		#damage_resource.receive_points(-value)
	#
	#remaining_ticks -= 1
	#var tween:Tween = damage_resource.owner.create_tween()
	#tween.tween_callback(tick.bind(damage_resource, health_resource, remaining_ticks)).set_delay(interval)
