## 血量条
class_name JucyBar 
extends Control

@export var top_layer_bar: ProgressBar
@export var bottom_layer_bar: ProgressBar

@export var min_value: float
@export var max_value: float
@export var current_value: float
@export var top_layer_bar_time: float = 0.2
@export var top_layer_bar_delay: float = 0.0
@export var bottom_layer_bar_time: float = 0.2
@export var bottom_layer_bar_delay: float = 0.0


func _ready() -> void:
	current_value = max_value
	set_default_values(min_value, max_value, current_value)


## 直接设置默认值
func set_default_values(_min: float = 0, _max: float = 100, current: float = 100) -> void:
	top_layer_bar.min_value = _min
	top_layer_bar.max_value = _max
	top_layer_bar.value = current
	
	bottom_layer_bar.min_value = _min
	bottom_layer_bar.max_value = _max
	bottom_layer_bar.value = current


func change_current_value(value: float) -> void:
	current_value = clamp(value, min_value, max_value)
	run_juicy_tween(top_layer_bar, current_value, top_layer_bar_time, top_layer_bar_delay)
	run_juicy_tween(bottom_layer_bar, current_value, bottom_layer_bar_time, bottom_layer_bar_delay)


func run_juicy_tween(bar: ProgressBar, value: float, length: float, delay: float) -> void:
	var tween = create_tween()
	tween.tween_property(bar, "value", value, length).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
