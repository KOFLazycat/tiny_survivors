## 玩家出生特效
class_name BornLight
extends Line2D

## 目标位置
@export var target_position: Vector2 = Vector2.ZERO
## 线宽
@export var target_width: float = 30.0
## 白光出现时间
@export var appear_duration: float = 1.0
## 白光消失时间
@export var disappear_duration: float = 0.5

var start_points: PackedVector2Array


func _ready() -> void:
	points[0].x = target_position.x
	points[0].y = -20.0
	points[1] = points[0]
	start_points = points.duplicate()  # 保存初始点
	self_modulate.a = 0.0
	request_ready()


func appear() -> void:
	var tween: Tween = create_tween()
	tween.parallel().tween_property(self, "self_modulate:a", 1.0, appear_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "width", target_width, appear_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_method(_update_line_end_points, 0.0, 1.0, appear_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "self_modulate:a", 0.0, disappear_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "width", 0.0, disappear_duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	## 删除
	tween.tween_callback(queue_free)


# 自定义插值方法（由Tween自动调用）
func _update_line_end_points(progress: float):
	points[1] = start_points[1].lerp(target_position, progress)
