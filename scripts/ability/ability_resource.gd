## 玩家升级能力资源类
class_name AbilityResource
extends ValueResource

@export_group("AbilityResource")
## 能力名称
@export var ability_name:StringName

## 是否可用
@export var valid:bool = true

## Value for error from transmission receiver
#enum ErrorType {
	### Default value
	#NONE = -1,
	### Transmission processed successfully
	#SUCCESS = 0, 
	### Try transmission next physics frame
	#TRY_AGAIN, 
	### Transmission processing was denied
	#DENIED,
	### Transmission process was denied
	#FAILED}


## Receiver need to provide a reference to a ResourceNode
## Override this function with specific use.
## Should result with a state change
func process(resource_node:ResourceNode)->void:
	pass
