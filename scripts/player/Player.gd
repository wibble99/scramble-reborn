extends Area2D
class_name Player
## The player's ship. Movement uses acceleration/inertia rather than
## instant response (period-appropriate arcade feel): vertical thrust is a
## direct analog stick, while horizontal thrust adjusts a speed factor that
## the level manager turns into scroll speed, with the ship's own screen
## position drifting forward/back within a fixed band as feedback.

signal died

const V_ACCEL := 340.0
const V_MAX_SPEED := 95.0
const V_DAMPING := 300.0
const H_ACCEL := 1.1
const H_DAMPING := 0.9
const SHIP_MIN_X_FRAC := 0.22 # fraction of Game.screen_w
const SHIP_MAX_X_FRAC := 0.41
const FIRE_COOLDOWN := 0.24
const BOMB_COOLDOWN := 0.5
const RESPAWN_INVULN := 2.2

var level: LevelManager = null

var velocity_y: float = 0.0
var speed_factor: float = 0.0
var _fire_timer: float = 0.0
var _bomb_timer: float = 0.0
var _invuln_timer: float = 0.0
var _alive: bool = true
var _blink_time: float = 0.0
var sprite: Sprite2D

func _ready() -> void:
	collision_layer = Layers.PLAYER
	collision_mask = Layers.TERRAIN | Layers.ENEMY_AIR | Layers.ENEMY_GROUND | Layers.ENEMY_SHOT
	monitoring = true
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16.0, 8.0)
	shape.shape = rect
	add_child(shape)

	sprite = PixelArt.make_sprite(Sprites.PLAYER_SHIP, Sprites.player_palette(), 1.6, "player_ship")
	add_child(sprite)

	area_entered.connect(_on_area_entered)
	position = Vector2(_ship_min_x() + 10.0, Game.GAME_H * 0.5)

func _ship_min_x() -> float:
	return Game.screen_w * SHIP_MIN_X_FRAC

func _ship_max_x() -> float:
	return Game.screen_w * SHIP_MAX_X_FRAC

func reset_for_new_life() -> void:
	velocity_y = 0.0
	speed_factor = 0.0
	position = Vector2(_ship_min_x() + 10.0, Game.GAME_H * 0.5)
	_invuln_timer = RESPAWN_INVULN
	_blink_time = 0.0
	_alive = true
	visible = true
	sprite.visible = true
	monitoring = true
	monitorable = true

func is_alive() -> bool:
	return _alive

func get_scroll_speed_factor() -> float:
	return speed_factor

func _physics_process(delta: float) -> void:
	if not _alive:
		return

	var vy_in := Controls.vy
	if absf(vy_in) > 0.01:
		velocity_y = move_toward(velocity_y, vy_in * V_MAX_SPEED, V_ACCEL * delta)
	else:
		velocity_y = move_toward(velocity_y, 0.0, V_DAMPING * delta)
	position.y = clampf(position.y + velocity_y * delta, 8.0, Game.GAME_H - 8.0)

	var hx_in := Controls.hx
	if absf(hx_in) > 0.01:
		speed_factor = move_toward(speed_factor, hx_in, H_ACCEL * delta)
	else:
		speed_factor = move_toward(speed_factor, 0.0, H_DAMPING * delta)
	speed_factor = clampf(speed_factor, -1.0, 1.0)
	var target_x := lerpf(_ship_min_x(), _ship_max_x(), (speed_factor + 1.0) * 0.5)
	position.x = move_toward(position.x, target_x, 60.0 * delta)

	_fire_timer -= delta
	if Controls.fire_held and _fire_timer <= 0.0:
		_fire_timer = FIRE_COOLDOWN
		_fire()

	_bomb_timer -= delta
	if Controls.bomb_held and _bomb_timer <= 0.0:
		_bomb_timer = BOMB_COOLDOWN
		_drop_bomb()

	if _invuln_timer > 0.0:
		_invuln_timer -= delta
		_blink_time += delta
		sprite.visible = fmod(_blink_time, 0.18) < 0.09
		if _invuln_timer <= 0.0:
			sprite.visible = true

	Game.consume_fuel(delta)

func _fire() -> void:
	if level:
		level.spawn_bullet(position + Vector2(14.0, 0.0))
	SFX.play("fire")

func _drop_bomb() -> void:
	if level:
		level.spawn_bomb(position + Vector2(0.0, 6.0))
	SFX.play("bomb")

func _on_area_entered(_area: Area2D) -> void:
	if _invuln_timer > 0.0 or not _alive:
		return
	die()

func die() -> void:
	if not _alive:
		return
	_alive = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	visible = false
	if level:
		level.spawn_explosion(position, true)
	SFX.play("player_death")
	if Save.vibration_enabled:
		Input.vibrate_handheld(150)
	died.emit()
