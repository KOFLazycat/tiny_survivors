## 经验管理类
class_name ExperienceManager
extends Node

## 经验条
@export var experience_bar: ExperienceBar
## 等级配置资源
@export var level_config: LevelConfigResource
## 经验获取资源
@export var score_resource:ScoreResource

## 经验获取、更新信号
signal experience_updated(current_exp: int, required_exp: int)
## 升级信号
signal level_up(new_level: int)

# 当前等级
var _current_level := 0
# 当前累积经验值
var _current_exp := 0


func _ready() -> void:
	assert(level_config != null)
	assert(experience_bar != null)
	
	_current_level = 0
	_current_exp = 0
	experience_bar.reset_default_values(0, get_required_exp(), 0)
	score_resource.updated.connect(_on_score_updated)

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
	return _get_current_level_data().value


## 校验是否可以升级，以及相关逻辑处理
func _check_level_up() -> void:
	var max_level = level_config.levels.size() - 1
	while _current_level < max_level:
		var required = _get_current_level_data().value
		if _current_exp >= required:
			_current_exp -= required
			_current_level += 1
			# 重置经验条
			_reset_experience_bar()
		else:
			break

## 获取当前等级资源数据
func _get_current_level_data() -> LevelData:
	if _current_level >= level_config.levels.size():
		return level_config.levels[-1]
	return level_config.levels[_current_level]

## 释放经验获取、更新信号
func _emit_experience_update() -> void:
	experience_updated.emit(_current_exp, get_required_exp())

## 重置经验条
func _reset_experience_bar() -> void:
	# 保证经验条tween动画完成
	await get_tree().create_timer(0.5).timeout
	experience_bar.reset_default_values(0, get_required_exp(), 0)
	level_up.emit(_current_level)

## 获取经验
func _on_score_updated() -> void:
	add_experience(score_resource.step)
