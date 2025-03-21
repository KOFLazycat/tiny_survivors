## 数值组件
class_name StatsComponent
extends Node

## 数值更新信号
signal stats_updated(stat: STAT)

## 组名称
@export var group_name: StringName = "stats_component"
@export var resource_node:ResourceNode

enum STAT {
	MAX_HEALTH,
	MAX_SPEED,
	PROJECTILE_DAMAGE,
	AMMO_CAPACITY,
	RELOAD_SPEED,
	SHOT_NUMBER,
	CRIT_CHANCE,
	CRIT_DAMAGE,
	FIRE_RATE
}

var base_values: Dictionary = {
	STAT.MAX_HEALTH: 0.0, # 基础血量
	STAT.MAX_SPEED: 0.0, # 基础移动速度
	STAT.PROJECTILE_DAMAGE: 1.0, # 基础伤害
	STAT.AMMO_CAPACITY: 10, # 基础弹匣容量
	STAT.RELOAD_SPEED: 10, # 基础装填速度（个/秒）
	STAT.SHOT_NUMBER: 1, # 基础一次发射子弹数量
	STAT.CRIT_CHANCE: 0.05, # 5%基础暴击率
	STAT.CRIT_DAMAGE: 1.5, # 基础暴击率，150%暴击伤害
	STAT.FIRE_RATE: 1 # 攻击速度（次/秒），越大攻击速度越快
}
## 加法数值
var additive_bonuses = {}
## 乘法数值
var multiplier_bonuses = {}
## 玩家生命资源
var health_resource: HealthResource
var movement_resource: ActorStatsResource

func _ready() -> void:
	# 初始化基础生命数值
	health_resource = resource_node.get_resource("health")
	base_values[STAT.MAX_HEALTH] = health_resource.max_hp
	# 初始化基础移动数值
	movement_resource = resource_node.get_resource("movement")
	base_values[STAT.MAX_SPEED] = movement_resource.max_speed
	
	# 初始化加法和乘法数值
	for stat in STAT.values():
		additive_bonuses[stat] = 0.0
		multiplier_bonuses[stat] = 1.0
	
	if is_in_group(group_name):
		add_to_group(group_name)
	
	stats_updated.connect(_on_stats_updated)


## 获取数值
func get_stat(stat: STAT) -> float:
	return (base_values[stat] + additive_bonuses[stat]) * multiplier_bonuses[stat]


## 加法运算
func add_additive_bonus(stat: STAT, value: float) -> void:
	additive_bonuses[stat] += value
	stats_updated.emit(stat)


## 乘法运算
func add_multiplier_bonus(stat: STAT, value: float) -> void:
	multiplier_bonuses[stat] *= (1.0 + value)
	stats_updated.emit(stat)


func _on_stats_updated(stat: STAT) -> void:
	var value: float = get_stat(stat)
	match stat:
		STAT.MAX_HEALTH:
			if value > health_resource.max_hp:
				var tmp_hp: float = value - health_resource.max_hp
				health_resource.set_max_hp(value)
				health_resource.add_hp(tmp_hp)
		STAT.MAX_SPEED:
			if value > movement_resource.max_speed:
				movement_resource.max_speed = value
