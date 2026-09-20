extends Area2D
class_name EnemyBase
## Common behaviour shared by every destructible level object: it tracks its
## own position in "world space" and converts that to screen space each
## frame based on the level's scroll distance, takes damage from player
## weapons, and cleans itself up once it has scrolled off the left side of
## the screen (it can never come back on-screen again, since the world only
## scrolls one way).

const CULL_X := -300.0

var world_x: float = 0.0
var level: LevelManager = null
var health: int = 1
var score_value: int = 100
var _destroyed: bool = false

func setup(spawn_world_x: float, level_mgr: LevelManager) -> void:
	world_x = spawn_world_x
	level = level_mgr

func take_hit(damage: int) -> void:
	if _destroyed:
		return
	health -= damage
	if health <= 0:
		_on_destroyed()

func is_alive() -> bool:
	return not _destroyed

func _physics_process(_delta: float) -> void:
	if _destroyed or level == null:
		return
	var screen_x: float = world_x - level.scroll_distance
	position.x = screen_x
	if screen_x < CULL_X:
		_destroyed = true
		monitoring = false
		monitorable = false
		queue_free()
		return
	_update(_delta, screen_x)

func _update(_delta: float, _screen_x: float) -> void:
	pass # overridden by subclasses

func _on_destroyed() -> void:
	if _destroyed:
		return
	_destroyed = true
	Game.add_score(score_value)
	_apply_destroy_effects()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	queue_free()

func _apply_destroy_effects() -> void:
	if level:
		level.spawn_explosion(position, false)
	SFX.play("enemy_destroy")
