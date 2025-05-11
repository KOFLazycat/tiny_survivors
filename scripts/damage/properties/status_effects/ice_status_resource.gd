## 冰冻效果资源脚本
class_name IceStatusResource
extends DamageStatusResource

@export_group("Ice Settings", "ice_")
## 敌人速度减少百分比
@export_range(0.0, 1.0) var ice_speed_decrease: float = 0.5
## 死亡后，周围敌人冰冻时间
@export var ice_duration: float = 1.0

## 主处理入口（由StatusSetup调用）
func process(delta: float) -> bool:
	# 血量管理
	if _health_resource.is_dead:
		_trigger_remove()
		return false
	# 持续时间管理
	if status_duration > 0:
		_current_duration += delta
		if _current_duration >= status_duration:
			_trigger_remove()
			return false
	
	# 间隔触发逻辑
	_current_interval += delta
	if _current_interval >= status_interval + randf_range(-0.2, 0.2):
		_current_interval = 0.0
		on_tick(status_spreadable)
		status_ticked.emit(self)
	
	return true


## 初次应用时触发（子类必须实现）
func on_apply() -> void:
	status_damage_type = DamageTypeResource.DamageType.ICE
	if _movement_resource.max_speed >= _movement_resource.default_max_speed:
		_movement_resource.max_speed = _movement_resource.max_speed * (1 - ice_speed_decrease)


## 每次间隔触发（子类必须实现）
func on_tick(is_spreadable: bool = false) -> void:
	var ddr: DamageDataResource = DamageDataResource.new()
	ddr.total_damage = _calculate_final_value(status_value)
	_health_resource.add_hp(ddr.total_damage, is_spreadable)
	ddr.is_kill = _health_resource.is_dead
	if ddr.total_damage < 0.0:
		# show damage points but as positive numbers
		_damage_resource.receive(ddr, status_damage_type)

## 效果移除时触发（子类可选实现）
func on_remove() -> void:
	_movement_resource.max_speed = _movement_resource.default_max_speed


## 效果传播时触发（子类可选实现）
## 一次性伤害， obj_rn 需要传染对象的ResourceNode
func on_spread(obj_rn: ResourceNode) -> void:
	# 对自身不能传染
	if obj_rn == _resource_node:
		return
	ice_speed_decrease = 1.0
	status_duration = ice_duration
	initialize(obj_rn, false)
