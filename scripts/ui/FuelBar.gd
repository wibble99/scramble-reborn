extends Control
class_name FuelBar
## Small bordered bar showing remaining fuel, colour-coded green/amber/red.

var _fraction: float = 1.0

func set_fraction(f: float) -> void:
	_fraction = clampf(f, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2.ZERO, Vector2(w, h)), Color(0, 0, 0, 0.5))
	var fill_w: float = maxf(w * _fraction - 2.0, 0.0)
	var color: Color
	if _fraction > 0.5:
		color = Palette.SHIP_GREEN
	elif _fraction > 0.22:
		color = Palette.HUD_GOLD
	else:
		color = Palette.HUD_WARN
	draw_rect(Rect2(Vector2(1, 1), Vector2(fill_w, h - 2.0)), color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(w, h)), Palette.WHITE, false, 1.0)
