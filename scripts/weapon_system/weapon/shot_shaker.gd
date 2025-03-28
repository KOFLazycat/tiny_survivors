## 射击时震动
class_name ShotShaker
extends Node

@export var weapon_trigger:WeaponTrigger
@export var player_shot_shake:CameraShakeResource


func _ready()->void:
	assert(weapon_trigger != null)
	weapon_trigger.shoot_event.connect(play)


func play()->void:
	player_shot_shake.play()
