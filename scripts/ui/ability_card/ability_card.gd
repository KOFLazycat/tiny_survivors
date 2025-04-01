## 技能card，点击升级技能
class_name AbilityCard
extends Button

## 能力资源
@export var ability_resource: AbilityResource
## 初始位置
@export var init_pos: Vector2
## 初始角度
@export var init_rotation: float = 0.0
## 初始缩放
@export var init_scale: Vector2 = Vector2(1.5, 1.5)
## 目标位置
@export var target_pos: Vector2
## 目标角度
@export var target_rotation: float = 0.0
## 目标缩放
@export var target_scale: Vector2 = Vector2.ONE
## 移动动画时间
@export var animation_duration: float = 1.0

@onready var panel_container: PanelContainer = %PanelContainer
@onready var level_label: Label = %LevelLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var line_2d: Line2D = $Line2D

var ability_system: AbilitySystem
# 上下浮动动画
var float_tween : Tween
# 左右摆动动画
var sway_tween  : Tween
# 鼠标hover动画
var hover_tween: Tween
# 移动动画
var movement_tween: Tween


func _ready() -> void:
	ability_system = get_tree().get_nodes_in_group("ability_system").pop_front()
	assert(ability_resource != null)
	assert(ability_system != null)
	
	#	重置卡片
	reset_card()
	
	pressed.connect(_on_pressed)
	ability_resource.updated.connect(_on_ability_resource_updated)
	
	move_to_target_pos()
	
	### 浮动
	#float_tween  = create_tween().set_loops(0)  # 0表示无限循环
	#float_tween .set_trans(Tween.TRANS_SINE)    # 使用正弦过渡
	#float_tween .set_ease(Tween.EASE_IN_OUT)    # 缓入缓出使动画更平滑
	## 上浮10像素，耗时1秒
	#float_tween .tween_property(self, "position:y", position.y - randf_range(2.0, 6.0), 1.0)
	## 下沉回原位，耗时1秒
	#float_tween .tween_property(self, "position:y", position.y + randf_range(2.0, 6.0), 1.0)
	#
	### 摆动
	#sway_tween  = create_tween().set_loops(0)  # 0表示无限循环
	#sway_tween.set_trans(Tween.TRANS_SINE)
	#sway_tween.set_ease(Tween.EASE_IN_OUT)
	#sway_tween.tween_property(self, "rotation_degrees", 1, 0.5)  # 摆动5度
	#sway_tween.tween_property(self, "rotation_degrees", -1, 0.5)  # 摆动5度


func _process(_delta: float) -> void:
	pass
	#global_position = global_position - offset
	#level_label.text = str(ability_resource.current_level)
	#detail_label.text = str(ability_resource.description)


func reset_card() -> void:
	set_process(false)
	disabled = true
	
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)
	
	#line_2d.visible = false
	pivot_offset = size / 2.0
	global_position = init_pos
	rotation = init_rotation
	#scale = init_scale
	modulate.a = 0


func move_to_target_pos() -> void:
	set_process(true)
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
	movement_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#
	movement_tween.tween_property(self, "modulate:a", 0.3, 0.4)
	movement_tween.parallel().tween_property(self, "global_position:y", init_pos.y - 100, 0.4)
	movement_tween.parallel().tween_property(self, "scale", init_scale, 0.4)
	
	movement_tween.tween_property(self, "rotation", TAU + target_rotation, animation_duration).from(rotation)
	movement_tween.parallel().tween_property(self, "global_position", target_pos, animation_duration)
	movement_tween.parallel().tween_property(self, "modulate:a", 1.0, animation_duration)
	movement_tween.parallel().tween_property(self, "scale", target_scale, animation_duration)
	movement_tween.parallel().tween_property(self, "scale", target_scale, animation_duration)
	
	await movement_tween.finished
	
	# 连接信号
	disabled = false
	if !mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if !mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)


func _on_pressed() -> void:
	ability_system.acquire_ability(ability_resource)
	queue_free()


func _on_ability_resource_updated() -> void:
	level_label.text = str(ability_resource.current_level)
	#detail_label.text = str(ability_resource.description)


func _on_mouse_entered() -> void:
	#if float_tween.is_running():
		#float_tween.stop()
	#if sway_tween.is_running():
		#sway_tween.stop()
	
	#line_2d.visible = true
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	hover_tween.tween_property(self, "scale", Vector2(0.65, 0.65), 0.15)


func _on_mouse_exited() -> void:
	#float_tween.play()
	#sway_tween.play()
	#line_2d.visible = false
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	hover_tween.tween_property(self, "scale", target_scale, 0.15)
