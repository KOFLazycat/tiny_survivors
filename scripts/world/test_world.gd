class_name TestWorld
extends Node2D


func _ready() -> void:
	PersistentData.saveable_list[0].load_resource()
