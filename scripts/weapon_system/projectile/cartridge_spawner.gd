## 弹壳弹飞生成效果
class_name CartridgeSpawner
extends Node

## projectile 生成器
@export var projectile_spawner: ProjectileSpawner
## 弹壳资源
@export var cartridge_instance_resource: InstanceResource
## 开火枪口位置
@export var muzzle_pos: Marker2D


func _ready() -> void:
	if !projectile_spawner.prepare_spawn.is_connected(on_projectile_spawner_prepare_spawn):
		projectile_spawner.prepare_spawn.connect(on_projectile_spawner_prepare_spawn)


func on_projectile_spawner_prepare_spawn() -> void:
	var _partickle_config:Callable = func(inst:Cartridge)->void:
		inst.global_position = muzzle_pos.global_position
		inst.start(projectile_spawner.direction)
	cartridge_instance_resource.instance(_partickle_config)
