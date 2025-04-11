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
## 充填动画
@export var reload_progress_bar_instance:InstanceResource
## 充填动画相对武器位置的偏移量
@export var reload_progress_bar_offset: Vector2 = Vector2(0, -20)
## 武器充填音效
@export var sound_reload_resource:SoundResource
## 充填速度（每秒充填多少个子弹）资源
@export var reload_speed_resource: IntResource
## 剩余子弹容量资源
@export var ammo_remain_resource: IntResource
## 弹匣最大容量资源
@export var ammo_capacity_resource: IntResource

# 需要充填的子弹数量
var reload_num: int = 0
# 需要充填的时间
var reload_time: float = 0.0
# 充填进度条
var reload_bar: ReloadProgressBar
# 最大容量
var max_capacity: int


func _ready() -> void:
	assert(ammo_remain_resource != null)
	assert(weapon_trigger != null)
	
	reset_capacity()
	# 信号连接
	ammo_remain_resource.updated.connect(_update_ammo_remain)
	ammo_capacity_resource.updated.connect(_update_ammo_capacity)


func _physics_process(_delta: float) -> void:
	if reload_bar:
		reload_bar.global_position = owner.global_position + reload_progress_bar_offset


func reload() -> void:
	# 停止射击
	weapon_trigger.set_enabled(false)
	weapon_trigger.set_can_shoot(false)
	projectile_spawner.set_enabled(false)
	
	reload_num = clampi(max_capacity - ammo_remain_resource.value, 0, max_capacity)
	reload_time = float(reload_num) / reload_speed_resource.value
	# 进度条时间
	var _config_callback:Callable = func (inst:ReloadProgressBar)->void:
			inst.reload_time = reload_time
	reload_bar = reload_progress_bar_instance.instance(_config_callback)
	# 播放装填音效
	sound_reload_resource.play_managed()
	
	# TODO 增加装填动画
	var _tween:Tween = create_tween()
	_tween.tween_callback(_reload_finish).set_delay(reload_time)


## 重置弹匣
func reset_capacity() -> void:
	reload_num = 0
	reload_time = 0
	max_capacity = ammo_capacity_resource.value
	ammo_remain_resource.value = max_capacity


## 弹匣子弹剩余数量变化时，在此处理逻辑
func _update_ammo_remain() -> void:
	if ammo_remain_resource.value <= 0:
		reload_start.emit()
		reload()


func _update_ammo_capacity() -> void:
	max_capacity = ammo_capacity_resource.value


func _reload_finish() -> void:
	reset_capacity()
	weapon_trigger.set_enabled(true)
	projectile_spawner.set_enabled(true)
	reload_finish.emit()
