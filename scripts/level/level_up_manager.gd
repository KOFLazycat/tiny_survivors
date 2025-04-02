## 管理用户升级情况
class_name LevelUpManager
extends Node

@export var experience_manager: ExperienceManager 

@onready var ability_card: PackedScene = preload("res://scenes/ui/ability_card/ability_card.tscn")
@onready var health_ability_resource: AbilityResource = preload("res://resources/abilities/health_ability_resource.tres")
@onready var speed_ability_resource: AbilityResource = preload("res://resources/abilities/move_speed_ability_resource.tres")
@onready var fire_rate_ability_resource: AbilityResource = preload("res://resources/abilities/fire_rate_ability_resource.tres")

## 开始选择能力信号
signal select_card_begin
## 能力提升选择完毕信号
signal select_card_end(ability_card: AbilityCard)


func _ready() -> void:
	experience_manager.level_up.connect(_on_experience_manager_level_up)
	select_card_end.connect(_on_select_card_end)


func _on_experience_manager_level_up() -> void:
	get_tree().paused = true
	
	# 获取窗口位置（左上角坐标）和尺寸
	var window_position: Vector2 = DisplayServer.window_get_position()
	var window_size: Vector2 = DisplayServer.window_get_size()

	# 计算中心位置（转换为浮点数避免整数除法问题）
	var center: Vector2 = window_position + (Vector2(window_size) / 2.0)
	print(window_position, window_size, center)
	
	select_card_begin.emit()


func _on_select_card_end(_ability_card: AbilityCard) -> void:
	get_tree().paused = false
