## 初始化敌人出生位置
class_name EnemySpawnPoint
extends Node2D

## 出生位置数量，这个只是确定可选择的初审位置，并不代表每次产生的敌人数量
@export var spawn_point_num: int = 20
## 出生位置资源
@export var spawn_point_resource: SpawnPointResource


func _ready() -> void:
	assert(spawn_point_resource != null)
	init_spawn_point()


## 初始化出生位置
func init_spawn_point() -> void:
	var spawn_point: Vector2 = Vector2.ZERO
	for i in range(spawn_point_num):
		spawn_point = get_random_position()
		spawn_point_resource.add_position(spawn_point)
		## TODO 增加boss位置
		#spawn_point_resourceresource.add_boss_position(spawn_point)


func get_random_position():
	#var vpr = get_viewport_rect().size * randf_range(0.8, 0.9)
	var top_left = Vector2(100, 30)
	var top_right = Vector2(380, 30)
	var bottom_left = Vector2(100, 240)
	var bottom_right = Vector2(380, 240)
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)
