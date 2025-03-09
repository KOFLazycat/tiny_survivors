## Handles spawning new projectiles
class_name ProjectileSpawnerBase
extends ProjectileSpawner

## bullet spawn position
@export var bullet_spawn_position:Marker2D


func spawn()->void:
	assert(projectile_instance_resource != null)
	assert(axis_multiplication_resource != null)
	
	if !enabled:
		return
	prepare_spawn.emit()
	
	var new_damage_resource:DamageDataResource
	if new_damage:
		new_damage_resource = damage_data_resource.new_generation()
	else:
		new_damage_resource = damage_data_resource
	
	for angle:float in projectile_angles:
		var _config_callback:Callable = func (inst:Projectile2D)->void:
			# TODO: maybe there's better solution
			var _angle_delta:Vector2 = (direction.rotated(deg_to_rad(angle)) - direction) * axis_multiplication_resource.value
			
			inst.direction = (direction + _angle_delta).normalized()
			inst.damage_data_resource = new_damage_resource.new_split()
			inst.collision_mask = Bitwise.append_flags(inst.collision_mask, collision_mask)
			if is_instance_valid(bullet_spawn_position):
				inst.global_position = bullet_spawn_position.global_position
			else: 
				inst.global_position = initial_distance * direction * axis_multiplication_resource.value + projectile_position
		
		var _inst:Projectile2D = projectile_instance_resource.instance(_config_callback)
