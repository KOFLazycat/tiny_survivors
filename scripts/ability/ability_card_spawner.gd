## 技能card生成器
class_name AbilityCardSpawner
extends Node

@export var experience_manager: ExperienceManager 

@onready var ability_card: PackedScene = preload("res://scenes/ui/ability_card/ability_card.tscn")
@onready var health_ability_resource: AbilityResource = preload("res://resources/abilities/health_ability_resource.tres")
@onready var speed_ability_resource: AbilityResource = preload("res://resources/abilities/move_speed_ability_resource.tres")
@onready var fire_rate_ability_resource: AbilityResource = preload("res://resources/abilities/fire_rate_ability_resource.tres")


func _ready() -> void:
	experience_manager.level_up.connect(_on_experience_manager_level_up)


func _on_experience_manager_level_up(current_level: int) -> void:
	get_tree().paused = true
	
	health_ability_resource.current_level = current_level + 1
	speed_ability_resource.current_level = current_level + 1
	fire_rate_ability_resource.current_level = current_level + 1
	
	var health_ability_card: AbilityCard = ability_card.instantiate()
	health_ability_card.ability_resource = health_ability_resource
	health_ability_card.target_pos = Vector2(180, 30)
	add_child(health_ability_card)
	await health_ability_card.movement_tween.finished
	
	var speed_ability_card: AbilityCard = ability_card.instantiate()
	speed_ability_card.ability_resource = speed_ability_resource
	speed_ability_card.target_pos = Vector2(220, 30)
	add_child(speed_ability_card)
	await speed_ability_card.movement_tween.finished
	
	var fire_rate_ability_card: AbilityCard = ability_card.instantiate()
	fire_rate_ability_card.ability_resource = fire_rate_ability_resource
	fire_rate_ability_card.target_pos = Vector2(260, 30)
	add_child(fire_rate_ability_card)
	await fire_rate_ability_card.movement_tween.finished
	
	get_tree().paused = false
