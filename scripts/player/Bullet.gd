extends Area2D
class_name Bullet
## The player's forward-firing shot. Pooled by LevelManager. Hits anything
## on the ENEMY_AIR layer (flying enemies, rising missiles).

const SPEED := 270.0
const SCREEN_LIMIT := 280.0

var _velocity: Vector2 = Vector2.ZERO
var _done: bool = false

func _ready() -> void:
	collision_layer = Layers.PLAYER_BULLET
	collision_mask = Layers.ENEMY_AIR
	monitoring = true
	monitorable = false

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(6.0, 3.0)
	shape.shape = rect
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.BULLET, Sprites.bullet_palette(), 2.0, "bullet")
	add_child(sprite)

	area_entered.connect(_on_area_entered)

func activate(pos: Vector2) -> void:
	position = pos
	_velocity = Vector2(SPEED, 0.0)
	_done = false

func _physics_process(delta: float) -> void:
	position += _velocity * delta
	if position.x > SCREEN_LIMIT:
		_done = true

func _on_area_entered(area: Area2D) -> void:
	if _done:
		return
	if area.has_method("take_hit"):
		area.take_hit(1)
	_done = true

func is_done() -> bool:
	return _done
