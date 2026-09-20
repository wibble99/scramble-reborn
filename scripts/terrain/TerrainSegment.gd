extends Area2D
class_name TerrainSegment
## One interval of hand-authored terrain (between two heightmap keyframes).
## Holds both the collision polygons (ceiling rock + floor rock) and the
## pixel-art rendering for that interval. The whole stage is built from a
## chain of these at load time; TerrainSystem just slides them left each
## frame as the world scrolls.
##
## Rendered as a bold flat colour fill with a bright jagged outline along
## the passage edge - matching the original arcade's simple, saturated
## terrain silhouette rather than a shaded/textured rock face. The fill
## colour is set per-stage by TerrainSystem.

const MARGIN := 80.0
const TERRAIN_LAYER := 1 << 4

var seg_width: float = 32.0
var ceiling_left: float = 0.0
var ceiling_right: float = 0.0
var floor_left: float = Game.GAME_H
var floor_right: float = Game.GAME_H
var fill_color: Color = Palette.TERRAIN_ROCK
var outline_color: Color = Palette.TERRAIN_ROCK_LIGHT

func setup(width: float, c_left: float, c_right: float, f_left: float, f_right: float, fill: Color, outline: Color) -> void:
	seg_width = width
	ceiling_left = c_left
	ceiling_right = c_right
	floor_left = f_left
	floor_right = f_right
	fill_color = fill
	outline_color = outline

	collision_layer = TERRAIN_LAYER
	collision_mask = 0
	monitoring = false
	monitorable = true

	var ceiling_poly := CollisionPolygon2D.new()
	ceiling_poly.polygon = PackedVector2Array([
		Vector2(0, -MARGIN), Vector2(width, -MARGIN),
		Vector2(width, ceiling_right), Vector2(0, ceiling_left),
	])
	add_child(ceiling_poly)

	var floor_poly := CollisionPolygon2D.new()
	floor_poly.polygon = PackedVector2Array([
		Vector2(0, floor_left), Vector2(width, floor_right),
		Vector2(width, Game.GAME_H + MARGIN), Vector2(0, Game.GAME_H + MARGIN),
	])
	add_child(floor_poly)

	queue_redraw()

func _draw() -> void:
	var ceiling_pts := PackedVector2Array([
		Vector2(0, -MARGIN), Vector2(seg_width, -MARGIN),
		Vector2(seg_width, ceiling_right), Vector2(0, ceiling_left),
	])
	draw_polygon(ceiling_pts, PackedColorArray([fill_color]))
	draw_line(Vector2(0, ceiling_left), Vector2(seg_width, ceiling_right), outline_color, 2.0)

	var floor_pts := PackedVector2Array([
		Vector2(0, floor_left), Vector2(seg_width, floor_right),
		Vector2(seg_width, Game.GAME_H + MARGIN), Vector2(0, Game.GAME_H + MARGIN),
	])
	draw_polygon(floor_pts, PackedColorArray([fill_color]))
	draw_line(Vector2(0, floor_left), Vector2(seg_width, floor_right), outline_color, 2.0)
