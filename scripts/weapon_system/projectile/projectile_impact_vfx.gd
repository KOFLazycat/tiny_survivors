## 子弹弹跳时的声音特效
class_name ProjectileBounceVfx
extends Node

@export var projectile_mover:ProjectileMover
@export var damage_sound_resource: SoundResource


func _ready()->void:
	assert(damage_sound_resource != null)
	projectile_mover.bounce_position.connect(spawn)


func spawn()->void:
	damage_sound_resource.play_managed()
