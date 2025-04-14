class_name InfoTrackerDetail
extends InfoTracker
## 剩余子弹资源
@export var ammo_remain_resource: IntResource
## 弹匣最大容量资源
@export var ammo_capacity_resource: IntResource
@export var cartridge_count: Label


func _ready() -> void:
	super._ready()
	
	ammo_remain_resource.updated.connect(update_cartridge_count_label)
	update_cartridge_count_label()


func update_cartridge_count_label()->void:
	cartridge_count.text = "Remaining Bullets: " + str(ammo_remain_resource.value) + "/" + str(ammo_capacity_resource.value)
