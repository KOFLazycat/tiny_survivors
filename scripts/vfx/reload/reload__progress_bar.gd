class_name ReloadProgressBar
extends Node2D

## 装填时间
@export var reload_time: float = 1.0
@export var pool_node:PoolNode

@onready var left_pos: Marker2D = $Bottom/LeftPos
@onready var right_pos: Marker2D = $Bottom/RightPos
@onready var top: Sprite2D = $Top

var tween:Tween

func _ready() -> void:
	# 使用相对位置
	top.position = left_pos.position
	reload_bar()


func reload_bar() -> void:
	if tween != null:
		tween.kill
	tween = create_tween()
	# 使用相对位置
	tween.tween_property(top, "position", right_pos.position, reload_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
	tween.finished.connect(pool_node.pool_return)
