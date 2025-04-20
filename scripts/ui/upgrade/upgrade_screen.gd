## 升级card界面
class_name UpgradeScreen
extends Control
## 选择技能card
signal ability_card_selected(ability_card: AbilityCard)

## 经验管理组件
@export var experience_manager: ExperienceManager
## 技能池管理组件
@export var ability_pool_manager: AbilityPoolManager
## 技能card场景
@export var ability_card_scene: PackedScene
## card显示相对延迟时间
@export var display_delay: float = 0.2

@onready var ability_card_container: HBoxContainer = %AbilityCardContainer
@onready var refresh_container: HBoxContainer = %RefreshContainer
@onready var refresh_button: Button = %RefreshButton
@onready var color_rect: ColorRect = %ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_deferred("visible", false)
	refresh_container.modulate.a = 0.0
	color_rect.modulate.a = 0.0
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	experience_manager.level_up.connect(_on_experience_manager_level_up)


## 逆序删除所有子节点
func clear_cards() -> void:
	for i in range(ability_card_container.get_child_count() - 1, -1, -1):
		var child: AbilityCard = ability_card_container.get_child(i)
		child.queue_free()


func spawn_card() -> void:
	randomize()
	clear_cards()
	var abilities_res: Array[AbilityResource] = ability_pool_manager.get_upgrade_options()
	abilities_res.shuffle()
	for i:int in range(abilities_res.size()):
		var ability_card: AbilityCard = ability_card_scene.instantiate()
		ability_card_container.add_child(ability_card)
		ability_card.ability_resource = abilities_res[i]
		ability_card.play_animation("in", i * display_delay)
		ability_card.pressed.connect(_on_ability_card_pressed.bind(ability_card))
		if i == (abilities_res.size() - 1):
			await ability_card.animation_player.animation_finished
			var tween: Tween = create_tween()
			tween.tween_property(refresh_container, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_ability_card_pressed(ability_card: AbilityCard) -> void:
	for card: AbilityCard in ability_card_container.get_children():
		if card == ability_card:
			card.play_animation("selected")
			ability_pool_manager.add_ability_pick_list(ability_card.ability_resource)
			animation_player.play("out")
			await card.animation_player.animation_finished
			ability_card_selected.emit(ability_card)
			get_tree().paused = false
			set_deferred("visible", false)
			refresh_container.modulate.a = 0.0
			color_rect.modulate.a = 0.0
		else:
			card.on_pressed()
			card.play_animation("discard")


func _on_experience_manager_level_up(current_level: int) -> void:
	#await get_tree().create_timer(0.2).timeout
	get_tree().paused = true
	set_deferred("visible", true)
	animation_player.play("in")
	await animation_player.animation_finished
	spawn_card()


func _on_refresh_button_pressed() -> void:
	spawn_card()
