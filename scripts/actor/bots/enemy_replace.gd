## 敌人的二阶段处理，在一定条件下，敌人可能变换形态
class_name EnemyReplace
extends Node

### 组件依赖 ###
@export_category("Commponent")
@export var resource_node: ResourceNode
@export var pool_node: PoolNode
@export var active_enemy: ActiveEnemy

### 配置参数 ###
@export_category("Parameter")
## 生命值下限阈值百分比，生命低于这个百分比在有可能进入第二形态
@export_range(0.0, 1.0, 0.01) var health_treshold: float = 0.5
## 进入第二形态的概率
@export_range(0.0, 1.0, 0.01) var replace_chance: float = 0.3
## 进入第二形态时是否恢复生命
@export var is_restore_life: bool = false
@export var replacement_instance_resource: InstanceResource
@export var sound_effect: SoundResource
@export var damage_data_receiver: DataChannelReceiver

### 运行时状态 ###
var health_resource: HealthResource
var is_replaced: bool  # 初始化默认值避免状态残留

func _ready() -> void:
	is_replaced = false
	# 初始化健康资源（优化点1：增加空值保护）
	health_resource = resource_node.get_resource("health") if resource_node else null
	assert(health_resource != null, "缺少health资源")
	
	# 初始化伤害资源（优化点2：避免临时变量命名混淆）
	var damage_resource := resource_node.get_resource("damage") as DamageResource
	assert(damage_resource != null, "缺少damage资源")
	
	# 信号连接（优化点3：使用类型安全的连接方式）
	damage_resource.received_damage.connect(_on_damage, CONNECT_DEFERRED)
	
	# 对象池初始化
	request_ready()
	damage_data_receiver.enabled = true
	
	# 清理连接（优化点4：使用更可靠的断开方式）
	tree_exiting.connect(
		func(): damage_resource.received_damage.disconnect(_on_damage),
		CONNECT_ONE_SHOT
	)

func _on_damage(damage: DamageDataResource) -> void:
	# 条件检查链（优化点5：优化判断逻辑顺序）
	if is_replaced || health_resource.is_dead || health_resource.hp > health_treshold * health_resource.max_hp:
		return
	
	## 是否满足概率
	if randf() > replace_chance:
		return
	
	_trigger_replacement(damage)


### 核心替换逻辑 ###
func _trigger_replacement(damage: DamageDataResource) -> void:
	is_replaced = true
	damage_data_receiver.enabled = false
	
	# 数据快照（优化点6：显式声明常量）
	const IMPULSE_MULTIPLIER: float = 1.5
	var push_vector: Vector2 = damage.kickback_strength * damage.direction * IMPULSE_MULTIPLIER
	var current_hp: float = health_resource.max_hp if is_restore_life else health_resource.hp
	var enemy_branch: ActiveEnemyResource = active_enemy.enemy_resource
	
	# 实例化回调（优化点7：拆分回调逻辑）
	replacement_instance_resource.instance(_get_config_callback(push_vector, current_hp, enemy_branch))
	
	# 后处理
	sound_effect.play_managed()
	active_enemy.remove_self()
	pool_node.pool_return()


### 配置回调生成器 ###
func _get_config_callback(push: Vector2, hp: float, branch: ActiveEnemyResource) -> Callable:
	return func(inst: Node):
		inst.global_position = owner.global_position
		
		# 准备就绪回调（优化点8：使用命名函数）
		inst.ready.connect(
			func(): _on_replacement_ready(inst, push, hp),
			CONNECT_ONE_SHOT | CONNECT_DEFERRED
		)
		
		ActiveEnemy.insert_child(inst, branch)

### 替换实例就绪处理 ###
func _on_replacement_ready(inst: Node, push: Vector2, hp: float) -> void:
	var new_resource_node: ResourceNode = inst.get_node("ResourceNode") as ResourceNode
	
	# 健康同步（优化点9：添加空值保护）
	if new_resource_node:
		var new_health: HealthResource = new_resource_node.get_resource("health") as HealthResource
		new_health.add_hp.call_deferred(hp - new_health.hp)
		
		var push_resource: PushResource = new_resource_node.get_resource("push") as PushResource
		push_resource.add_impulse(push)
	
	inst.request_ready()
