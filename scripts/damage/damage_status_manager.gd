## 角色状态管理
class_name DamageStatusManager
extends Node

@export_category("Commponent")
@export var resource_node: ResourceNode

@export_category("Parameter")
@export var enabled:bool = true

@onready var timer: Timer = $Timer


### 运行时状态 ###
var health_resource: HealthResource
var damage_resource: DamageResource
var is_replaced: bool  # 初始化默认值避免状态残留
var active_status: Dictionary
var poison_time_left: int = 0

func _ready() -> void:
	if !enabled:
		return
	
	active_status.clear()
	# 初始化健康资源（优化点1：增加空值保护）
	health_resource = resource_node.get_resource("health") if resource_node else null
	assert(health_resource != null, "缺少health资源")
	
	# 初始化伤害资源（优化点2：避免临时变量命名混淆）
	damage_resource = resource_node.get_resource("damage") as DamageResource
	assert(damage_resource != null, "缺少damage资源")
	
	# 信号连接（优化点3：使用类型安全的连接方式）
	damage_resource.received_damage.connect(_on_damage, CONNECT_DEFERRED)
	timer.timeout.connect(_on_timeout, CONNECT_DEFERRED)
	
	# 清理连接（优化点4：使用更可靠的断开方式）
	tree_exiting.connect(
		func(): 
			damage_resource.received_damage.disconnect(_on_damage)
			timer.timeout.disconnect(_on_timeout),
		CONNECT_ONE_SHOT
	)
	
	# 对象池初始化
	request_ready()


func _physics_process(_delta: float) -> void:
	if active_status.is_empty() and !timer.is_stopped():
		timer.stop()
	
	if !active_status.is_empty() and timer.is_stopped():
		timer.start()


func _on_damage(damage: DamageDataResource) -> void:
	for _damage:DamageTypeResource in damage.base_damage:
		match _damage.type:
			DamageTypeResource.DamageType.POISON:
				if _damage is not PoisonDamageTypeResource:
					return
				if randf() > _damage.poison_chance:
					return
				# 刷新时间
				poison_time_left = _damage.duration
				if !active_status.has(DamageTypeResource.DamageType.POISON):
					active_status.set(DamageTypeResource.DamageType.POISON, _damage)


func _on_timeout() -> void:
	if poison_time_left > 0:
		poison_time_left -= 1
		var _damage: DamageTypeResource = active_status.get(DamageTypeResource.DamageType.POISON)
		damage_resource.receive_points(_damage.damage_per_sec)
	else:
		poison_time_left = 0
		active_status.erase(DamageTypeResource.DamageType.POISON)
		timer.stop()
