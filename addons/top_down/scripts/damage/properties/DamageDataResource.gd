## 伤害数据核心资源，管理从伤害生成到应用的全生命周期
## 功能：
## - 多属性伤害混合计算（物理/元素）
## - 暴击与闪避概率判定
## - 状态效果批量应用
## - 支持代际复制（穿透）和分裂（范围伤害）
## 用法：由抛射体或近战攻击创建实例，通过process()触发
class_name DamageDataResource
extends TransmissionResource

@export_group("Weapon Config")
## 基础伤害类型列表（可混合物理+元素伤害）
## 注意：非物理伤害不受暴击影响
@export var base_damage: Array[DamageTypeResource]
## 暴击发生概率
@export_range(0.0, 1.0) var critical_chance:float = 0.3
## 暴击倍率系数
@export var critical_multiply:float = 1.5
## 子弹穿透攻击数量，0为无限
@export var target_hit_limit:int = 1

@export_group("Advanced")
## Status effects that can be applied to target
@export var status_list:Array[DamageStatusResource]

@export_group("Report")
## Exploiting that array is shared reference.
## it will collect from same generation hits.
## Allows to hit same target once.
@export var hit_list:Array
## Callback function to receive DamageResource that hit a target.
## Using export allows to duplicate and maintain reference.
@export var report_callback:Callable
## Kickback given to damage target, manipulated in ProjectileSetup
## Set by projectile uppon hitting a target.
@export var kickback_strength:float

## These are set at collision time
## Direction of dealth damage
## Set by projectile uppon hitting a target.
var direction:Vector2

## An information for a damage report.
## Set by damage application process.
var is_critical:bool

## A way to read if it was a killing damage
var is_kill:bool

## pre-calculated value
## Set by damage application process.
var total_damage:float


func _init(_transmission_name:String = "")->void:
	transmission_name = _transmission_name

## 创建新代际伤害数据（用于穿透攻击）
## 特点：
## - 复制基础属性（暴击率、伤害类型等）
## - 清空命中列表避免重复打击
## 返回: 新实例，transmission_name强制设为"damage"
func new_generation()->DamageDataResource:
	var data: DamageDataResource = self.duplicate()
	data.transmission_name = "damage"
	data.hit_list = []
	return data

## Create new split of the same generation, like shrapnels from a granade explosion.
func new_split()->DamageDataResource:
	var data:DamageDataResource = self.duplicate()
	#data.resource_name += "_split"
	return data

## 处理伤害应用的核心逻辑
## 流程：
## 1. 校验目标是否可受伤
## 2. 计算抗性与暴击
## 3. 应用击退与状态效果
## 4. 触发信号与回调
## 参数:
##   resource_node: 目标实体的资源容器节点
func process(resource_node:ResourceNode)->void:
	var _damage_resource:DamageResource = resource_node.get_resource("damage")
	var _health_resource: HealthResource = resource_node.get_resource("health")
	if !_validate_resources(resource_node, _damage_resource, _health_resource):
		return
	
	# It's sure to have a hit, so pull last possible updates, like hit direction
	_update_essentials(resource_node, _damage_resource)
	_apply_damage_effects(resource_node, _damage_resource, _health_resource)
	
	if report_callback.is_valid():
		report_callback.call_deferred(self)
	
	success()


## 校验关键资源是否存在
func _validate_resources(resource_node: ResourceNode, _damage_resource: DamageResource, _health_resource: HealthResource) -> bool:
	if !_damage_resource || !_damage_resource.can_receive_damage:
		try_again() if _damage_resource else failed()
		return false
	
	if !_health_resource || _health_resource.is_dead || _health_resource.hp <= 0.0:
		denied()
		return false
	return true


## 更新方向/击退/受击列表等实时数据
func _update_essentials(resource_node: ResourceNode, _damage_resource: DamageResource) -> void:
	update_requested.emit()
	hit_list.append(_damage_resource.owner)
	
	var _push_resource: PushResource = resource_node.get_resource("push")
	if _push_resource:
		_push_resource.add_impulse(direction * kickback_strength)
	
	# 状态效果
	for _status: DamageStatusResource in status_list:
		_status.initialize(resource_node, _status.status_spreadable)


## 应用伤害与状态效果
func _apply_damage_effects(resource_node: ResourceNode, _damage_resource: DamageResource, _health_resource: HealthResource) -> void:
	if base_damage.is_empty():
		return
	
	# 计算总伤害
	total_damage = base_damage.reduce(
		func(acc, d): return acc + _calculate_single_damage(d, _damage_resource), 
		0.0
	)
	
	# 闪避检测
	if _check_miss(resource_node):
		_damage_resource.miss_damage(self)
	else:
		_commit_damage(_damage_resource, _health_resource)

## 单类型伤害计算
func _calculate_single_damage(dmg: DamageTypeResource, res: DamageResource) -> float:
	is_critical = randf() < critical_chance
	var base = dmg.value * (critical_multiply if dmg.type == DamageTypeResource.DamageType.PHYSICAL and is_critical else 1.0)
	return max(base * (1.0 - res.resistance_value_list[dmg.type]), 0.0)

## 抽离闪避检测逻辑
func _check_miss(resource_node: ResourceNode) -> bool:
	var is_miss: bool = false
	var _miss_chance_resource: MissChanceResource = resource_node.get_resource("miss_chance")
	if _miss_chance_resource != null:
		is_miss = _miss_chance_resource.check_miss()
	if is_miss:
		_miss_chance_resource.add_miss_damage(total_damage)
	return is_miss

## 提交伤害
func _commit_damage(_damage_resource: DamageResource, _health_resource: HealthResource) -> void:
	_health_resource.add_hp( -total_damage )
	is_kill = _health_resource.is_dead
	_damage_resource.receive(self)
