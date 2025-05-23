class_name HealthResource
extends SaveableResource

signal damaged(is_spreadable: bool)
signal dead
signal hp_changed
signal max_hp_changed
signal full
signal reset_update

@export var hp:float = 5
@export var max_hp:float = 5

@export var reset_hp:float = 5
@export var reset_max_hp:float = 5
@export var is_dead:bool

func set_max_hp(value:float)->void:
	max_hp = value
	max_hp_changed.emit()

func reset_resource()->void:
	is_dead = false
	max_hp = reset_max_hp
	hp = reset_hp
	hp_changed.emit()
	reset_update.emit()

func prepare_load(data:Resource)->void:
	is_dead = data.is_dead
	hp = data.hp
	max_hp = data.max_hp
	hp_changed.emit()

func is_full()->bool:
	return hp == max_hp

func add_hp(value:float, is_spreadable: bool = false)->void:
	hp = clamp(hp + value, 0.0, max_hp)
	hp_changed.emit()
	if value < 0.0:
		damaged.emit(is_spreadable)
	if hp == 0.0:
		is_dead = true
		dead.emit()
		return
	if hp == max_hp:
		full.emit()
		return

func insta_kill()->void:
	add_hp(-hp)
