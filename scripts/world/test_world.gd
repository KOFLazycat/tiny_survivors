class_name TestWorld
extends Node2D

@onready var timer: Timer = $Timer
@onready var ability_card: PackedScene = preload("res://scenes/ui/ability_card/ability_card.tscn")
@onready var health_ability_resource: AbilityResource = preload("res://resources/abilities/health_ability_resource.tres")
@onready var speed_ability_resource: AbilityResource = preload("res://resources/abilities/move_speed_ability_resource.tres")
@onready var fire_rate_ability_resource: AbilityResource = preload("res://resources/abilities/fire_rate_ability_resource.tres")


func _ready() -> void:
	PersistentData.saveable_list[0].load_resource()
	timer.timeout.connect(_on_timer_timeout)
	health_ability_resource.current_level = 2
	speed_ability_resource.current_level = 5
	fire_rate_ability_resource.current_level = 5


func _on_timer_timeout() -> void:
	var health_ability_card: AbilityCard = ability_card.instantiate()
	health_ability_card.ability_resource = health_ability_resource
	health_ability_card.global_position = Vector2(80, 160)
	add_child(health_ability_card)
	
	var speed_ability_card: AbilityCard = ability_card.instantiate()
	speed_ability_card.ability_resource = speed_ability_resource
	speed_ability_card.global_position = Vector2(160, 160)
	add_child(speed_ability_card)
	
	var fire_rate_ability_card: AbilityCard = ability_card.instantiate()
	fire_rate_ability_card.ability_resource = fire_rate_ability_resource
	fire_rate_ability_card.global_position = Vector2(240, 160)
	add_child(fire_rate_ability_card)
