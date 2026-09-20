extends EnemyBase
class_name FuelTank
## A destructible ground target that refuels the player when destroyed -
## the risk/reward heart of the fuel system: dive low over enemy fire to
## bomb it, or keep your distance and hope the tank in your reserves lasts.

var refuel_amount: float = 34.0

func _ready() -> void:
	collision_layer = Layers.ENEMY_GROUND
	collision_mask = 0
	monitoring = false
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(9.0, 9.0)
	shape.shape = rect
	add_child(shape)

	var sprite := PixelArt.make_sprite(Sprites.FUEL_TANK, Sprites.fuel_tank_palette(), 1.5, "fuel_tank")
	add_child(sprite)

	health = 1
	score_value = 50

func _apply_destroy_effects() -> void:
	Game.add_fuel(refuel_amount)
	if level:
		level.spawn_explosion(position, false)
	SFX.play("fuel_pickup")
