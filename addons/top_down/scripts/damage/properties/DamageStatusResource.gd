## 状态效果基类，用于实现持续性伤害/增益效果.
## 子类需重写 process() 或生命周期方法（on_apply/on_update/on_remove）.
## 示例用法:
## - 中毒: 每帧扣血
## - 燃烧: 周期性伤害 + 特效
## - 无敌BUFF: 临时屏蔽伤害接收
class_name DamageStatusResource
extends Resource

## 生命周期信号
signal status_applied(dsr: DamageStatusResource)  # 效果应用时
signal status_ticked(dsr: DamageStatusResource)   # 每次间隔触发
signal status_removed(dsr: DamageStatusResource)  # 效果移除时

@export_group("Base Settings", "status_")
## 状态显示名称
@export var status_name: StringName = "Default Status"
## 基础持续时间（秒），≤0 表示永久
@export_range(-1.0, 60.0) var status_duration: float = 3.0
## 每次结算基础值（负=伤害，正=治疗）
@export var status_value:float = 0.0
## 伤害结算间隔（秒）
@export_range(0.1, 10.0) var status_interval: float = 1.0
## 状态施加概率（0.0~1.0）
@export_range(0.0, 1.0) var status_chance: float = 1.0
## 伤害类型（影响抗性计算）
@export var status_damage_type: DamageTypeResource.DamageType = DamageTypeResource.DamageType.PHYSICAL

@export_group("Visual Settings", "vfx_")
## 状态图标（用于UI显示）
@export var vfx_icon: Texture2D
## 持续生效时的粒子特效
@export var vfx_looping_scene: PackedScene
## 生效时的单次特效
@export var vfx_impact_scene: PackedScene

# 运行时状态
var _current_duration: float = 0.0
var _current_interval: float = 0.0
var _target_node: CharacterBody2D      # 目标实体节点
var _resource_node:ResourceNode # 伤害
var _damage_resource:DamageResource # 伤害
var _health_resource:HealthResource # 血量
var _looping_vfx: Node      # 循环特效实例

## 初始化状态（由StatusSetup调用）
func initialize(resource_node:ResourceNode) -> void:
	if randf() > status_chance:
		return
	
	# 参数校验
	_resource_node = resource_node
	assert(resource_node != null, "ResourceNode is null")
	_damage_resource = resource_node.get_resource("damage")
	assert(_damage_resource != null, "DamageResource not found")
	_health_resource = resource_node.get_resource("health")
	assert(_health_resource != null, "HealthResource not found")
	_target_node = resource_node.owner
	
	# 存储逻辑
	store_effect(_damage_resource)
	on_apply()
	#_apply_visual_effects()
	status_applied.emit(self)

## 主处理入口（由StatusSetup调用）
func process(delta: float) -> bool:
	# 血量管理
	if _health_resource.is_dead:
		_trigger_remove()
		return false
	# 持续时间管理
	if status_duration > 0:
		_current_duration += delta
		if _current_duration >= status_duration:
			_trigger_remove()
			return false
	
	# 间隔触发逻辑
	_current_interval += delta
	if _current_interval >= status_interval + randf_range(-0.2, 0.2):
		_current_interval = 0.0
		on_tick()
		status_ticked.emit(self)
	
	return true

## 复制时生成唯一ID（可选）
func duplicate(subresources: bool = false) -> Resource:
	var copy = super.duplicate(subresources)
	copy.status_name = status_name
	copy._resource_node = _resource_node
	copy._damage_resource = _damage_resource
	copy._health_resource = _health_resource
	return copy

## 存储状态效果到实体
func store_effect(damage_resource: DamageResource) -> void:
	damage_resource.add_status_effect(self.duplicate(true))


## 移除状态（外部可强制移除）
func remove() -> void:
	_trigger_remove()


#region 生命周期方法（子类重写区域）
## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	push_warning("Unimplemented _on_apply() in status: %s" % status_name)

## 每次间隔触发（子类必须实现）
func on_tick() -> void:
	push_warning("Unimplemented _on_tick() in status: %s" % status_name)

## 效果移除时触发（子类可选实现）
func on_remove() -> void:
	pass

## 效果传播时触发（子类可选实现）
func on_spread() -> void:
	pass
#endregion


#region 辅助方法
## 计算最终效果值（考虑抗性/增益）
func _calculate_final_value(value: float) -> float:
	if value >= 0:
		return value  # 治疗值不受抗性影响
	
	# 获取抗性值（带边界保护）
	var resist = 0.0
	if _damage_resource.resistance_value_list.size() > status_damage_type:
		resist = _damage_resource.resistance_value_list[status_damage_type]
	
	return value * (1.0 - clamp(resist, 0.0, 1.0))

## 应用视觉特效
func _apply_visual_effects() -> void:
	if vfx_impact_scene:
		var effect = vfx_impact_scene.instantiate()
		_target_node.add_child(effect)
	
	if vfx_looping_scene:
		_looping_vfx = vfx_looping_scene.instantiate()
		_target_node.add_child(_looping_vfx)

## 触发移除流程
func _trigger_remove() -> void:
	if _looping_vfx:
		_looping_vfx.queue_free()
	on_remove()
	status_removed.emit(self)

#endregion
