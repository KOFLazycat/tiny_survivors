class_name IceEffect
extends Node2D

## 冰资源
@export var ice_status_resource: IceStatusResource : set = set_ice_status_resource
@export var area_detect: Area2D
@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D
@export var body_node: Node2D
@export var animation_player: AnimationPlayer
@onready var pool_node: PoolNode = $PoolNode

var is_spreadable: bool = false

func _ready() -> void:
	if !animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
	
	if !area_detect.body_entered.is_connected(_on_area_detect_body_entered):
		area_detect.body_entered.connect(_on_area_detect_body_entered)
	
	if is_spreadable:
		area_detect.monitoring = true
	else:
		area_detect.monitoring = false
	
	request_ready()


# 设置雷资源
func set_ice_status_resource(isr: IceStatusResource) -> void:
	ice_status_resource = isr
	if collision_shape.shape == null:
		collision_shape.shape = CircleShape2D.new()  # 若未初始化则新建
	collision_shape.shape.radius = ice_status_resource.effect_radius  # 设置半径
	var scale_i: float = ice_status_resource.effect_radius/(sprite.texture.get_height()/2.0) # 爆炸动画方位需要跟探测方向一致
	body_node.scale = Vector2(scale_i, scale_i)
	body_node.rotation = randf_range(0, TAU)
	animation_player.play("explosion")


func _on_area_detect_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("enemies"):
		##TODO 可能存在BUG，即使body超过collision_shape检测范围也有可能被检测到
		var dis: float = global_position.distance_to(body.global_position)
		if dis >= ice_status_resource.effect_radius * 1.1:
			prints("检测到对象:", body.name, " 位置:", body.global_position, " 检测范围:", ice_status_resource.effect_radius, " 距离:", dis)
			return
		var obj_rn: ResourceNode = body.get_node("ResourceNode") as ResourceNode
		assert(obj_rn != null, "ResourceNode should not be null.")
		ice_status_resource.on_spread(obj_rn)


func _on_animation_finished(anim: StringName) -> void:
	if anim == "explosion":
		area_detect.monitoring = false
