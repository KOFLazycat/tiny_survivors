class_name ActorDamage
extends Node

signal actor_died

@export var resource_node:ResourceNode
@export var sprite_flip:SpriteFlip
@export var status_setup: StatusSetup
@export var flash_animation_player:AnimationPlayer
@export var effect_animation_player:AnimationPlayer
@export var flash_animation:StringName
@export var sound_resource_damage:SoundResource
@export var sound_resource_dead:SoundResource
@export var dead_vfx_instance_resource:InstanceResource
@export var poison_effect_instance_resource:InstanceResource
@export var fire_effect_instance_resource:InstanceResource
@export var lightning_effect_instance_resource:InstanceResource
@export var curse_effect_instance_resource:InstanceResource
@export var ice_effect_instance_resource:InstanceResource

func _ready()->void:
	var _health_resource:HealthResource = resource_node.get_resource("health")
	# workaround to retrigger color flash - stop and then play again
	_health_resource.damaged.connect(_play_damaged)
	
	# remove character
	_health_resource.dead.connect(_play_dead)
	
	# in case used with PoolNode
	request_ready()
	flash_animation_player.play("RESET")
	effect_animation_player.play("RESET")
	tree_exiting.connect(_remove_connections.bind(_health_resource), CONNECT_ONE_SHOT)


func _remove_connections(health_resource:HealthResource)->void:
	health_resource.damaged.disconnect(_play_damaged)
	# remove character
	health_resource.dead.disconnect(_play_dead)

func _play_damaged(is_spreadable: bool = false)->void:
	var anim_played: bool = false
	
	if status_setup:
		var lightning_status: LightningStatusResource = status_setup.status_list[DamageTypeResource.DamageType.LIGHTNING]
		if lightning_status != null:
			var _lightning_config_callback:Callable = func (inst:LightningEffect)->void:
				inst.global_position = owner.global_position
				inst.lightning_status_resource = lightning_status
				inst.is_spreadable = is_spreadable
			
			lightning_effect_instance_resource.instance.call_deferred(_lightning_config_callback)
		
		for _status: DamageStatusResource in status_setup.status_list:
			if _status != null:
				if !anim_played:
					if _status.status_damage_type == DamageTypeResource.DamageType.CURSE:
						effect_animation_player.stop()
						effect_animation_player.play("flash_curse")
						anim_played = true
						break
					if _status.status_damage_type == DamageTypeResource.DamageType.ICE:
						effect_animation_player.stop()
						effect_animation_player.play("flash_ice")
						anim_played = true
						break
		
		if !anim_played:
			flash_animation_player.stop()
			flash_animation_player.play(flash_animation)
	
	sound_resource_damage.play_managed()

func _play_dead()->void:
	sound_resource_dead.play_managed()
	
	var _config_callback:Callable = func (inst:Node2D)->void:
		inst.global_position = owner.global_position
		inst.scale.x = sprite_flip.dir
	
	dead_vfx_instance_resource.instance.call_deferred(_config_callback)
	
	if status_setup:
		var poison_status: PoisonStatusResource = status_setup.status_list[DamageTypeResource.DamageType.POISON]
		if poison_status != null:
			var _poison_config_callback:Callable = func (inst:PoisonEffect)->void:
				inst.global_position = owner.global_position
				inst.poison_status_resource = poison_status
			
			poison_effect_instance_resource.instance.call_deferred(_poison_config_callback)
		
		var fire_status: FireStatusResource = status_setup.status_list[DamageTypeResource.DamageType.FIRE]
		if fire_status != null:
			var _fire_config_callback:Callable = func (inst:FireEffect)->void:
				inst.global_position = owner.global_position
				inst.fire_status_resource = fire_status
			
			fire_effect_instance_resource.instance.call_deferred(_fire_config_callback)
		
		var curse_status: CurseStatusResource = status_setup.status_list[DamageTypeResource.DamageType.CURSE]
		if curse_status != null:
			var _curse_config_callback:Callable = func (inst:CurseEffect)->void:
				inst.global_position = owner.global_position
				inst.curse_status_resource = curse_status
				inst.is_spreadable = curse_status.status_spreadable
			
			curse_effect_instance_resource.instance.call_deferred(_curse_config_callback)
		
		var ice_status: IceStatusResource = status_setup.status_list[DamageTypeResource.DamageType.ICE]
		if ice_status != null:
			var _ice_config_callback:Callable = func (inst:IceEffect)->void:
				inst.global_position = owner.global_position
				inst.ice_status_resource = ice_status
				inst.is_spreadable = ice_status.status_spreadable
			
			ice_effect_instance_resource.instance.call_deferred(_ice_config_callback)
	actor_died.emit()
