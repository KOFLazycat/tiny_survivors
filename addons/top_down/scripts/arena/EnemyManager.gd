class_name EnemyManager
extends Node


@export var wave_queue:SpawnQueueResource

# 当前波数索引
var wave_index: int
# 总的波数
var total_wave_count: int
# 剩余波数
var remain_wave_count: int

func _ready()->void:
	if wave_queue == null:
		return
	## BUG: Workaround for stupid bug. Arrays, dictionaries and resources reference from PackedScene
	wave_queue = wave_queue.duplicate()
	wave_queue.waves = wave_queue.waves.duplicate()
	
	for i:int in wave_queue.waves.size():
		wave_queue.waves[i] = wave_queue.waves[i].duplicate()
	
	wave_index = 0
	set_total_wave_count()
	set_remain_wave_count()


## 增加索引
func increase_wave_index() -> void:
	if wave_index == wave_queue.waves.size():
		return
	wave_index += 1
	set_remain_wave_count()

## 设置总波数
func set_total_wave_count() -> void:
	total_wave_count = wave_queue.waves.size()

## 设置剩余波数
func set_remain_wave_count() -> void:
	remain_wave_count = wave_queue.waves.size() - wave_index

## 是否波数清空
func is_wave_clear() -> bool:
	return remain_wave_count == 0
