extends EnemyBase
class_name GroundTurret
## A stationary ground-based cannon. Fires an aimed shot at the player at a
## steady cadence once it's on screen. Destroyed by bombs (it sits on the
## floor, out of the forward gun's flight line).

var fire_cooldown: float = 2.2
var _timer: float = 0.0

func _ready() -> void:
	collision_layer = Layers.ENEMY_GROUND
	collision_mask = 0
	monitoring = false
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(11.0, 8.0)
	shape.shape = rect
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.TURRET, Sprites.turret_palette(), 1.6, "turret")
	add_child(sprite)

	health = 2
	score_value = 150
	_timer = randf_range(0.6, 2.0)

func _update(delta: float, screen_x: float) -> void:
	if screen_x < -20.0 or screen_x > Game.screen_w + 24.0:
		return
	_timer -= delta * Game.difficulty_multiplier()
	if _timer <= 0.0 and level and level.player and level.player.is_alive():
		_timer = fire_cooldown
		var dir: Vector2 = (level.player.position - position).normalized()
		level.spawn_enemy_shot(position + Vector2(0.0, -6.0), dir)
		SFX.play("fire", 0.7)
