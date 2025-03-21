## 玩家升级能力资源类，基类，每一种能力、技能可以继承该类，进行个性化的修改
class_name AbilityResource
extends ValueResource

# 能力显示信息
# TODO: 制作UI的时候再调整
@export_category("Display")
## 能力icon
@export var icon: Texture2D
## 能力名称
@export var ability_name: String = "New Ability"
## 能力stat分类
@export var ability_stat: StatsComponent.STAT
## 描述
@export_multiline var description: String

## 等级标记
@export_category("Level Set") 
## 每个等级增加值
@export var additive_per_level: Array[float]
## 每个等级百分比
@export var multiplier_per_level: Array[float]

## 特殊效果标记
@export_category("Special Flags") 
@export var is_unique: bool = false # 是否唯一能力
@export var max_stacks: int = 1 # 可叠加次数

var max_level: int = 1
var current_level: int = 1

func _init() -> void:
	max_level = max(additive_per_level.size(), multiplier_per_level.size())


## 更新数值
func apply_effect(stats: StatsComponent) -> void:
	if additive_per_level.size() >= current_level:
		stats.add_additive_bonus(ability_stat, additive_per_level[current_level - 1])
	if multiplier_per_level.size() >= current_level:
		stats.add_multiplier_bonus(ability_stat, multiplier_per_level[current_level - 1])
