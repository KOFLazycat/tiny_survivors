class_name WeaponTriggerAuto
extends WeaponTrigger

@export var weapom_auto_aim:WeapomAutoAim


func _process(delta: float) -> void:
	if weapom_auto_aim.enemy_attackable_resource.list.size() > 0:
		on_shoot()


func set_enabled(value:bool)->void:
	enabled = value


## Setup and trigger a projectile spawner
func on_shoot()->void:
	var direction: Vector2 = weapom_auto_aim.get_direction()
	if !can_shoot || !weapon.enabled || direction == Vector2.ZERO:
		return
	shoot_event.emit()
	projectile_spawner.projectile_position = weapon.global_position
	## Don't normalize direction if it is used for target position
	projectile_spawner.direction = direction
	projectile_spawner.spawn()
	sound_resource.play_managed()
