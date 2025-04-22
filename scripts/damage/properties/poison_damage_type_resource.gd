## 毒类型伤害数值
class_name PoisonDamageTypeResource
extends DamageTypeResource

## 中毒概率，0必然不中毒，1必然中毒
@export_range(0.0, 1.0, 0.01) var poison_chance: float = 0.0
## 持续时间，0表示无持续伤害，大于0表示状态伤害，每秒进行检查
@export var duration: int = 0
## 每秒伤害
@export var damage_per_sec: float = 0.0
## 敌人死亡后，周围敌人可中毒的范围，0表示单体伤害，对范围内的敌人进行概率检验，并不是每个都中毒
@export var poison_radius: float = 0.0
