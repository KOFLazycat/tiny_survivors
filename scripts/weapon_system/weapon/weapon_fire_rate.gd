## 武器攻击速度，攻击频率
class_name WeaponFireRate
extends Node

## 触发器
@export var weapon_trigger: WeaponTrigger
## 攻击速度资源，每秒攻击次数
@export var fire_rate_resource: FloatResource

var tween:Tween
# 攻击间隔，即每次攻击之间间隔多久
var interval:float

func _ready()->void:
	assert(weapon_trigger != null)
	assert(fire_rate_resource != null)
	weapon_trigger.shoot_event.connect(start)

## Disables weapon's ability to spawn and plays an attack animation
func start() -> void:
	interval = 1 / fire_rate_resource.value
	print(interval)
	weapon_trigger.set_can_shoot(false)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_callback(timeout).set_delay(interval)

## enables trigger to shoot projectiles
func timeout()->void:
	weapon_trigger.can_shoot = true
	if weapon_trigger.can_retrigger():
		weapon_trigger.on_shoot()
