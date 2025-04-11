class_name InfoTrackerDetail
extends InfoTracker

@export var ammo_remain_resource: IntResource
@export var cartridge_count: Label


func _ready() -> void:
	super._ready()
	
	ammo_remain_resource.updated.connect(update_cartridge_count_label)
	update_cartridge_count_label()


func update_cartridge_count_label()->void:
	cartridge_count.text = "Remaining Bullets: " + str(ammo_remain_resource.value)
