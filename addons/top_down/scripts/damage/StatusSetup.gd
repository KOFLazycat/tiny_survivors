class_name StatusSetup
extends Node2D

@export var resource_node:ResourceNode
@export var status_list:Array[DamageStatusResource]

var damage_resource:DamageResource

func _ready() -> void:
	# BUG: workaround - https://github.com/godotengine/godot/issues/96181
	#status_list = status_list.duplicate()
	status_list = []
	var type_count = DamageTypeResource.DamageType.size()
	status_list.resize(type_count)
	
	_setup_status()
	# in case used with PoolNode
	if !resource_node.ready.is_connected(_setup_status):
		resource_node.ready.connect(_setup_status)
	# 对象池初始化
	request_ready()


func _physics_process(delta: float) -> void:
	for _status: DamageStatusResource in status_list:
		if _status != null:
			_status.tick(resource_node, delta)


func _setup_status()->void:
	damage_resource = resource_node.get_resource("damage")
	assert(damage_resource != null)
	if !damage_resource.store_status.is_connected(store_status):
		# it is the same DamageResource
		damage_resource.store_status.connect(store_status)


## 存储状态BUF，相同类型的BUF只能存在一个
func store_status(status_effect:DamageStatusResource)->void:
	if status_list[status_effect.dmg_type] == null and status_effect != null:
		status_list[status_effect.dmg_type] = status_effect
		if !status_effect.tick_finished.is_connected(_on_tick_finished):
			status_effect.tick_finished.connect(_on_tick_finished)


func _on_tick_finished(status_effect: DamageStatusResource) -> void:
	status_list[status_effect.dmg_type] = null
