class_name DamageTypeResource
extends Resource

## 基础伤害值
@export var value: float = 0.0
## 持续时间，0表示即时伤害，大于0表示状态伤害，每秒进行检查
@export var duration: int = 0
## 每秒伤害
@export var damage_per_sec: float = 0.0
## 死亡后对周围敌人造成伤害值
@export var damage_after_dead: float = 0.0
## 伤害范围半径，0表示单体伤害，大于0表示半径范围内的都会受到伤害
@export var damage_radius: float = 0.0
## 移速降低百分比，冰冻类型有用
@export var speed_decrease: float = 0.0
## 伤害加深系数，敌人收到的伤害都会乘以该系数，所以该系数应该是一个大于1的数值
@export var amplify_damage_multiply: float = 2.0
## 是否具有传染性
@export var is_infect: bool = false
## 伤害类型
@export var type: DamageType = DamageType.PHYSICAL

enum DamageType {
	PHYSICAL, # 物理
	FIRE,  # 火
	ICE,  # 冰
	LIGHTNING, # 雷 
	POISON,  # 毒
	CURSE, # 咒
	ACID, 
	MAGNETIC, 
	BLOOD, 
	DARK, 
	ARCANE,
	## Last one for fetching total count
	COUNT,
}
