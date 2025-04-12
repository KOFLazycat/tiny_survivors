## Handles spawning new projectiles
## 增加子弹发射完成的信号
class_name ProjectileSpawnerBase
extends ProjectileSpawner

## 一个子弹生产完成的信号
signal one_spawn_done

## 武器弹匣容量资源
@export var ammo_remain_resource: IntResource
## Sound of shooting projectile
@export var sound_resource:SoundResource
## 基础散弹数量资源，通过该值自动生成projectile_angles，不要主动去设置projectile_angles
@export var shot_number_resource: IntResource
## 两个子弹之间的夹角值，单位度
@export var interval_angle: float = 10.0


func _ready() -> void:
	assert(shot_number_resource != null)
	set_angles()
	shot_number_resource.updated.connect(_on_shot_number_updated)

# 第一个子弹的夹角计算规律：
	#1 0
	#2 -5
	#3 -10
	#4 -15
	#5 -20
func set_angles() -> void:
	projectile_angles.clear()
	var first_angle: float = (shot_number_resource.value - 1) * (interval_angle/2) * (-1)
	for i:int in range(shot_number_resource.value):
		projectile_angles.append(first_angle + i * interval_angle)


func set_enabled(value:bool)->void:
	enabled = value


## 生产子弹
func spawn()->void:
	assert(projectile_instance_resource != null)
	assert(axis_multiplication_resource != null)
	assert(ammo_remain_resource != null)
	
	if !enabled:
		return
	prepare_spawn.emit()
	
	var new_damage_resource:DamageDataResource
	if new_damage:
		new_damage_resource = damage_data_resource.new_generation()
	else:
		new_damage_resource = damage_data_resource
	
	for angle:float in projectile_angles:
		if ammo_remain_resource.value <= 0:
			return
		
		ammo_remain_resource.value -= 1
		
		var _config_callback:Callable = func (inst:Projectile2D)->void:
			# TODO: maybe there's better solution
			var _angle_delta:Vector2 = (direction.rotated(deg_to_rad(angle)) - direction) * axis_multiplication_resource.value
			
			inst.direction = (direction + _angle_delta).normalized()
			inst.damage_data_resource = new_damage_resource.new_split()
			inst.collision_mask = Bitwise.append_flags(inst.collision_mask, collision_mask)
			inst.global_position = initial_distance * direction * axis_multiplication_resource.value + projectile_position
		
		var _inst:Projectile2D = projectile_instance_resource.instance(_config_callback)
		one_spawn_done.emit()
	## 射击音效
	sound_resource.play_managed()


func _on_shot_number_updated() -> void:
	set_angles()
