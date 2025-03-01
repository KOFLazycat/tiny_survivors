class_name WeaponTrigger
extends Node

signal shoot_event

## Toggle weapons capability to spawn projectile
@export var enabled:bool = true
@export var weapon:Weapon
@export var projectile_spawner:ProjectileSpawner

## Sound of shooting projectile
@export var sound_resource:SoundResource
@export var can_shoot:bool = true

var input_resource:InputResource

func _ready()->void:
	input_resource = weapon.resource_node.get_resource("input")
	if !weapon.enabled_changed.is_connected(set_enabled):
		weapon.enabled_changed.connect(set_enabled)
	set_enabled(weapon.enabled)
	projectile_spawner.damage_data_resource = weapon.damage_data_resource
	projectile_spawner.collision_mask = Bitwise.append_flags(projectile_spawner.collision_mask, weapon.collision_mask)
	
	# when using with pool node
	request_ready()

## Toggle connections to the action input and controls visibility
## TODO: better system would be using update tick instead of signal events
func set_enabled(value:bool)->void:
	enabled = value
	if enabled:
		if !input_resource.action_pressed.is_connected(on_shoot):
			input_resource.action_pressed.connect(on_shoot)
	else:
		if input_resource.action_pressed.is_connected(on_shoot):
			input_resource.action_pressed.disconnect(on_shoot)

## Setup and trigger a projectile spawner
func on_shoot()->void:
	if !can_shoot || !weapon.enabled:
		return
	shoot_event.emit()
	projectile_spawner.projectile_position = weapon.global_position
	## Don't normalize direction if it is used for target position
	var d: Vector2 = get_direction_tmp()
	if d == Vector2.ZERO:
		projectile_spawner.direction = input_resource.aim_direction
	else:
		projectile_spawner.direction = d
	projectile_spawner.spawn()
	sound_resource.play_managed()

## Toggle ability to spawn projectiles
func set_can_shoot(value:bool)->void:
	can_shoot = value

func can_retrigger()->bool:
	return input_resource.action_1

## Return direction information
func get_direction()->Vector2:
	return input_resource.aim_direction


func get_closest_enemy() -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest = null
	var min_dist = INF
	
	for enemy in enemies:
		var dist = weapon.global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest


func get_direction_tmp() -> Vector2:
	var c: CharacterBody2D = get_closest_enemy()
	if !is_instance_valid(c):
		return Vector2.ZERO
	return (c.global_position - weapon.global_position).normalized()
