## 经验管理类
class_name ExperienceManager
extends Node

## 经验条
@export var experience_bar: ExperienceBar
## 经验获取资源
@export var score_resource:ScoreResource
## 敌人管理器
@export var enemy_manager:EnemyManager

## 经验获取、更新信号
signal experience_updated(current_exp: int, required_exp: int)
## 升级信号
signal level_up(new_level: int)

# 当前等级
var _current_level:int = 1
# 最大等级
var _max_level:int = 1
# 当前累积经验值
var _current_exp:int = 0
# 升级
var is_level_up: bool = false
# 等级以及升级所需经验数组
var level_exp: Array[int]


func _ready() -> void:
	assert(experience_bar != null)
	assert(enemy_manager != null)
	
	init_level_exp()
	experience_bar.reset_default_values(0, get_required_exp(), 0)
	experience_bar.juicy_tween_finished.connect(_on_experience_bar_juicy_tween_finished)
	score_resource.updated.connect(_on_score_updated)


## 初始化等级、所需经验等数据
func init_level_exp() -> void:
	for i:int in enemy_manager.wave_queue.waves.size():
		level_exp.append(enemy_manager.wave_queue.waves[i].count)
	
	_current_level = 1
	_current_exp = 0
	_max_level = level_exp.size()


## 增加经验值
func add_experience(amount: int) -> void:
	_current_exp += amount
	experience_bar.set_current_value(_current_exp)
	_check_level_up()
	_emit_experience_update()

## 返回当前等级
func get_current_level() -> int:
	return _current_level

## 获取升级所需经验值
func get_required_exp() -> int:
	return _get_current_level_data()


## 校验是否可以升级，以及相关逻辑处理
func _check_level_up() -> void:
	while _current_level < _max_level:
		var required = _get_current_level_data()
		if required == 0:
			is_level_up = false
			break
		# 满足升级经验
		if _current_exp >= required:
			_current_exp -= required
			_current_level += 1
			if !is_level_up:
				is_level_up = true
		else:
			if is_level_up:
				is_level_up = false
			break

## 获取当前等级资源数据
func _get_current_level_data() -> int:
	if _current_level > _max_level:
		return 0
	return level_exp[_current_level - 1]

## 释放经验获取、更新信号
func _emit_experience_update() -> void:
	experience_updated.emit(_current_exp, get_required_exp())


## 获取经验
func _on_score_updated() -> void:
	add_experience(score_resource.step)


func _on_experience_bar_juicy_tween_finished() -> void:
	if experience_bar.current_value == experience_bar.top_layer_bar.max_value:
		experience_bar.reset_default_values(0, get_required_exp(), 0)
		level_up.emit(_current_level)
