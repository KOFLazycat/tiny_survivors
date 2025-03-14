class_name ItemPickup
extends Node2D

signal success

@export var item_resource:ItemResource

@export var icon_sprite:Sprite2D

@export var data_transmitter:DataChannelTransmitter

@export var sound_resource:SoundResource

func _ready() -> void:
	if item_resource == null:
		return
	icon_sprite.texture = item_resource.icon
	
	var _transmission_resource:ItemTransmission = ItemTransmission.new()
	_transmission_resource.transmission_name = "item"
	_transmission_resource.item_resource = item_resource
	data_transmitter.transmission_resource = _transmission_resource
	
	data_transmitter.success.connect(prepare_remove, CONNECT_ONE_SHOT)
	data_transmitter.set_enabled(false)
	get_tree().physics_frame.connect(_delay_enable, CONNECT_ONE_SHOT)

## delay to avoid triggering if overlap at spawn
func _delay_enable()->void:
	get_tree().physics_frame.connect(data_transmitter.set_enabled.bind(true), CONNECT_ONE_SHOT)

func prepare_remove()->void:
	data_transmitter.set_enabled(false)
	sound_resource.play_managed()
	success.emit()
	## TODO: DO proper VFX
	queue_free()
