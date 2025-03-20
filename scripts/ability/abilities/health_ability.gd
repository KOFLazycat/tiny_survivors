## 血量能力资源
class_name HealthAbility
extends AbilityResource

## 最高等级
@export var max_level: int = 5
## 每个等级增加值
@export var additive_per_level: Array[float]
## 每个等级百分比
@export var multiplier_per_level: Array[float]

var current_level: int = 1


func apply_effect(stats: StatsComponent) -> void:
	super(stats)
	if additive_per_level.size() >= current_level:
		stats.add_additive_bonus(StatsComponent.STAT.MAX_HEALTH, additive_per_level[current_level - 1])
	if multiplier_per_level.size() >= current_level:
		stats.add_multiplier_bonus(StatsComponent.STAT.MAX_HEALTH, multiplier_per_level[current_level - 1])
	
