## 角色冲刺能力
class_name ActorDashAbility
extends DashAbility

@export var move_particles_instance_resource:InstanceResource

var move_particles: MoveParticles


func _physics_process(delta: float) -> void:
	if move_particles:
		move_particles.global_position = sprite.global_position + Vector2(0, 8)
		move_particles.emitting = dash_bool.value


func _dash_pressed()->void:
	super._dash_pressed()
	_spawn_move_particles()


func _spawn_move_particles()->void:
	if !move_particles:
		move_particles = move_particles_instance_resource.instance()
