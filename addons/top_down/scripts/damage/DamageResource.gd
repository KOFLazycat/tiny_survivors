## 实体伤害接收器，处理伤害事件分发、抗性计算和状态效果存储.
## 需配合 DamageSetup 节点初始化 resistance_value_list 和 owner.
## 通过信号与 UI/游戏逻辑系统解耦.
class_name DamageResource
extends SaveableResource

#region SIGNALS
## 伤害报告事件（外部系统监听）
signal report_damage(damage_data:DamageDataResource)
## 实际接收伤害事件
signal received_damage(damage_data:DamageDataResource)
## 接收伤害数值事件（用于UI/日志）
signal received_damage_points(points:float, is_critical:bool, damage_type: DamageTypeResource.DamageType)
## 存储状态效果到实体
## 参数:
##   status_effect: 需持久化的状态效果资源（如中毒、燃烧）
signal store_status(status_effect:DamageStatusResource)
## 伤害接收能力变化事件
signal can_receive_changed
## 当实体成功闪避伤害时触发
## 参数:
##   damage_data: 关联的伤害数据资源，含闪避判定信息
signal damage_missed(damage_data:DamageDataResource)
#endregion

@export_group("Damage Configuration")
## 是否允许接收伤害（可动态切换）
@export var can_receive_damage: bool = true

@export_group("Resistances")
## 抗性值数组，索引对应 DamageTypeResource.DamageType 枚举
## 示例: [0.2, 0.5] 表示物理抗性20%，火焰抗性50%
@export var resistance_value_list: Array[float] = []

## 关联的实体节点（由 DamageSetup 初始化）
var owner: Node = null

#region PUBLIC METHODS
## 设置能否接收伤害，触发状态变更信号
## 典型用例: 无敌状态、技能免疫
func set_can_receive_damage(value:bool)->void:
	can_receive_damage = value
	can_receive_changed.emit()

## 报告伤害数据（非实际接收）
func report(damage_data:DamageDataResource)->void:
	report_damage.emit(damage_data)

## 处理实际伤害接收
func receive(damage_data:DamageDataResource, damage_type: DamageTypeResource.DamageType = DamageTypeResource.DamageType.PHYSICAL)->void:
	received_damage.emit(damage_data)
	receive_points(damage_data.total_damage, damage_data.is_critical, damage_type)

## 接收伤害点数（直接数值，非 DamageDataResource）
## 参数:
##   points: 实际伤害值（已计算抗性后的正值）
##   is_critical: 是否暴击，用于特效区分
func receive_points(points:float, is_critical:bool = false, damage_type: DamageTypeResource.DamageType = DamageTypeResource.DamageType.PHYSICAL)->void:
	received_damage_points.emit(points, is_critical, damage_type)

## 添加状态效果
func add_status_effect(status_effect:DamageStatusResource)->void:
	store_status.emit(status_effect)

## 处理伤害闪避
func miss_damage(damage_data:DamageDataResource)->void:
	damage_missed.emit(damage_data)
#endregion
