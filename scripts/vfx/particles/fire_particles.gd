class_name FireParticles
extends GPUParticles2D

func _ready():
	set_emitting.call_deferred(true)
