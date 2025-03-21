## 玩家生命初始化与升级
class_name PlayerHealthUpdate
extends Node

@export var resource_node: ResourceNode
@export var ability_system: AbilitySystem
@export var stats_component: StatsComponent
@export var health_ability_name: StringName = "health_ability"

var health_resource: HealthResource

## Player's health is globally used and stays the same
func _ready()->void:
	health_resource = resource_node.get_resource("health")
	health_resource.reset_resource()
	health_resource.dead.connect(owner.queue_free)
	
	ability_system.ability_added.connect(_on_ability_system_ability_added)


func _on_ability_system_ability_added(ability: AbilityResource) -> void:
	if ability.ability_name != health_ability_name:
		return
	var max_hp: float = stats_component.get_stat(StatsComponent.STAT.MAX_HEALTH)
	if max_hp > health_resource.max_hp:
		var tmp_hp: float = max_hp - health_resource.max_hp
		health_resource.set_max_hp(max_hp)
		health_resource.add_hp(tmp_hp)
