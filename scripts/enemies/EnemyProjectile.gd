extends Area2D
class_name EnemyProjectile
## A turret shot aimed at the player when fired. Pooled by LevelManager.

const SPEED := 105.0

var _velocity: Vector2 = Vector2.ZERO
var _done: bool = false

func _ready() -> void:
	collision_layer = Layers.ENEMY_SHOT
	collision_mask = 0
	monitoring = false
	monitorable = true

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 2.5
	shape.shape = circle
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.ENEMY_SHOT, Sprites.enemy_shot_palette(), 2.0, "enemy_shot")
	add_child(sprite)

func activate(pos: Vector2, direction: Vector2, speed_mult: float = 1.0) -> void:
	position = pos
	var dir := direction
	if dir.length() < 0.001:
		dir = Vector2(-1.0, 0.0)
	_velocity = dir.normalized() * SPEED * speed_mult
	_done = false

func _physics_process(delta: float) -> void:
	position += _velocity * delta
	if position.x < -24.0 or position.x > Game.screen_w + 24.0 or position.y < -24.0 or position.y > Game.GAME_H + 24.0:
		_done = true

func is_done() -> bool:
	return _done
