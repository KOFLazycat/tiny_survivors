class_name LightningEffect
extends Node2D

## 雷资源
@export var lightning_status_resource: LightningStatusResource : set = set_lightning_status_resource
@export var area_detect: Area2D
@export var collision_shape: CollisionShape2D
@export var sprite: Sprite2D
@export var body_node: Node2D
@export var animation_player: AnimationPlayer
@onready var pool_node: PoolNode = $PoolNode

var is_spreadable: bool = false

func _ready() -> void:
	modulate.a = 1.0
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
		##TODO 可能存在BUG，即使body超过collision_shape检测范围也有可能被检测到
		var dis: float = global_position.distance_to(body.global_position)
		if dis >= lightning_status_resource.effect_radius * 1.1:
			prints("检测到对象:", body.name, " 位置:", body.global_position, " 检测范围:", lightning_status_resource.effect_radius, " 距离:", dis)
			return
		
		var obj_rn: ResourceNode = body.get_node("ResourceNode") as ResourceNode
		assert(obj_rn != null, "ResourceNode should not be null.")
		lightning_status_resource.on_spread(obj_rn)


func _on_animation_finished(anim: StringName) -> void:
	if anim == "lightning_end":
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.tween_callback(pool_node.pool_return)
