## 用来检测进入攻击范围的敌人
class_name AttackDetectArea
extends Area2D

@export var enemy_attackable_resource: EnemyAttactableResource
@export var collison_shape: CollisionShape2D
@export var attack_range: float = 50.0

## 初始化
func _ready() -> void:
	assert(enemy_attackable_resource != null)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collison_shape.shape.set_deferred("radius", attack_range)


func _on_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return
	enemy_attackable_resource.add_enemy(body)


func _on_body_exited(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return
	enemy_attackable_resource.remove_enemy(body)
