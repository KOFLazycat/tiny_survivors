class_name PoisonEffect
extends Node2D

## 毒资源
@export var poison_status_resource: PoisonStatusResource : set = set_poison_status_resource


func _ready() -> void:
	if !$SpreadDetect.body_entered.is_connected(_on_spread_detect_body_entered):
		$SpreadDetect.body_entered.connect(_on_spread_detect_body_entered)
	request_ready()

# 设置毒资源
func set_poison_status_resource(psr: PoisonStatusResource) -> void:
	poison_status_resource = psr
	if $SpreadDetect/CollisionShape2D.shape == null:
		$SpreadDetect/CollisionShape2D.shape = CircleShape2D.new()  # 若未初始化则新建
	$SpreadDetect/CollisionShape2D.shape.radius = poison_status_resource.speard_radius  # 设置半径
	var scale_i: float = poison_status_resource.speard_radius/($Body/Stretch/Sprite2D.texture.get_height()/2) # 爆炸动画方位需要跟探测方向一致
	$Body.scale = Vector2(scale_i, scale_i)
	$Body.rotation = randf_range(0, TAU)
	$Body/Stretch/Sprite2D/AnimationPlayer.play("explosion")


func _on_spread_detect_body_entered(body: Node2D) -> void:
	# 传染
	if body is CharacterBody2D and body.is_in_group("enemies"):
		var rn: ResourceNode = body.get_node("ResourceNode") as ResourceNode
		assert(rn != null, "ResourceNode should not be null.")
		var damage_resource: DamageResource = rn.get_resource("damage")
		assert(damage_resource != null, "DamageResource not found")
		poison_status_resource.process(rn, damage_resource, false)
