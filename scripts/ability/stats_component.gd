## 数值组件
class_name StatsComponent
extends Node

## 数值更新信号
signal stats_updated(stat: STAT)

## 组名称
@export var group_name: StringName = "stats_component"
@export var resource_node: ResourceNode
## 攻击速度资源，每秒攻击次数
@export var fire_rate_resource: FloatResource
## 基础伤害
@export var projectile_damage_type_resource: DamageTypeResource
## 基础暴击概率与暴击倍率、击退距离
@export var damage_data_resource: DamageDataResource
## 基础弹匣容量
@export var ammo_capacity_resource: IntResource
## 基础充填速度（每秒充填多少个子弹）资源
@export var reload_speed_resource: IntResource
## 基础散弹数量资源
@export var shot_number_resource: IntResource
## 基础无敌时间
@export var invincible_time_resource: FloatResource
## 基础闪避概率
@export var miss_chance_resource: MissChanceResource

enum STAT {
	MAX_HEALTH,
	MAX_SPEED,
	FIRE_RATE,
	DAMAGE,
	CRIT_CHANCE,
	CRIT_MULTIPLY,
	AMMO_CAPACITY,
	RELOAD_SPEED,
	SHOT_NUMBER,
	KICKBACK,
	INVINCIBLE,
	MISS_CHANCE,
	HIT_LIMIT
}

var base_values: Dictionary = {
	STAT.MAX_HEALTH: 0.0, # 基础血量
	STAT.MAX_SPEED: 0.0, # 基础移动速度
	STAT.FIRE_RATE: 1, # 攻击速度（次/秒），越大攻击速度越快
	STAT.DAMAGE: 1.0, # 基础伤害
	STAT.CRIT_CHANCE: 0.05, # 5%基础暴击率
	STAT.CRIT_MULTIPLY: 1.5, # 基础暴击率，150%暴击伤害
	STAT.AMMO_CAPACITY: 10, # 基础弹匣容量
	STAT.RELOAD_SPEED: 10, # 基础装填速度（个/秒）
	STAT.SHOT_NUMBER: 1, # 基础一次发射子弹数量
	STAT.KICKBACK: 10, # 基础击退距离
	STAT.INVINCIBLE: 0.5, # 基础无敌时间
	STAT.MISS_CHANCE: 0.1, # 基础闪避概率
	STAT.HIT_LIMIT: 1 # 基础穿透数量
}
## 加法数值
var additive_bonuses = {}
## 乘法数值
var multiplier_bonuses = {}
## 玩家生命资源
var health_resource: HealthResource
var movement_resource: ActorStatsResource

func _ready() -> void:
	assert(resource_node != null)
	assert(fire_rate_resource != null)
	assert(invincible_time_resource != null)
	# 初始化基础生命数值
	health_resource = resource_node.get_resource("health")
	base_values[STAT.MAX_HEALTH] = health_resource.max_hp
	# 初始化基础移动数值
	movement_resource = resource_node.get_resource("movement")
	base_values[STAT.MAX_SPEED] = movement_resource.max_speed
	# 初始化基础攻速数值
	base_values[STAT.FIRE_RATE] = fire_rate_resource.value
	# 初始化基础伤害
	base_values[STAT.DAMAGE] = projectile_damage_type_resource.value
	# 初始化基础暴击概率与暴击倍率
	base_values[STAT.CRIT_CHANCE] = damage_data_resource.critical_chance
	base_values[STAT.CRIT_MULTIPLY] = damage_data_resource.critical_multiply
	# 初始化基础弹匣容量
	base_values[STAT.AMMO_CAPACITY] = ammo_capacity_resource.value
	# 初始化基础充填速度（每秒充填多少个子弹）
	base_values[STAT.RELOAD_SPEED] = reload_speed_resource.value
	# 基础散弹数量资源
	base_values[STAT.SHOT_NUMBER] = shot_number_resource.value
	# 初始化基础击退距离
	base_values[STAT.KICKBACK] = damage_data_resource.kickback_strength
	# 初始化基础无敌时间数值
	base_values[STAT.INVINCIBLE] = invincible_time_resource.value
	# 初始化基础闪避概率
	base_values[STAT.MISS_CHANCE] = miss_chance_resource.miss_chance
	# 初始化基础穿透数量
	base_values[STAT.HIT_LIMIT] = damage_data_resource.target_hit_limit
	
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
		STAT.FIRE_RATE:
			fire_rate_resource.value = value
		STAT.DAMAGE:
			projectile_damage_type_resource.value = value
		STAT.CRIT_CHANCE:
			damage_data_resource.critical_chance = value
		STAT.CRIT_MULTIPLY:
			damage_data_resource.critical_multiply = value
		STAT.AMMO_CAPACITY:
			ammo_capacity_resource.value = int(value)
		STAT.RELOAD_SPEED:
			reload_speed_resource.value = int(value)
		STAT.SHOT_NUMBER:
			shot_number_resource.value = int(value)
		STAT.KICKBACK:
			damage_data_resource.kickback_strength = value
		STAT.INVINCIBLE:
			invincible_time_resource.value = value
		STAT.MISS_CHANCE:
			miss_chance_resource.miss_chance = value
		STAT.HIT_LIMIT:
			damage_data_resource.target_hit_limit = int(value)
