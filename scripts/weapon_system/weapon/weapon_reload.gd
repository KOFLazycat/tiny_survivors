## 武器重新装填
class_name WeaponReload
extends Node

## 信号：开始装填
signal reload_start
## 信号：装填完成
signal reload_finish

## 武器发射类
@export var weapon_trigger:WeaponTrigger
## 子弹生产类
@export var projectile_spawner:ProjectileSpawner
## 武器弹匣容量资源
@export var weapon_capacity_resource: IntResource
## 武器充填音效
@export var sound_resource:SoundResource
## 充填速度（每秒充填多少个子弹）
@export var reload_num_every_second: int = 10
## 弹匣最大容量
@export var max_capacity: int = 10

# 需要充填的子弹数量
var reload_num: int = 0
# 需要充填的时间
var reload_time: float = 0.0


func _ready() -> void:
	assert(weapon_capacity_resource != null)
	assert(weapon_trigger != null)
	
	reset_capacity()
	# 信号连接
	weapon_capacity_resource.updated.connect(_update_weapon_capacity)


func reload() -> void:
	# 停止射击
	weapon_trigger.set_enabled(false)
	projectile_spawner.set_enabled(false)
	
	reload_num = clampi(max_capacity - weapon_capacity_resource.value, 0, max_capacity)
	reload_time = reload_num / reload_num_every_second
	# TODO 音效长度需要与装填速度匹配
	# 播放装填音效
	sound_resource.play_managed()
	
	# TODO 增加装填动画
	var _tween:Tween = create_tween()
	_tween.tween_callback(_reload_finish).set_delay(reload_time)


## 重置弹匣
func reset_capacity() -> void:
	reload_num = 0
	reload_time = 0
	weapon_capacity_resource.value = max_capacity


## 弹匣子弹数量变化时，在此处理逻辑
func _update_weapon_capacity()->void:
	if weapon_capacity_resource.value <= 0:
		reload_start.emit()
		reload()


func _reload_finish() -> void:
	reset_capacity()
	weapon_trigger.set_enabled(true)
	projectile_spawner.set_enabled(true)
	reload_finish.emit()
