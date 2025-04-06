## 玩家升级能力资源类，基类，每一种能力、技能可以继承该类，进行个性化的修改
class_name AbilityResource
extends ValueResource

# 能力显示信息
# TODO: 制作UI的时候再调整
@export_category("Display")
## 能力名称，唯一
@export var ability_name: StringName = "New Ability"
## 能力icon
@export var icon: Texture2D
## 能力stat分类
@export var ability_stat: StatsComponent.STAT
## 描述
@export_multiline var description: String

## 等级标记
@export_category("Level Set")
## 最大等级
@export var max_level: int = 1
## 每个等级增加值，超过最大等级的无效
@export var additive_per_level: Array[float]
## 每个等级百分比，超过最大等级的无效
@export var multiplier_per_level: Array[float]
## 基础出现权重
@export var base_weight: float = 1.0

## 特殊效果标记
@export_category("Special Flags") 
@export var is_unique: bool = false # 是否唯一能力
@export var max_stacks: int = 0 # 可叠加次数，0表示不限制叠加次数
## 当前等级
var current_level: int = 1
## 当前权重
var current_weight: float = 1.0
## 是否满级
var is_max_level: bool = false

## 更新数值
func apply_effect(stats: StatsComponent) -> void:
	if !is_max_level:
		if additive_per_level.size() >= current_level:
			stats.add_additive_bonus(ability_stat, additive_per_level[current_level - 1])
		if multiplier_per_level.size() >= current_level:
			stats.add_multiplier_bonus(ability_stat, multiplier_per_level[current_level - 1])
		# 技能应用后，等级+1
		if current_level < max_level:
			current_level += 1
		else:
			is_max_level = true
