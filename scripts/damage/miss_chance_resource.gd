## 闪避资源类
class_name MissChanceResource
extends ValueResource

# 闪避成功信号
signal miss_success
# 闪避失败信号
signal miss_fail

@export_range(0.0, 1.0, 0.01) var miss_chance: float = 0.3

## 累积已经闪避伤害
var total_miss_damage: float = 0.0

func check_miss() -> bool:
	var is_miss: bool = randf() < miss_chance
	if is_miss:
		miss_success.emit()
	else:
		miss_fail.emit()
	return is_miss


func add_miss_damage(dmg: float) -> void:
	total_miss_damage += dmg


func get_miss_damage() -> float:
	return total_miss_damage
