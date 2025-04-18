## 技能系统，负责收集以获取能力，以及应用能力到数值组件
class_name AbilitySystem
extends Node

@export var stats_component: StatsComponent
## 已选技能列表
@export var ability_pick_list_resource: AbilityPickListResource

signal ability_added(ability: AbilityResource)
signal ability_updated

# 已获得能力字典（处理叠加）
var _acquired_abilities: Dictionary = {} # Key: AbilityResource, Value: Stack count

func _ready() -> void:
	assert(stats_component != null)
	assert(ability_pick_list_resource != null)
	ability_pick_list_resource.pick_list_update.connect(_on_pick_list_update)


# 添加新能力
func acquire_ability(new_ability: AbilityResource) -> void:
	if _acquired_abilities.has(new_ability):
		if new_ability.max_stacks > 0 and _acquired_abilities[new_ability] >= new_ability.max_stacks:
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


func _on_pick_list_update(ability_res: AbilityResource) -> void:
	acquire_ability(ability_res)
