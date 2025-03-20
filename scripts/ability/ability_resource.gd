## 玩家升级能力资源类，基类，每一种能力、技能可以继承该类，进行个性化的修改
class_name AbilityResource
extends ValueResource

# 能力显示信息
# TODO: 制作UI的时候再调整
@export_category("Display")
@export var icon: Texture2D
@export var ability_name: String = "New Ability"
## 稀有度
@export_multiline var description: String

# 特殊效果标记
@export_category("Special Flags") 
@export var is_unique: bool = false # 是否唯一能力
@export var max_stacks: int = 1 # 可叠加次数


# 应用能力到数值
func apply_effect(stats: StatsComponent) -> void:
	pass
	#stats.add_additive_bonus("health", health_bonus)
	#stats.add_multiplier_bonus("health", health_multiplier, true)
