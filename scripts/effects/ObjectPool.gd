extends RefCounted
class_name ObjectPool
## Generic pool for high-frequency transient nodes (bullets, bombs, enemy
## shots, explosions). Pooled instances must implement `is_done() -> bool`
## so the pool can reclaim them automatically each frame, and should reset
## their own state in `activate(...)`-style methods called by the owner
## right after `acquire()`.
##
## Instances are deliberately left untyped (Variant) here: the pool holds a
## mix of Area2D-based projectiles and a plain Node2D explosion effect, so
## there is no single static type that exposes every member this file
## touches (visible, position, monitoring...). Each caller casts the
## returned value to its concrete type immediately after `acquire()`.

var _factory: Callable
var _parent: Node
var _free: Array = []
var _active: Array = []

func _init(factory: Callable, parent: Node) -> void:
	_factory = factory
	_parent = parent

func acquire():
	var instance
	if _free.is_empty():
		instance = _factory.call()
		_parent.add_child(instance)
	else:
		instance = _free.pop_back()
	instance.visible = true
	if instance.has_method("set_monitoring"):
		instance.monitoring = true
		instance.monitorable = true
	instance.set_process(true)
	instance.set_physics_process(true)
	_active.append(instance)
	return instance

func release(instance) -> void:
	var idx := _active.find(instance)
	if idx != -1:
		_active.remove_at(idx)
	instance.visible = false
	if instance.has_method("set_monitoring"):
		instance.monitoring = false
		instance.monitorable = false
	instance.set_process(false)
	instance.set_physics_process(false)
	instance.position = Vector2(-100000, -100000)
	_free.append(instance)

## Call once per frame from the owner to reclaim finished instances.
func update_active() -> void:
	for i in range(_active.size() - 1, -1, -1):
		var instance = _active[i]
		if instance.has_method("is_done") and instance.is_done():
			release(instance)

func release_all() -> void:
	for instance in _active.duplicate():
		release(instance)
