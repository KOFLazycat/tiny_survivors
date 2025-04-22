class_name DamageTypeResource
extends Resource

## 基础伤害值，一次性伤害
@export var value:float

enum DamageType {
	PHYSICAL, # 物理
	FIRE, # 火
	ICE, # 冰
	LIGHTNING, # 雷 
	POISON, # 毒
	CURSE, # 咒
	ACID, 
	MAGNETIC, 
	BLOOD, 
	DARK, 
	ARCANE,
	## Last one for fetching total count
	COUNT,
	}

## 伤害类型
@export var type:DamageType
