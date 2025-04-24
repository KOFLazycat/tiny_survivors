## 状态效果基类，用于实现持续性伤害/增益效果.
## 子类需重写 process() 或生命周期方法（on_apply/on_update/on_remove）.
## 示例用法:
## - 中毒: 每帧扣血
## - 燃烧: 周期性伤害 + 特效
## - 无敌BUFF: 临时屏蔽伤害接收
class_name DamageStatusResource
extends Resource

@export_group("Base Settings")
## 状态显示名称
@export var status_name: String = "Default Status"
## 基础持续时间（秒）
@export var base_duration: float = 5.0

@export_group("Visual Settings")
## 状态图标
@export var status_icon: Texture2D
## 状态生效时的粒子特效场景
@export var effect_scene: PackedScene

## 当前生效时长
var current_duration: float = 0.0
## 所属伤害资源
var source_damage: DamageDataResource

## 初始化状态（子类必须实现）
func initialize(damage_data: DamageDataResource) -> void:
	self.source_damage = damage_data
	current_duration = base_duration

## 处理状态效果逻辑（基类默认行为为存储副本到实体）
## 参数:
##   resource_node: 目标实体资源节点（可获取 HealthResource 等）
##   damage_resource: 关联的伤害资源（自动获取若为空）
##   is_stored: 是否为已存储的实例（避免循环添加）
func process(resource_node:ResourceNode, damage_resource:DamageResource = null, is_stored:bool = false)->void:
	# 参数校验
	assert(resource_node != null, "ResourceNode is null")
	if damage_resource == null:
		damage_resource = resource_node.get_resource("damage")
		assert(damage_resource != null, "DamageResource not found")
	
	# 存储逻辑
	if !is_stored:
		_store_effect(damage_resource)
	
	# 子类扩展点
	_on_process(resource_node, damage_resource)


## 复制时生成唯一ID（可选）
func duplicate(subresources: bool = false) -> Resource:
	var copy = super.duplicate(subresources)
	copy.status_name = status_name  # 或生成UUID
	return copy

## 存储状态效果到实体
func _store_effect(damage_resource: DamageResource) -> void:
	damage_resource.add_status_effect(self.duplicate(true))

## 内部处理逻辑（子类重写此方法而非 process()）
func _on_process(resource_node: ResourceNode, damage_resource: DamageResource) -> void:
	pass


## 应用效果（子类必须实现）
func apply_effect(target: Node) -> void:
	pass

## 传播效果（子类可选实现）
func spread_effect(origin: Node) -> void:
	pass

## 更新效果（返回true表示效果继续）
func update_effect(delta: float) -> bool:
	current_duration -= delta
	return current_duration > 0

## 获取状态类型（子类必须实现）
func get_status_type() -> int:
	return DamageTypeResource.DamageType.PHYSICAL
