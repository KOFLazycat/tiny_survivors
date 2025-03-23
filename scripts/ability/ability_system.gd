## 技能系统，负责收集以获取能力，以及应用能力到数值组件
class_name AbilitySystem
extends Node

@export var stats_component: StatsComponent
## 组名称
@export var group_name: StringName = "ability_system"

signal ability_added(ability: AbilityResource)
signal ability_updated

# 已获得能力字典（处理叠加）
var _acquired_abilities: Dictionary = {} # Key: AbilityResource, Value: Stack count

func _ready() -> void:
	assert(stats_component != null)
	if is_in_group(group_name):
		add_to_group(group_name)
	#var tmp: AbilityResource = preload("res://resources/abilities/health_ability_resource.tres")
	#var tmp: AbilityResource = preload("res://resources/abilities/move_speed_ability_resource.tres")
	#var tmp: AbilityResource = preload("res://resources/abilities/fire_rate_ability_resource.tres")
	#tmp.current_level = 1
	#await get_tree().create_timer(5).timeout
	#acquire_ability(tmp)
	#print(stats_component.get_stat(StatsComponent.STAT.FIRE_RATE))


# 添加新能力
func acquire_ability(new_ability: AbilityResource) -> void:
	if _acquired_abilities.has(new_ability):
		if _acquired_abilities[new_ability] >= new_ability.max_stacks:
			return
		_acquired_abilities[new_ability] += 1
	else:
		_acquired_abilities[new_ability] = 1
	
	# 应用能力效果
	new_ability.apply_effect(stats_component)
	
	emit_signal("ability_added", new_ability)
	emit_signal("ability_updated")


# 获取当前能力列表
func get_acquired_abilities() -> Array:
	return _acquired_abilities.keys()
