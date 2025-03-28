## 技能card，点击升级技能
class_name AbilityCard
extends Button

@export var ability_resource: AbilityResource

@onready var panel_container: PanelContainer = %PanelContainer
@onready var level_label: Label = %LevelLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var line_2d: Line2D = $Line2D
#@onready var detail_label: Label = %DetailLabel

var ability_system: AbilitySystem
# 上下浮动动画
var float_tween : Tween
# 左右摆动动画
var sway_tween  : Tween


func _ready() -> void:
	ability_system = get_tree().get_nodes_in_group("ability_system").pop_front()
	assert(ability_resource != null)
	assert(ability_system != null)
	line_2d.visible = false
	pressed.connect(_on_pressed)
	ability_resource.updated.connect(_on_ability_resource_updated)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	## 浮动
	float_tween  = create_tween().set_loops(0)  # 0表示无限循环
	float_tween .set_trans(Tween.TRANS_SINE)    # 使用正弦过渡
	float_tween .set_ease(Tween.EASE_IN_OUT)    # 缓入缓出使动画更平滑
	# 上浮10像素，耗时1秒
	float_tween .tween_property(self, "position:y", position.y - randf_range(2.0, 6.0), 1.0)
	# 下沉回原位，耗时1秒
	float_tween .tween_property(self, "position:y", position.y + randf_range(2.0, 6.0), 1.0)
	
	## 摆动
	sway_tween  = create_tween().set_loops(0)  # 0表示无限循环
	sway_tween.set_trans(Tween.TRANS_SINE)
	sway_tween.set_ease(Tween.EASE_IN_OUT)
	sway_tween.tween_property(self, "rotation_degrees", 1, 0.5)  # 摆动5度
	sway_tween.tween_property(self, "rotation_degrees", -1, 0.5)  # 摆动5度


func _process(delta: float) -> void:
	level_label.text = str(ability_resource.current_level)
	#detail_label.text = str(ability_resource.description)


func _on_pressed() -> void:
	ability_system.acquire_ability(ability_resource)
	queue_free()


func _on_ability_resource_updated() -> void:
	level_label.text = str(ability_resource.current_level)
	#detail_label.text = str(ability_resource.description)


func _on_mouse_entered() -> void:
	if float_tween.is_running():
		float_tween.stop()
	if sway_tween.is_running():
		sway_tween.stop()
	
	line_2d.visible = true
	set_deferred("rotation", 0)
	set_deferred("scale", Vector2(1.2, 1.2))


func _on_mouse_exited() -> void:
	float_tween.play()
	sway_tween.play()
	line_2d.visible = false
	set_deferred("scale", Vector2(1.0, 1.0))
