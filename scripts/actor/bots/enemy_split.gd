## 敌人分裂成若干个敌人
class_name EnemySplit
extends Node

# 建议将角度数组改为常量（若不需要运行时修改）
const DEFAULT_ANGLES: Array[float] = [-25.0, 25.0, -65.0, 65.0]

@export var resource_node: ResourceNode
@export var split_instance_resource: InstanceResource
## 分裂的角度（非弧度）和数量
@export var angles: Array[float] = DEFAULT_ANGLES
## 分裂距离
@export var spawn_distance: float = 8.0
@export var axis_multiplication: Vector2Resource
@export var position_node: Node2D
@export var active_enemy: ActiveEnemy

# 缓存计算值避免重复转换
var _radian_angles: Array = []

func _ready() -> void:
	# 添加空值检查
	assert(resource_node != null, "ResourceNode must be assigned")
	assert(position_node != null, "PositionNode must be assigned")
	assert(active_enemy != null, "ActiveEnemy must be assigned")

	# 预处理角度转换
	_radian_angles = angles.map(func(deg): return deg_to_rad(deg))
	
	var damage_resource: DamageResource = resource_node.get_resource("damage") as DamageResource
	if damage_resource != null:
		damage_resource.received_damage.connect(_on_damage_received)
		# 使用引用计数安全的连接方式
		tree_exiting.connect(
			func(): damage_resource.received_damage.disconnect(_on_damage_received),
			CONNECT_ONE_SHOT
		)
	else:
		push_error("Failed to get DamageResource from ResourceNode")
	
	request_ready()

## 提取回调函数为类方法
func _config_instance(inst: Node, pos: Vector2, dir: Vector2, branch: ActiveEnemyResource) -> void:
	inst.global_position = pos + spawn_distance * dir
	ActiveEnemy.insert_child(inst, branch)

## 受到伤害时信号处理函数
func _on_damage_received(damage: DamageDataResource) -> void:
	if !damage.is_kill:
		return

	# 添加资源有效性检查
	if !axis_multiplication:
		push_warning("Axis multiplication not configured")
		return

	var enemy_branch: ActiveEnemyResource = active_enemy.enemy_resource
	var base_dir: Vector2 = damage.direction.normalized()
	var spawn_pos: Vector2 = position_node.global_position

	# 使用预处理的角度数据
	for radian in _radian_angles:
		var modified_dir: Vector2 = (
			base_dir.rotated(radian) * axis_multiplication.value
		).normalized()
		
		# 使用预先生成的配置方法
		split_instance_resource.instance(
			func(inst): 
				_config_instance(inst, spawn_pos, modified_dir, enemy_branch)
		)

	# 添加安全移除检查
	if is_instance_valid(active_enemy):
		active_enemy.remove_self()  # 更安全的节点移除方式
	else:
		push_warning("ActiveEnemy reference is already invalid")
