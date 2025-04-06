## 技能card，点击升级技能
class_name AbilityCard
extends Button

## 能力资源
@export var ability_resource: AbilityResource: set = set_ability_resource

@onready var panel_container: PanelContainer = %PanelContainer
@onready var level_label: Label = %LevelLabel
@onready var ability_name_label: Label = %AbilityNameLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hover_animation_player: AnimationPlayer = $HoverAnimationPlayer

var hover_tween: Tween


func _ready() -> void:
	init_card()


func init_card() -> void:
	set_process(false)
	disabled = true
	pivot_offset = size / 2.0
	modulate = Color.TRANSPARENT
	scale = Vector2.ZERO
	
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)


func _on_pressed() -> void:
	set_deferred("disabled", true)

## 设置技能资源
func set_ability_resource(v: AbilityResource) -> void:
	ability_resource = v
	level_label.text = str(ability_resource.current_level)
	ability_name_label.text = ability_resource.ability_name


func play_animation(ani_name: StringName, delay: float = 0.0) -> void:
	if animation_player.has_animation(ani_name) and !animation_player.is_playing():
		await get_tree().create_timer(delay).timeout
		animation_player.play(ani_name)


func _on_mouse_entered() -> void:
	set_deferred("disabled", false)
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	hover_tween.set_parallel(true).tween_property(self, "modulate:a", 1.0, 0.15)
	hover_tween.tween_callback(hover_animation_player.play.bind("swing"))


func _on_mouse_exited() -> void:
	set_deferred("disabled", true)
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	hover_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	hover_tween.set_parallel(true).tween_property(self, "modulate:a", 0.5, 0.15)
	hover_tween.tween_callback(hover_animation_player.stop)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"discard":
			queue_free()
		"selected":
			queue_free()
