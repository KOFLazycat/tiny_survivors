class_name LightningEffect
extends Node2D

## 雷资源
@export var lightning_status_resource: LightningStatusResource : set = set_lightning_status_resource
@export var area_detect: Area2D
@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D
@export var body_node: Node2D
@export var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)


# 设置雷资源
func set_lightning_status_resource(lsr: LightningStatusResource) -> void:
	lightning_status_resource = lsr
	if collision_shape.shape == null:
		collision_shape.shape = CircleShape2D.new()  # 若未初始化则新建
	collision_shape.shape.radius = lightning_status_resource.effect_radius  # 设置半径
	animation_player.play("lightning_start")
	#animation_player.queue("lightning_loop")
	animation_player.queue("lightning_end")


func _on_area_detect_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("enemies"):
		var obj_rn: ResourceNode = body.get_node("ResourceNode") as ResourceNode
		assert(obj_rn != null, "ResourceNode should not be null.")
		lightning_status_resource.on_spread(obj_rn)


func _on_animation_finished(anim: StringName) -> void:
	if anim == "lightning_end":
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
