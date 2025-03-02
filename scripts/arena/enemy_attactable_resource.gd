class_name EnemyAttactableResource
extends SaveableResource

signal updated

var list:Array[CharacterBody2D]

## 添加敌人
func add_enemy(enemy:CharacterBody2D)->void:
	if !list.has(enemy):
		list.append(enemy)
		updated.emit()
		var ad: ActorDamage = enemy.get_node("ActorDamage")
		if !ad.actor_died.is_connected(_on_enemy_died):
			ad.actor_died.connect(_on_enemy_died.bind(enemy), CONNECT_ONE_SHOT)


## 删除敌人
func remove_enemy(enemy: CharacterBody2D) -> void:
	if list.has(enemy):
		list.erase(enemy)
		updated.emit()
		var ad: ActorDamage = enemy.get_node("ActorDamage")
		if ad.actor_died.is_connected(_on_enemy_died):
			ad.actor_died.disconnect(_on_enemy_died)


func _on_enemy_died(enemy: CharacterBody2D) -> void:
	remove_enemy(enemy)
