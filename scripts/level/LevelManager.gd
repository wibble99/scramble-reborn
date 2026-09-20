extends Node2D
class_name LevelManager
## Orchestrates one stage: owns the terrain, drives the world-scroll speed
## from the player's horizontal thrust, spawns enemies as the scroll
## reveals them, and detects the end of the stage. Also owns the object
## pools for every pooled transient (bullets, bombs, enemy shots,
## explosions) so Player/enemies never allocate a new node mid-play.

const SCREEN_W := 256.0
const SPAWN_MARGIN := 40.0
const SCROLL_RANGE := 42.0
const SCROLL_MIN := 20.0

const TURRET_ANCHOR := 7.0
const FUEL_ANCHOR := 7.5
const BASE_ROCKET_ANCHOR := 19.0

var player: Player = null
var terrain: TerrainSystem
var scroll_distance: float = 0.0
var stage_finished: bool = false

var _stage_data: Dictionary = {}
var _enemy_spawns: Array = []
var _spawn_cursor: int = 0
var _stage_length: float = 0.0

var _bullet_pool: ObjectPool
var _bomb_pool: ObjectPool
var _shot_pool: ObjectPool
var _explosion_pool: ObjectPool

func _ready() -> void:
	terrain = TerrainSystem.new()
	add_child(terrain)
	_bullet_pool = ObjectPool.new(func(): return Bullet.new(), self)
	_bomb_pool = ObjectPool.new(func(): return Bomb.new(), self)
	_shot_pool = ObjectPool.new(func(): return EnemyProjectile.new(), self)
	_explosion_pool = ObjectPool.new(func(): return Explosion.new(), self)

func load_stage(stage_data: Dictionary) -> void:
	_stage_data = stage_data
	terrain.build(stage_data.get("terrain", []))
	_stage_length = terrain.stage_length
	_enemy_spawns = (stage_data.get("enemies", []) as Array).duplicate(true)
	_enemy_spawns.sort_custom(func(a, b): return a.x < b.x)
	_spawn_cursor = 0
	scroll_distance = 0.0
	stage_finished = false
	_bullet_pool.release_all()
	_bomb_pool.release_all()
	_shot_pool.release_all()
	_explosion_pool.release_all()
	_clear_enemies()

func _clear_enemies() -> void:
	for child in get_children():
		if child is EnemyBase:
			child.queue_free()

func _physics_process(delta: float) -> void:
	if Game.state != Game.State.PLAYING or stage_finished or player == null or not player.is_alive():
		_bullet_pool.update_active()
		_bomb_pool.update_active()
		_shot_pool.update_active()
		_explosion_pool.update_active()
		return

	var factor: float = player.get_scroll_speed_factor()
	var base_speed: float = _stage_data.get("scroll_speed", 60.0)
	var speed: float = (base_speed + factor * SCROLL_RANGE) * Game.difficulty_multiplier()
	speed = maxf(speed, SCROLL_MIN)
	scroll_distance += speed * delta

	terrain.update_scroll(scroll_distance)
	_update_spawns()

	_bullet_pool.update_active()
	_bomb_pool.update_active()
	_shot_pool.update_active()
	_explosion_pool.update_active()

	if scroll_distance >= _stage_length - 4.0:
		stage_finished = true
		Game.advance_stage()

func _update_spawns() -> void:
	var reveal_x: float = scroll_distance + SCREEN_W + SPAWN_MARGIN
	while _spawn_cursor < _enemy_spawns.size() and _enemy_spawns[_spawn_cursor].x <= reveal_x:
		_spawn_enemy(_enemy_spawns[_spawn_cursor])
		_spawn_cursor += 1

func _spawn_enemy(data: Dictionary) -> void:
	var enemy_type: String = data.get("type", "")
	var wx: float = data.get("x", 0.0)
	match enemy_type:
		"flyer":
			var e := FlyingEnemy.new()
			add_child(e)
			e.setup(wx, self)
			e.configure(data.get("y", 90.0), data.get("amp", 14.0), data.get("freq", 1.1))
		"turret":
			var e := GroundTurret.new()
			add_child(e)
			e.setup(wx, self)
			e.position.y = terrain.floor_at(wx) - TURRET_ANCHOR
		"fuel":
			var e := FuelTank.new()
			add_child(e)
			e.setup(wx, self)
			e.position.y = terrain.floor_at(wx) - FUEL_ANCHOR
		"missile":
			var e := RisingMissile.new()
			add_child(e)
			e.setup(wx, self)
			e.configure(terrain.floor_at(wx))
		"base_rocket":
			var e := BaseRocket.new()
			add_child(e)
			e.setup(wx, self)
			e.position.y = terrain.floor_at(wx) - BASE_ROCKET_ANCHOR

func spawn_bullet(pos: Vector2) -> void:
	var b := _bullet_pool.acquire() as Bullet
	b.activate(pos)

func spawn_bomb(pos: Vector2) -> void:
	var b := _bomb_pool.acquire() as Bomb
	b.activate(pos, self)

func spawn_enemy_shot(pos: Vector2, dir: Vector2) -> void:
	var s := _shot_pool.acquire() as EnemyProjectile
	s.activate(pos, dir, Game.difficulty_multiplier())

func spawn_explosion(pos: Vector2, big: bool) -> void:
	var e := _explosion_pool.acquire() as Explosion
	e.activate(pos, big)
