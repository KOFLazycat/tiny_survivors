class_name WeapomAutoAim
extends Node

@export var weapon:Weapon
@export var weapon_rotation: WeaponRotation
@export var enemy_attackable_resource: EnemyAttactableResource


func _ready() -> void:
	assert(weapon != null)
	assert(weapon_rotation != null)
	assert(enemy_attackable_resource != null)


func get_closest_enemy() -> CharacterBody2D:
	var closest: CharacterBody2D
	var min_dist: float = INF
	if enemy_attackable_resource.list.size() > 0:
		for enemy in enemy_attackable_resource.list:
			var dist = weapon.global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = enemy
	return closest


func get_direction() -> Vector2:
	var c: CharacterBody2D = get_closest_enemy()
	if !is_instance_valid(c):
		return Vector2.ZERO
	return (c.global_position - weapon.global_position).normalized()
