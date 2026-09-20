extends Area2D
class_name Bomb
## The player's downward bomb. Falls under gravity in screen space and
## detonates on hitting a ground target (ENEMY_GROUND) or the terrain
## floor beneath it. Pooled by LevelManager.

const GRAVITY := 280.0
const FALL_LIMIT := 260.0

var _vy: float = 0.0
var _done: bool = false
var _level: LevelManager = null

func _ready() -> void:
	collision_layer = Layers.PLAYER_BOMB
	collision_mask = Layers.ENEMY_GROUND
	monitoring = true
	monitorable = false

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 3.0
	shape.shape = circle
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.BOMB, Sprites.bomb_palette(), 2.0, "bomb")
	add_child(sprite)

	area_entered.connect(_on_area_entered)

func activate(pos: Vector2, level_mgr: LevelManager) -> void:
	position = pos
	_vy = 16.0
	_done = false
	_level = level_mgr

func _physics_process(delta: float) -> void:
	if _done:
		return
	_vy += GRAVITY * delta
	position.y += _vy * delta

	if _level:
		var world_x: float = _level.scroll_distance + position.x
		var floor_y: float = _level.terrain.floor_at(world_x)
		if position.y >= floor_y:
			_impact()
			return

	if position.y > FALL_LIMIT:
		_done = true

func _on_area_entered(area: Area2D) -> void:
	if _done:
		return
	if area.has_method("take_hit"):
		area.take_hit(3)
	_impact()

func _impact() -> void:
	if _done:
		return
	_done = true
	if _level:
		_level.spawn_explosion(position, false)

func is_done() -> bool:
	return _done
