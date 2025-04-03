## 升级card界面
class_name UpgradeScreen
extends Control

## 技能card场景
@export var ability_card_scene: PackedScene

@onready var ability_card_container: HBoxContainer = %AbilityCardContainer


var card_num: int = 4

func _ready() -> void:
	for i in range(card_num):
		var ability_card: AbilityCard = ability_card_scene.instantiate()
		ability_card_container.add_child(ability_card)
		ability_card.play_animation("in", i * 0.2)
		ability_card.pressed.connect(_on_ability_card_pressed.bind(ability_card))


func _on_ability_card_pressed(ability_card: AbilityCard) -> void:
	for card in ability_card_container.get_children():
		if card == ability_card:
			card.play_animation("selected")
		else:
			card.play_animation("discard")
