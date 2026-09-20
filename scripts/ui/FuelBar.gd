extends Control
class_name FuelBar
## Segmented pixel-style fuel gauge (a row of discrete LED-like blocks that
## fill/empty one at a time) matching the original arcade's fuel readout,
## rather than a smooth modern gradient bar.

const SEGMENTS := 26
const GAP := 1.0

var _fraction: float = 1.0

func set_fraction(f: float) -> void:
	_fraction = clampf(f, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 0.0 or h <= 0.0:
		return
	var seg_w: float = (w - GAP * float(SEGMENTS - 1)) / float(SEGMENTS)
	var filled: int = int(round(_fraction * SEGMENTS))
	var lit_color: Color
	if _fraction > 0.5:
		lit_color = Palette.HUD_GOLD
	elif _fraction > 0.22:
		lit_color = Palette.FLAME_ORANGE
	else:
		lit_color = Palette.HUD_WARN
	for i in range(SEGMENTS):
		var x: float = i * (seg_w + GAP)
		var color: Color = lit_color if i < filled else Color(0.16, 0.12, 0.06, 1.0)
		draw_rect(Rect2(x, 0.0, seg_w, h), color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(w, h)), Palette.WHITE, false, 1.0)
