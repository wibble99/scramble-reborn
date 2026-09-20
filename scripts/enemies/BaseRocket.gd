extends EnemyBase
class_name BaseRocket
## The final encounter: a large rocket sitting at the enemy base at the end
## of the last stage. Tough and high-value - the closing "boss" beat of a
## run before the loop repeats at higher difficulty.

func _ready() -> void:
	collision_layer = Layers.ENEMY_GROUND
	collision_mask = 0
	monitoring = false
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(13.0, 26.0)
	shape.shape = rect
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.BASE_ROCKET, Sprites.base_rocket_palette(), 1.35, "base_rocket")
	add_child(sprite)

	health = 6
	score_value = 1000

func _apply_destroy_effects() -> void:
	if level:
		level.spawn_explosion(position, true)
	SFX.play("explosion")
