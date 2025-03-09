## 武器自动根据敌人转动
class_name WeaponRotationAuto
extends WeaponRotation

@export var weapom_auto_aim:WeapomAutoAim


func _process(_delta:float)->void:
	var direction: Vector2 = weapom_auto_aim.get_direction()
	if direction == Vector2.ZERO:
		direction = input_resource.aim_direction
	var dir_x:int = sign(direction.x)
	if flip_vertically && (dir_x != 0 && dir_x != current_flip):
		current_flip = dir_x
		rotate_node.scale.y = current_flip
	rotate_node.rotation = direction.angle()
