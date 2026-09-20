extends Node2D
class_name Decoration
## Purely cosmetic ground installation (a simple blocky building/tower
## silhouette with a few lit windows) scattered along the terrain floor
## between hazards. No collision, no score - just scenery, matching the
## look of the ground bases dotting the original arcade's terrain.

const CULL_X := -300.0

var world_x: float = 0.0
var level: LevelManager = null
var width: float = 14.0
var height: float = 24.0
var rows: int = 2

func setup(spawn_world_x: float, level_mgr: LevelManager, w: float, h: float, r: int) -> void:
	world_x = spawn_world_x
	level = level_mgr
	width = w
	height = h
	rows = maxi(r, 1)
	z_index = -1
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if level == null:
		return
	var screen_x: float = world_x - level.scroll_distance
	position.x = screen_x
	if screen_x < CULL_X:
		queue_free()

func _draw() -> void:
	var body := Rect2(Vector2(-width * 0.5, -height), Vector2(width, height))
	draw_rect(body, Palette.TERRAIN_ROCK_DARK)
	draw_rect(body, Palette.TERRAIN_ROCK_LIGHT, false, 1.0)

	var win_w: float = width * 0.24
	var win_h: float = maxf(height / (rows * 2.6), 2.0)
	var left_x: float = -width * 0.32
	var right_x: float = width * 0.08
	for r in range(rows):
		var t: float = (float(r) + 0.55) / float(rows)
		var y: float = -height + height * t
		draw_rect(Rect2(Vector2(left_x, y), Vector2(win_w, win_h)), Palette.TANK_YELLOW)
		draw_rect(Rect2(Vector2(right_x, y), Vector2(win_w, win_h)), Palette.TANK_YELLOW)
