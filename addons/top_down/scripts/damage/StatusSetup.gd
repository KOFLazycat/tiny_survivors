class_name StatusSetup
extends Node2D

@export var resource_node:ResourceNode
@export var status_list:Array[DamageStatusResource]

var damage_resource:DamageResource

func _ready() -> void:
	# BUG: workaround - https://github.com/godotengine/godot/issues/96181
	status_list = status_list.duplicate()
	
	_setup_status()
	# in case used with PoolNode
	if !resource_node.ready.is_connected(_setup_status):
		resource_node.ready.connect(_setup_status)
	# 对象池初始化
	request_ready()


func _setup_status()->void:
	damage_resource = resource_node.get_resource("damage")
	assert(damage_resource != null)
	if !damage_resource.store_status.is_connected(_store_status):
		# it is the same DamageResource
		damage_resource.store_status.connect(_store_status)
	
	for _status:DamageStatusResource in status_list:
		assert(_status != null)
		_status.set_over(true)


func _store_status(status_effect:DamageStatusResource)->void:
	status_effect.set_over(false)
	if status_effect.tick_finished.is_connected(_on_tick_finished):
		return
	status_effect.tick_finished.connect(_on_tick_finished)
	status_list.append(status_effect)


func _on_tick_finished(status_effect: DamageStatusResource) -> void:
	status_list.erase(status_effect)
