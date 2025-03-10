class_name FireParticlesSpawner
extends Node

## projectile 生成器
@export var projectile_spawner: ProjectileSpawner
## 开火粒子特效资源
@export var fire_particles_instance_resource: InstanceResource
## 开火粒子位置
@export var fire_marker_2d: Marker2D


func _ready() -> void:
	if !projectile_spawner.prepare_spawn.is_connected(on_projectile_spawner_prepare_spawn):
		projectile_spawner.prepare_spawn.connect(on_projectile_spawner_prepare_spawn)


func on_projectile_spawner_prepare_spawn() -> void:
	var _partickle_config:Callable = func(inst:Node2D)->void:		
		inst.global_position = fire_marker_2d.global_position
		inst.rotation = projectile_spawner.direction.angle()
	fire_particles_instance_resource.instance(_partickle_config)
