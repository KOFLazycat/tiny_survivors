class_name ActiveEnemy
extends Node

## 静态字典：存储敌人实例与其关联资源的映射关系（键：敌人实例，值：ActiveEnemyResource）
## 全局可通过 ActiveEnemy.instance_dictionary 访问
static var instance_dictionary: Dictionary = {}

## 树形结构的根节点资源，所有没有父节点的敌人分支都挂载在此
static var root: ActiveEnemyResource = ActiveEnemyResource.new()

## 存储所有活动敌人实例的弱引用数组（避免强引用导致内存泄漏）
static var active_instances: Array[Node2D] = []

##-----------------------------------------------------------------------
## 插入新的敌人分支到树形结构中
## @param node: 新敌人实例（将被添加到字典映射）
## @param parent_branch: 父分支资源（如果为null，新分支将挂载到根节点）
## @param clear_callback: 清理时触发的回调函数（可选）
static func insert_child(node: Node, parent_branch: ActiveEnemyResource, clear_callback: Callable = Callable()) -> void:
	# 创建新的资源节点并初始化
	var _active_enemy_resource: ActiveEnemyResource = ActiveEnemyResource.new()
	_active_enemy_resource.parent = parent_branch
	_active_enemy_resource.clear_callback = clear_callback
	
	# 将敌人实例与资源关联
	instance_dictionary[node] = _active_enemy_resource
	
	# 如果父分支为空，挂载到根节点（修复资源泄漏问题）
	if parent_branch == null:
		root.children.append(_active_enemy_resource)
		return
	
	# 将新资源添加到父分支的子节点列表
	parent_branch.children.append(_active_enemy_resource)

##-----------------------------------------------------------------------
## 递归删除指定分支（当分支没有节点和子节点时）
## @param branch: 要删除的分支资源
## @param caller: 调用此方法的敌人实例（用于回调参数传递）
static func remove_branch(branch: ActiveEnemyResource, caller: ActiveEnemy) -> void:
	# 防御性检查：如果分支仍有节点或子节点，终止操作
	if !branch.nodes.is_empty() || !branch.children.is_empty():
		return
	
	# 安全触发清理回调（检查回调有效性和caller实例状态）
	if branch.clear_callback.is_valid() && is_instance_valid(caller):
		branch.clear_callback.call(caller)
	
	# 如果分支有父节点，从父节点中移除自身引用
	if branch.parent != null:
		assert(branch.parent.children.has(branch), "父节点不包含该分支，数据不一致！")
		branch.parent.children.erase(branch)
		
		# 递归检查父节点是否需要清理（如果父节点无子节点且无实例）
		if branch.parent.children.is_empty():
			remove_branch(branch.parent, caller)
	
	# 清除循环引用帮助GC回收（修复内存泄漏）
	branch.parent = null
	branch.children.clear()

##-----------------------------------------------------------------------
## 递归销毁指定分支的所有敌人实例
## @param branch: 要清理的分支资源
static func destroy_children_enemies(branch: ActiveEnemyResource) -> void:
	# 销毁当前分支所有节点实例
	for _enemy: ActiveEnemy in branch.nodes:
		_enemy.self_destruct()
	
	# 深度优先遍历销毁子分支
	for _child_branch in branch.children:
		destroy_children_enemies(_child_branch)

##========================================================================
## 实例相关属性和方法
##========================================================================

## 监听的节点（通常为自身或父节点）
@export var listen_node: Node

## 要监听的信号名称（当信号触发时执行remove_self）
@export var signal_name: StringName

## 关联的资源节点（用于获取生命值等数据）
@export var resource_node: ResourceNode

## 是否在移除时销毁所有子分支敌人
@export var destroy_children: bool

## 当前实例关联的敌人资源
var enemy_resource: ActiveEnemyResource

##-----------------------------------------------------------------------
## 从资源树中移除自身（触发清理逻辑）
func remove_self() -> void:
	# 如果开启子节点销毁，逆向遍历防止数组修改冲突
	if destroy_children:
		var children_copy = enemy_resource.children.duplicate()  # 创建副本避免遍历时修改
		for child in children_copy:
			destroy_children_enemies(child)
	
	# 从资源节点中移除自身引用
	enemy_resource.nodes.erase(self)
	
	# 触发分支清理检查
	remove_branch(enemy_resource, self)

##-----------------------------------------------------------------------
## 节点就绪时初始化信号监听
func _ready() -> void:
	if listen_node != null && listen_node.has_signal(signal_name):
		# 确保信号只连接一次
		if !listen_node.is_connected(signal_name, remove_self):
			listen_node.connect(signal_name, remove_self)

##-----------------------------------------------------------------------
## 当节点进入场景树时关联资源
func _enter_tree() -> void:
	# 从字典获取或分配根资源
	if instance_dictionary.has(owner):
		enemy_resource = instance_dictionary[owner]
		instance_dictionary.erase(owner)  # 防止重复使用
	else:
		enemy_resource = root
	
	# 将自身添加到资源节点
	enemy_resource.nodes.append(self)
	
	# 记录活动实例
	active_instances.append(owner)
	
	# 连接退出树的信号（一次性连接避免重复触发）
	tree_exiting.connect(_on_exiting_tree.bind(owner), CONNECT_ONE_SHOT)

##-----------------------------------------------------------------------
## 处理节点退出场景树时的清理
## @param owner_reference: 绑定的拥有者引用（可能为null）
func _on_exiting_tree(owner_reference: Node2D) -> void:
	# 防御性处理空引用
	if owner_reference == null:
		push_warning("Owner引用已丢失，可能已被提前释放！")
		return
	
	# 从活动实例列表中移除
	active_instances.erase(owner_reference)

##-----------------------------------------------------------------------
## 立即销毁敌人实例（例如：分裂或死亡时调用）
func self_destruct() -> void:
	var _health_resource: HealthResource = resource_node.get_resource("health")
	_health_resource.insta_kill()  # 调用生命值资源的秒杀方法
