class_name LightningEffect
extends Node2D

## 雷资源
#@export var fire_status_resource: FireStatusResource : set = set_fire_status_resource
#@export var area_detect: Area2D
#@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D
@export var body_node: Node2D
@export var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player.play("lightning_start")
	animation_player.queue("lightning_loop")
	animation_player.queue("lightning_end")
	
	animation_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim: StringName) -> void:
	if anim == "lightning_end":
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
