## 角色收到伤害时的处理组件
class_name ActorDamageSet
extends ActorDamage

@export var juicy_bar:JucyBar

var health_resource:HealthResource

func _ready()->void:
	super._ready()
	#assert(juicy_bar != null)
	health_resource = resource_node.get_resource("health")
	if juicy_bar:
		juicy_bar.set_default_values(0.0, health_resource.hp, health_resource.hp)


func _play_damaged()->void:
	super._play_damaged()
	if juicy_bar:
		juicy_bar.change_current_value(health_resource.hp)
