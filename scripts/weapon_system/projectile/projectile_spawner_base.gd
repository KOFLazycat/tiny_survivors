## Handles spawning new projectiles
## 增加子弹发射完成的信号
class_name ProjectileSpawnerBase
extends ProjectileSpawner

## 一个子弹生产完成的信号
signal one_spawn_done

## 武器弹匣容量资源
@export var weapon_capacity_resource: IntResource


func set_enabled(value:bool)->void:
	enabled = value

## 生产子弹
func spawn()->void:
	assert(projectile_instance_resource != null)
	assert(axis_multiplication_resource != null)
	assert(weapon_capacity_resource != null)
	
	if !enabled:
		return
	prepare_spawn.emit()
	
	var new_damage_resource:DamageDataResource
	if new_damage:
		new_damage_resource = damage_data_resource.new_generation()
	else:
		new_damage_resource = damage_data_resource
	
	for angle:float in projectile_angles:
		if weapon_capacity_resource.value <= 0:
			return
		
		weapon_capacity_resource.value -= 1
		
		var _config_callback:Callable = func (inst:Projectile2D)->void:
			# TODO: maybe there's better solution
			var _angle_delta:Vector2 = (direction.rotated(deg_to_rad(angle)) - direction) * axis_multiplication_resource.value
			
			inst.direction = (direction + _angle_delta).normalized()
			inst.damage_data_resource = new_damage_resource.new_split()
			inst.collision_mask = Bitwise.append_flags(inst.collision_mask, collision_mask)
			inst.global_position = initial_distance * direction * axis_multiplication_resource.value + projectile_position
		
		var _inst:Projectile2D = projectile_instance_resource.instance(_config_callback)
		one_spawn_done.emit()
