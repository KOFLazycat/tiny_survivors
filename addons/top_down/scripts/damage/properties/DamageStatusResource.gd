## 状态效果基类，用于实现持续性伤害/增益效果.
## 子类需重写 process() 或生命周期方法（on_apply/on_update/on_remove）.
## 示例用法:
## - 中毒: 每帧扣血
## - 燃烧: 周期性伤害 + 特效
## - 无敌BUFF: 临时屏蔽伤害接收
class_name DamageStatusResource
extends Resource

@export_group("Base Config")
## 状态唯一标识（用于防止重复添加）
@export var status_id: String = ""

@export_group("Timing")
## 持续时间（≤0 表示永久）
@export var duration: float = 10.0

@export_group("Visuals")
## 状态生效时的粒子特效场景
@export var effect_scene: PackedScene


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
	copy.status_id = status_id  # 或生成UUID
	return copy

## 存储状态效果到实体
func _store_effect(damage_resource: DamageResource) -> void:
	damage_resource.add_status_effect(self.duplicate(true))

## 内部处理逻辑（子类重写此方法而非 process()）
func _on_process(resource_node: ResourceNode, damage_resource: DamageResource) -> void:
	pass
