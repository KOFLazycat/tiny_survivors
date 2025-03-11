## 子弹壳，模拟射击时，弹壳掉落的效果
class_name Cartridge
extends RigidBody2D

## 渐隐动画播放器
@export var animation_player:AnimationPlayer
## 渐隐动画名称
@export var animation:StringName
## 实例池
@export var pool_node:PoolNode
## 子弹射出后，施加的冲击向上方向偏移量因子
@export var impulse_up_factor: float = 200.0
## 子弹射出后，跟射出方向反向的偏移量因子
@export var impulse_direction_factor: float = 80.0

var spin_speed = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spin_speed = randi_range(-15,15)
	animation_player.stop()
	animation_player.play(animation)
	animation_player.animation_finished.connect(on_animation_player_finished, CONNECT_ONE_SHOT)
	#start(Vector2.LEFT)
	request_ready()


func _physics_process(delta: float) -> void:
	rotation += spin_speed * delta


func start(direction: Vector2):
	var impluse: Vector2 = (-1) * direction.normalized()*impulse_direction_factor + Vector2.UP * impulse_up_factor
	apply_impulse(impluse)


func on_animation_player_finished(_anim:StringName)->void:
	queue_free()
