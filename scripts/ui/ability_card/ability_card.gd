## 技能card，点击升级技能
class_name AbilityCard
extends Button

@export var ability_resource: AbilityResource

@onready var ability_card: AbilityCard = $"."
@onready var level_label: Label = %LevelLabel
@onready var texture_rect: TextureRect = %TextureRect
#@onready var detail_label: Label = %DetailLabel

var ability_system: AbilitySystem
var tween: Tween


func _ready() -> void:
	ability_system = get_tree().get_nodes_in_group("ability_system").pop_front()
	assert(ability_resource != null)
	assert(ability_system != null)
	ability_card.pressed.connect(_on_ability_card_pressed)
	ability_resource.updated.connect(_on_ability_resource_updated)
	
	## 浮动
	tween = create_tween().set_loops(0)  # 0表示无限循环
	tween.set_trans(Tween.TRANS_SINE)    # 使用正弦过渡
	tween.set_ease(Tween.EASE_IN_OUT)    # 缓入缓出使动画更平滑
	
	# 上浮10像素，耗时1秒
	tween.tween_property(self, "position:y", position.y - randf_range(2.0, 6.0), 1.0)
	# 下沉回原位，耗时1秒
	tween.tween_property(self, "position:y", position.y + randf_range(2.0, 6.0), 1.0)


func _process(delta: float) -> void:
	level_label.text = str(ability_resource.current_level)
	#detail_label.text = str(ability_resource.description)


func _on_ability_card_pressed() -> void:
	ability_system.acquire_ability(ability_resource)
	queue_free()


func _on_ability_resource_updated() -> void:
	level_label.text = str(ability_resource.current_level)
	#detail_label.text = str(ability_resource.description)
