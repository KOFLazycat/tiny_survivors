class_name FireEffect
extends Node2D

## 火资源
@export var fire_status_resource: FireStatusResource : set = set_fire_status_resource
@export var area_detect: Area2D
@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D
@export var body_node: Node2D
@export var animation_player: AnimationPlayer


func _ready() -> void:
	if !area_detect.body_entered.is_connected(_on_area_detect_body_entered):
		area_detect.body_entered.connect(_on_area_detect_body_entered)
	request_ready()

# 设置火资源
func set_fire_status_resource(fsr: FireStatusResource) -> void:
	fire_status_resource = fsr
	if collision_shape.shape == null:
		collision_shape.shape = CircleShape2D.new()  # 若未初始化则新建
	collision_shape.shape.radius = fire_status_resource.effect_radius  # 设置半径
	var scale_i: float = fire_status_resource.effect_radius/(sprite.texture.get_height()/2.0) # 爆炸动画方位需要跟探测方向一致
	body_node.scale = Vector2(scale_i, scale_i)
	body_node.rotation = randf_range(0, TAU)
	animation_player.play("explosion")


func _on_area_detect_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("enemies"):
		var obj_rn: ResourceNode = body.get_node("ResourceNode") as ResourceNode
		assert(obj_rn != null, "ResourceNode should not be null.")
		fire_status_resource.on_spread(obj_rn)
