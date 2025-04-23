## 传输资源基类，用于定义可通过AreaReceiver2D接收的数据包.
## 子类需重写process()实现具体逻辑，接收器通过success()/failed()等方法修改状态.
class_name TransmissionResource
extends ValueResource

## Notifies a need to be updated
signal update_requested
## 状态更新信号
signal state_updated(new_state: ErrorType)

## Value for error from transmission receiver
enum ErrorType {
	NONE = -1,      # 初始无效状态
	SUCCESS = 0,    # 处理成功
	TRY_AGAIN,      # 需下一帧重试
	DENIED,         # 处理被拒绝
	FAILED          # 处理失败
}

@export_group("TransmissionResource")

## Used as transmission channel to match which receiver needs to process it
@export var transmission_name:StringName

## State of transmission process
@export var state:ErrorType = ErrorType.NONE

## Receiving end might decide that transmission is invalid and processing will be cancelled.
@export var valid:bool = true


## 发送传输到接收器，返回是否成功.
## [!警告]: receiver必须在处理中调用状态方法（如success()），否则断言失败.
func send_transmission(receiver:AreaReceiver2D)->bool:
	assert(receiver != null, "Receiver is null")
	assert(!transmission_name.is_empty(), "Transmission name unset")
	## Receiving end must call either one 
	receiver.receive(self)
	
	# TODO: if signal exists use this assert
	assert(state != ErrorType.NONE, "State not set by receiver")
	return state == ErrorType.SUCCESS


func success()->void:
	state = ErrorType.SUCCESS
	state_updated.emit(state)


func try_again()->void:
	state = ErrorType.TRY_AGAIN
	state_updated.emit(state)


func failed()->void:
	state = ErrorType.FAILED
	state_updated.emit(state)


func denied()->void:
	state = ErrorType.DENIED
	state_updated.emit(state)


func invalid()->void:
	valid = false


## 处理传输资源，需子类重写.
## 参数:
##   resource_node: 关联的资源节点，用于访问场景树或父节点数据.
func process(resource_node:ResourceNode)->void:
	pass
