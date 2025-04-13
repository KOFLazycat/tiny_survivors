class_name PlayerSpawnerDetail
extends PlayerSpawner

## VFX on moment player spawns
@export var spawn_partickle_instance_resource:InstanceResource
@export var player_born_instance:InstanceResource
@export var player_shot_shake:CameraShakeResource

func _ready()->void:
	assert(player_reference != null)
	assert(player_instance_resource != null)
	
	scene_transition_resource.change_scene.connect(on_scene_transition)
	
	if player_reference.node != null:
		## Allow doors to register themselves.
		on_player_scene_entry.call_deferred()
		return
	
	var _partickle_config:Callable = func(inst:Node2D)->void:
		inst.global_position = global_position
	
	var _player_born_config:Callable = func(inst: BornLight)->void:
		inst.target_position = global_position
		inst.appear()
	
	var _config_callback:Callable = func (inst:Node2D)->void:
		player_born_instance.instance(_player_born_config)
		inst.global_position = Vector2(global_position.x, global_position.y - 180) 
		var tween: Tween = create_tween()
		tween.tween_property(inst, "global_position", global_position, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		await tween.finished
		spawn_partickle_instance_resource.instance(_partickle_config)
		player_shot_shake.play()
		# TODO 增加光束效果
		
	var _player:Node2D = player_instance_resource.instance(_config_callback)
	
	
