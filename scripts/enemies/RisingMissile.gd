extends EnemyBase
class_name RisingMissile
## The classic Scramble rocket: sits dormant in a ground silo until the
## player closes in, then launches straight up through the passage. It can
## be shot down with the forward gun while dormant or rising.

enum MState { DORMANT, RISING }

var m_state: int = MState.DORMANT
var floor_y: float = 200.0
var rise_speed: float = 0.0

const RISE_ACCEL := 150.0
const MAX_RISE_SPEED := 140.0
const TRIGGER_AHEAD := 70.0

func _ready() -> void:
	collision_layer = Layers.ENEMY_AIR
	collision_mask = 0
	monitoring = false
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(5.0, 11.0)
	shape.shape = rect
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.MISSILE, Sprites.missile_palette(), 1.5, "missile")
	add_child(sprite)

	health = 1
	score_value = 200

func configure(pad_floor_y: float) -> void:
	floor_y = pad_floor_y
	position.y = floor_y - 10.0

func _update(delta: float, screen_x: float) -> void:
	if m_state == MState.DORMANT:
		position.y = floor_y - 10.0
		if level and level.player and level.player.is_alive():
			if screen_x > -40.0 and screen_x <= level.player.position.x + TRIGGER_AHEAD:
				m_state = MState.RISING
				rise_speed = 26.0
	else:
		rise_speed = minf(rise_speed + RISE_ACCEL * delta * Game.difficulty_multiplier(), MAX_RISE_SPEED)
		position.y -= rise_speed * delta
		if position.y < -20.0:
			_destroyed = true
			monitoring = false
			monitorable = false
			queue_free()
