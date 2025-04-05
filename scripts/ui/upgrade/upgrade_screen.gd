## 升级card界面
class_name UpgradeScreen
extends Control

## 经验管理组件
@export var experience_manager: ExperienceManager
## 技能池管理组件
@export var ability_pool_manager: AbilityPoolManager
## 技能card场景
@export var ability_card_scene: PackedScene

@onready var ability_card_container: HBoxContainer = %AbilityCardContainer


var card_num: int = 4

func _ready() -> void:
	experience_manager.level_up.connect(_on_experience_manager_level_up)


func _on_ability_card_pressed(ability_card: AbilityCard) -> void:
	for card: AbilityCard in ability_card_container.get_children():
		if card == ability_card:
			card.play_animation("selected")
			await card.animation_player.animation_finished
			get_tree().paused = false
		else:
			card.play_animation("discard")


func _on_experience_manager_level_up(current_level: int) -> void:
	get_tree().paused = true
	print(ability_pool_manager.get_upgrade_options())
	for i in range(card_num):
		var ability_card: AbilityCard = ability_card_scene.instantiate()
		ability_card_container.add_child(ability_card)
		ability_card.play_animation("in", i * 0.2)
		ability_card.pressed.connect(_on_ability_card_pressed.bind(ability_card))
