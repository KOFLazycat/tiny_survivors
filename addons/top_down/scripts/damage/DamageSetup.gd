## 实体抗性配置器，管理 DamageResource 的抗性数组
## 功能：
## - 初始化抗性值列表
## - 提供动态增删抗性方法
## - 解决 Godot 4 导出数组的引用共享问题（Issue #96181）
class_name DamageSetup
extends Node

@export_group("Core References")
## 关联的资源节点，需包含 DamageResource
@export var resource_node: ResourceNode

@export_group("Resistance Config")
## 抗性列表（相同类型可叠加）
@export var resistance_list: Array[DamageTypeResource] = []

## 关联的伤害资源（自动初始化）
var damage_resource:DamageResource

## 初始化抗性数据，绑定到 ResourceNode 的 ready 信号
## [!] 必须在场景树就绪后调用，确保 ResourceNode 已初始化
func _ready() -> void:
	# Godot 4 导出数组引用问题修复（Issue #96181）
	resistance_list = resistance_list.duplicate()
	
	# 延迟绑定确保 ResourceNode 初始化完成
	if resource_node.ready.is_connected(_setup_resistance):
		resource_node.ready.disconnect(_setup_resistance)
	resource_node.ready.connect(_setup_resistance)
	
	_setup_resistance()


## 初始化/更新抗性数组
func _setup_resistance()->void:
	if !resource_node:
		push_error("ResourceNode not assigned in DamageSetup")
		return
	
	damage_resource = resource_node.get_resource("damage")
	if !damage_resource:
		push_error("DamageResource missing in ResourceNode")
		return
	
	damage_resource.owner = owner
	
	# 初始化抗性数组（按枚举大小动态调整）
	var type_count = DamageTypeResource.DamageType.size()
	damage_resource.resistance_value_list.resize(type_count)
	#for i in type_count:
		#damage_resource.resistance_value_list[i] = 0.0
	
	_calculate_resistances()

## 动态添加抗性并更新数值
## 参数:
##   resistance: 需添加的抗性资源（类型需匹配 DamageType）
func add_resistance(resistance: DamageTypeResource) -> void:
	if !resistance:
		return
	
	resistance_list.append(resistance)
	var type: int = resistance.type
	if _is_valid_resistance_type(type):
		damage_resource.resistance_value_list[type] = clampf(damage_resource.resistance_value_list[type] + resistance.resistance_value, 0.0, 1.0)

## 移除抗性
func remove_resistance(resistance: DamageTypeResource) -> void:
	if !resistance || !resistance_list.has(resistance):
		return
	
	resistance_list.erase(resistance)
	var type: int = resistance.type
	if _is_valid_resistance_type(type):
		damage_resource.resistance_value_list[type] = clampf(damage_resource.resistance_value_list[type] - resistance.resistance_value, 0.0, 1.0)

## 计算总抗性值
func _calculate_resistances() -> void:
	for resistance in resistance_list:
		var type: int = resistance.type
		if _is_valid_resistance_type(type):
			damage_resource.resistance_value_list[type] = clampf(damage_resource.resistance_value_list[type] + resistance.resistance_value, 0.0, 1.0)
		else:
			push_warning("Invalid resistance type: %d" % type)

## 校验抗性类型有效性
func _is_valid_resistance_type(type: int) -> bool:
	return type >= 0 && type < damage_resource.resistance_value_list.size()
