extends Node

signal cooldown_started
signal cooldown_finished

@export var resource_node:ResourceNode
@export var cooldown_time:float = 0.0
@export var invincible_time_resource: FloatResource

var health_resource:HealthResource
var damage_resource:DamageResource

func _ready()->void:
	health_resource = resource_node.get_resource("health")
	assert(health_resource != null)
	damage_resource = resource_node.get_resource("damage")
	assert(damage_resource != null)
	health_resource.damaged.connect(_start_cooldown)
	
	if invincible_time_resource != null:
		cooldown_time = invincible_time_resource.value
		invincible_time_resource.updated.connect(_on_invincible_time_updated)
	
	# in case used with PoolNode
	request_ready()
	tree_exiting.connect(health_resource.damaged.disconnect.bind(_start_cooldown), CONNECT_ONE_SHOT)

func _start_cooldown(_is_spreadable: bool = false)->void:
	if cooldown_time == 0.0:
		return
	damage_resource.set_can_receive_damage(false)
	var _tween:Tween = create_tween()
	_tween.tween_callback(_on_cooldown_finish).set_delay(cooldown_time)

## Called from tween
func _on_cooldown_finish()->void:
	damage_resource.set_can_receive_damage(true)
	cooldown_finished.emit()

## 更新无敌时间
func _on_invincible_time_updated() -> void:
	cooldown_time = invincible_time_resource.value
