extends EnemyBase
class_name FlyingEnemy
## A flying enemy craft that bobs along a sine-wave path - the airborne
## threat the player's forward gun is meant for.

var base_y: float = 100.0
var amplitude: float = 20.0
var freq: float = 1.2
var _t: float = 0.0

func _ready() -> void:
	collision_layer = Layers.ENEMY_AIR
	collision_mask = 0
	monitoring = false
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(13.0, 7.0)
	shape.shape = rect
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.FLYER, Sprites.flyer_palette(), 1.4, "flyer")
	add_child(sprite)

	health = 1
	score_value = 100

func configure(spawn_y: float, amp: float, frequency: float) -> void:
	base_y = spawn_y
	amplitude = amp
	freq = frequency
	_t = randf() * TAU
	position.y = base_y

func _update(delta: float, _screen_x: float) -> void:
	_t += delta * Game.difficulty_multiplier()
	position.y = base_y + sin(_t * freq) * amplitude
