## 状态效果基类，用于实现持续性伤害/增益效果.
## 子类需重写 process() 或生命周期方法（on_apply/on_update/on_remove）.
## 示例用法:
## - 中毒: 每帧扣血
## - 燃烧: 周期性伤害 + 特效
## - 无敌BUFF: 临时屏蔽伤害接收
class_name DamageStatusResource
extends Resource

## 状态计时结束
signal tick_finished(dsr: DamageStatusResource)

@export_group("Base Settings")
## 状态显示名称
@export var status_name: String = "Default Status"
## 基础持续时间（秒）
@export var base_duration: float = 3.0
## 每次结算基础值，负数表示伤害，正数表示恢复
@export var value:float = 0.0
## 伤害结算间隔
@export var interval:float = 1.0
## 状态产生概率
@export_range(0.0, 1.0) var chance:float = 1.0
## 伤害类型，决定：
## - 抗性计算方式
## - 命中特效表现
@export var dmg_type: DamageTypeResource.DamageType = DamageTypeResource.DamageType.PHYSICAL

@export_group("Visual Settings")
## 状态图标
@export var status_icon: Texture2D
## 状态生效时的粒子特效场景
@export var effect_scene: PackedScene

var tick_tween: Tween

## 处理状态效果逻辑（基类默认行为为存储副本到实体）
## 参数:
##   resource_node: 目标实体资源节点（可获取 HealthResource 等）
##   damage_resource: 关联的伤害资源（自动获取若为空）
##   is_stored: 是否为已存储的实例（避免循环添加）
func process(resource_node:ResourceNode, damage_resource:DamageResource = null, is_stored:bool = false)->void:
	if randf() > chance:
		return
	# 参数校验
	assert(resource_node != null, "ResourceNode is null")
	if damage_resource == null:
		damage_resource = resource_node.get_resource("damage")
		assert(damage_resource != null, "DamageResource not found")
	
	#var ad: ActorDamage = resource_node.owner.get_node("ActorDamage")
	#if is_instance_valid(ad) and !ad.actor_died.is_connected(_on_actor_died):
		#ad.actor_died.connect(_on_actor_died, CONNECT_ONE_SHOT)
	
	# 存储逻辑
	if !is_stored:
		store_effect(damage_resource)
	
	# 子类扩展点
	tick(resource_node, damage_resource, base_duration)


## 复制时生成唯一ID（可选）
func duplicate(subresources: bool = false) -> Resource:
	var copy = super.duplicate(subresources)
	copy.status_name = status_name  # 或生成UUID
	return copy

## 存储状态效果到实体
func store_effect(damage_resource: DamageResource) -> void:
	damage_resource.add_status_effect(self.duplicate(true))

## 内部处理逻辑（子类重写此方法而非 process()）
func tick(resource_node:ResourceNode, damage_resource:DamageResource, remaining_ticks:float) -> void:
	pass


func kill_tick_tween() -> void:
	if tick_tween:
		tick_tween.kill()


## 单类型伤害计算
func calculate_value(dmg_resource: DamageResource) -> float:
	var r: float = 0.0
	if value > 0.0:
		r = value
	else:
		r = min(0.0, value * (1.0 - dmg_resource.resistance_value_list[dmg_type]))
	return r

#
#func _on_actor_died() -> void:
	#pass
