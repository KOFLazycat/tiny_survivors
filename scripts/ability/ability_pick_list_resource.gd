## 已选择技能列表
class_name AbilityPickListResource
extends ValueResource

signal pick_list_update(ability_res: AbilityResource)

@export var pick_list: Array[AbilityResource] = []


func get_pick_list() -> Array[AbilityResource]:
	return pick_list


func add_pick_list(ability_res: AbilityResource) -> void:
	if !pick_list.has(ability_res):
		pick_list.append(ability_res)
	pick_list_update.emit(ability_res)
