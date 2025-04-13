## 获取金币后的进度条
class_name ExperienceBar
extends MarginContainer

@export var top_layer_bar: ProgressBar
@export var bottom_layer_bar: ProgressBar
@export var gold_label: Label
## 金币资源
@export var score_resource:ScoreResource

@export_group("动画相关")
@export var min_value: float
@export var max_value: float
@export var current_value: float = 100.0 : set = set_current_value
@export var top_layer_bar_time: float = 0.5
@export var top_layer_bar_delay: float = 0.5
@export var bottom_layer_bar_time: float = 0.5
@export var bottom_layer_bar_delay: float = 0.5

signal juicy_tween_finished


func _ready() -> void:
	assert(top_layer_bar != null)
	assert(bottom_layer_bar != null)
	assert(gold_label != null)
	#await get_tree().process_frame
	## 设置旋转中心为Label中心
	gold_label.pivot_offset = gold_label.size / 2.0
	update_label(min_value)
	score_resource.updated.connect(_on_score_updated)

## 重置
func reset_default_values(_min: float = 0, _max: float = 100, current: float = 0) -> void:
	set_default_values(_min, _max, _max)
	set_current_value(current)

## 直接设置默认值
func set_default_values(_min: float = 0, _max: float = 100, current: float = 0) -> void:
	top_layer_bar.min_value = _min
	top_layer_bar.max_value = _max
	top_layer_bar.value = current
	
	bottom_layer_bar.min_value = _min
	bottom_layer_bar.max_value = _max
	bottom_layer_bar.value = current
	
	max_value = _max


func set_current_value(value: float) -> void:
	if !is_inside_tree():
		return
	
	if value < current_value:
		# 减少的情况，先减上层，后减下层
		current_value = clamp(value, min_value, max_value)
		run_juicy_tween(top_layer_bar, current_value, top_layer_bar_time, 0.0)
		run_juicy_tween(bottom_layer_bar, current_value, bottom_layer_bar_time, bottom_layer_bar_delay, true)
	else:
		# 增加的情况，先加下层，后加上层
		current_value = clamp(value, min_value, max_value)
		run_juicy_tween(bottom_layer_bar, current_value, bottom_layer_bar_time, 0.0)
		run_juicy_tween(top_layer_bar, current_value, top_layer_bar_time, top_layer_bar_delay, true)


func run_juicy_tween(bar: ProgressBar, value: float, length: float, delay: float, is_finished: bool = false) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(bar, "value", value, length).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	# 进度条动画完成后发射完成信号
	tween.tween_callback(_on_juicy_tween_finish.bind(is_finished))


func update_label(v: float) -> void:
	var vi: int = int(v)
	gold_label.text = str(vi)


func _on_score_updated() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(update_label, int(gold_label.text), score_resource.value, 0.2).set_trans(Tween.TRANS_LINEAR)
	# 放大到 1.5 倍，快速完成（0.2秒）
	tween.parallel().tween_property(gold_label, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 缩放到原始尺寸，带有弹性效果（0.5秒）
	tween.tween_property(gold_label, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _on_juicy_tween_finish(is_finished: bool = false) -> void:
	if is_finished:
		juicy_tween_finished.emit()
