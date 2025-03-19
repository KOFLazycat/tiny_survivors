## 玩家升级能力资源类
class_name AbilityResource
extends ValueResource

# 能力显示信息
# TODO: 制作UI的时候再调整
@export_category("Display")
@export var icon: Texture2D
@export var ability_name: String = "New Ability"
## 稀有度
@export var ability_star: int = 1
@export_multiline var description: String

# 数值修正定义
@export_category("Stat Modifiers")
@export_group("Additive Modifiers")
@export var health_bonus: float = 0.0

@export_group("Multiplicative Modifiers")
@export var health_multiplier: float = 0.0
@export var move_speed_multiplier: float = 0.0 # 百分比形式（0.1 = 10%）

# 特殊效果标记
@export_category("Special Flags") 
@export var is_unique: bool = false # 是否唯一能力
@export var max_stacks: int = 1 # 可叠加次数


# 应用能力到玩家
func apply_to(stats: StatsComponent) -> void:
	stats.add_modifier("health", health_bonus)
	stats.add_modifier("health", health_multiplier, true)
	stats.add_modifier("move_speed", move_speed_multiplier, true)
