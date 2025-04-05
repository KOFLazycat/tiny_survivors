## 技能池管理类
class_name AbilityPoolManager
extends Node

## 所有技能
@export var all_abilities: Array[AbilityResource] = []

# 已选技能
var _blacklist : Array[StringName] = []

# 获取升级用的技能列表
func get_upgrade_options() -> Array[AbilityResource]:
	var candidates: Array[AbilityResource] = get_available_abilities()
	var selected: Array[AbilityResource] = []
	# 分层抽取（确保出现至少1个新技能）
	var new_abilities: Array[AbilityResource] = candidates.filter(func(c): return c.current_level == 1)
	if new_abilities.size() > 0:
		selected.append(pick_by_weight(new_abilities))
		candidates = candidates.filter(func(c): return c not in selected)
	
	# 补足剩余选项
	while selected.size() < 3 and candidates.size() > 0:
		var pick: AbilityResource = pick_by_weight(candidates)
		selected.append(pick)
		candidates.erase(pick)
	
	return selected


func pick_by_weight(candidates: Array[AbilityResource]) -> AbilityResource:
	var total_weight: float = candidates.reduce(func(acc, c): return acc + c.current_weight, 0.0)
	var random: float = randf_range(0, total_weight)
	var accumulated: float = 0.0
	for c: AbilityResource in candidates:
		accumulated += c.current_weight
		if random <= accumulated:
			return c
	return candidates[0]


func get_available_abilities() -> Array[AbilityResource]:
	var candidates: Array[AbilityResource] = []
	for ability: AbilityResource in all_abilities:
		# 排除已满级和黑名单
		if ability.current_level >= ability.max_level:
			continue
		if ability.ability_name in _blacklist:
			continue
		
		# 动态权重计算
		ability.current_weight = (1.0 + ((ability.current_level - 1) * 0.2)) * ability.base_weight# 等级越高权重越高
		if ability.current_level == 1:
			ability.current_weight *= 1.5  # 未学习技能加成
		
		candidates.append(ability)
	return candidates
