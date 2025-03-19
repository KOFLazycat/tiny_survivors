## 数值组件
class_name StatsComponent
extends Node

# 基础属性（可在编辑器中直接配置）
@export_category("Base Stats")
@export var base_health: float = 100.0 # 基础血量
@export var base_move_speed: float = 300.0 # 基础移动速度
@export var base_projectile_damage: float = 10.0 # 基础伤害
@export var base_ammo: int = 10 # 基础弹匣容量
@export var base_reload_speed: float = 10 # 基础装填速度（个/秒）
@export var base_shot_number: int = 1 # 基础发射子弹数量
@export var base_critical_chance: float = 0.05 # 5%基础暴击率
@export var base_critical_multiplier: float = 1.5 # 150%暴击伤害
@export var base_fire_rate: float = 1.0  # 攻击速度（秒/次） TODO: 是否改成 次/秒

# 动态计算属性（通过能力系统修改）
var current_health: float:
	get = _get_current_health,
	set = _set_current_health

var move_speed: float:
	get = _get_move_speed

# 修正值存储（加法修正）
var _health_additive: float = 0.0
var _projectile_damage_additive: float = 0.0
var _shot_number_additive: int = 1

# 修正乘数存储（乘法修正）
var _health_multiplier: float = 1.0
var _move_speed_multiplier: float = 1.0
var _attack_speed_multiplier: float = 1.0
var _crit_chance_additive: float = 0.0
var _crit_multiplier_multiplier: float = 1.0

# 属性计算逻辑
func _get_current_health() -> float:
	return (base_health + _health_additive) * _health_multiplier


func _set_current_health(value: float) -> void:
	# 确保生命值不低于0
	base_health = max(value / _health_multiplier - _health_additive, 0)


func _get_move_speed() -> float:
	return base_move_speed * _move_speed_multiplier


# 应用修正的方法
func add_modifier(stat_type: String, value: float, is_multiplier: bool = false) -> void:
	match stat_type:
		"health":
			if is_multiplier:
				_health_multiplier *= (1.0 + value)
			else:
				_health_additive += value
		"move_speed":
			if is_multiplier:
				_move_speed_multiplier *= (1.0 + value)
		#"damage":
			#_projectile_damage_additive += value if not is_multiplier else 0
		#"attack_speed":
			#if is_multiplier:
				#_attack_speed_multiplier *= (1.0 + value)
		# ... 其他属性处理
