class_name FireParticles
extends GPUParticles2D

func _ready():
	#set_emitting.call_deferred(true)
	## 解决没有正确发送finished信号的问题
	if !ready.is_connected(restart):
		ready.connect(restart, CONNECT_ONE_SHOT)
