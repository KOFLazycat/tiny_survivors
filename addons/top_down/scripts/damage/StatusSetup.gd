class_name StatusSetup
extends Node2D

@export var resource_node:ResourceNode
@export var status_list:Array[DamageStatusResource]
@onready var sprite: Sprite2D = $"../Body/Stretch/Sprite2D"


var damage_resource:DamageResource

func _ready() -> void:
	# BUG: workaround - https://github.com/godotengine/godot/issues/96181
	#status_list = status_list.duplicate()
	status_list = []
	var type_count = DamageTypeResource.DamageType.size()
	status_list.resize(type_count)
	
	## 重置颜色
	sprite.self_modulate = Color.WHITE

	_setup_status()
	# in case used with PoolNode
	if !resource_node.ready.is_connected(_setup_status):
		resource_node.ready.connect(_setup_status)
	# 对象池初始化
	request_ready()


func _physics_process(delta: float) -> void:
	for _status: DamageStatusResource in status_list:
		if _status != null:
			_status.process(delta)


func _setup_status()->void:
	damage_resource = resource_node.get_resource("damage")
	assert(damage_resource != null)
	if !damage_resource.store_status.is_connected(store_status):
		# it is the same DamageResource
		damage_resource.store_status.connect(store_status)


## 存储状态BUF，相同类型的BUF只能存在一个
func store_status(status_effect:DamageStatusResource)->void:
	if status_list[status_effect.status_damage_type] == null and status_effect != null:
		#status_effect.initialize(resource_node)
		status_list[status_effect.status_damage_type] = status_effect
		
		if status_effect.status_damage_type == DamageTypeResource.DamageType.CURSE:
			sprite.self_modulate = Color.DIM_GRAY
		
		if !status_effect.status_removed.is_connected(_on_status_removed):
			status_effect.status_removed.connect(_on_status_removed)


func _on_status_removed(status_effect: DamageStatusResource) -> void:
	status_list[status_effect.status_damage_type] = null
