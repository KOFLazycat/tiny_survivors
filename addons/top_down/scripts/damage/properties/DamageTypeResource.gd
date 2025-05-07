## 伤害类型资源，定义一种特定属性的伤害（如火焰/毒素）。
## 用于：
## - 在 DamageDataResource 中组合多种伤害类型
## - 在抗性系统中匹配对应抗性值
class_name DamageTypeResource
extends Resource

@export_group("Basic Settings")
## 基础伤害值（最终伤害需计算抗性）
## 注意：该值为单次伤害，非持续伤害
@export_range(0.0, 10000.0) var value: float = 0.0
## 抗性百分比，DamageSetup设置时有效
## 注意：实际伤害 = 伤害总量 * (1 - resistance_value)
@export_range(0.0, 1.0, 0.01) var resistance_value: float = 0.0
## 伤害类型，决定：
## - 抗性计算方式
## - 命中特效表现
@export var type: DamageType = DamageType.PHYSICAL

@export_group("Advanced Effects")
## 是否允许对Boss生效
@export var allow_on_boss: bool = false

## 伤害类型枚举，命名规则：
## 1. 基础类型在前，特殊类型在后
## 2. 按世界观分类（自然/魔法/科技）
enum DamageType {
	PHYSICAL,   # 物理（刀剑/子弹）
	FIRE,       # 火焰（持续灼烧，可引燃环境）
	ICE,        # 冰霜（减速目标移动速度）
	LIGHTNING,  # 雷电（连锁攻击多个目标）
	POISON,     # 毒素（持续生命流失）
	CURSE,      # 诅咒（降低目标抗性）
	#ACID,       # 酸液（降低护甲值）
	#MAGNETIC,   # 磁力（禁用机械单位）
	#BLOOD,      # 鲜血（吸血效果）
	#DARK,       # 暗影（无视部分抗性）
	#ARCANE,     # 奥术（魔法穿透）
}

## 获取类型名称（用于UI显示）
func get_type_name() -> String:
	return DamageType.keys()[type].capitalize()

## 验证数据合法性（可在编辑器中调用）
func validate() -> bool:
	return value >= 0.0
