## 子弹壳，模拟射击时，弹壳掉落的效果
class_name Cartridge
extends RigidBody2D

## 渐隐动画播放器
@export var animation_player:AnimationPlayer
## 渐隐动画名称
@export var animation:StringName
## 实例池
@export var pool_node:PoolNode

var spin_speed = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spin_speed = randi_range(-15,15)
	animation_player.stop()
	animation_player.play(animation)
	animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)
	#start(Vector2.LEFT)
	request_ready()


func start(start: Vector2):
	apply_impulse(-(start + Vector2(0,200)) )


func _physics_process(delta: float) -> void:
	rotation += spin_speed * delta


func _on_anim_finished(_anim:StringName)->void:
	pool_node.pool_return()
