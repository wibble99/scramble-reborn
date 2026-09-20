extends Control
class_name StageProgressBar
## The classic Scramble stage tracker: a row of outlined boxes, one per
## stage, labelled ordinally with the last one always "BASE". The current
## stage (and everything before it, for the current loop) is highlighted.

var current_stage: int = 0

func set_current_stage(idx: int) -> void:
	current_stage = idx
	queue_redraw()

func _draw() -> void:
	var n: int = maxi(Stages.STAGE_COUNT, 1)
	var w: float = size.x
	var h: float = size.y
	if w <= 0.0 or h <= 0.0:
		return
	var seg_w: float = w / float(n)
	var font := ThemeDB.fallback_font
	var font_size: int = int(clampf(h * 0.6, 6.0, 10.0))
	for i in range(n):
		var x0: float = i * seg_w
		var active: bool = i <= current_stage
		var fill: Color = Palette.HUD_WARN if active else Palette.ENEMY_PURPLE
		draw_rect(Rect2(x0 + 1.0, 0.0, seg_w - 2.0, h), fill)
		draw_rect(Rect2(x0 + 1.0, 0.0, seg_w - 2.0, h), Palette.HUD_GOLD, false, 1.0)
		var label: String = "BASE" if i == n - 1 else _ordinal(i + 1)
		draw_string(font, Vector2(x0, h * 0.72), label, HORIZONTAL_ALIGNMENT_CENTER, seg_w, font_size, Palette.WHITE)

func _ordinal(n: int) -> String:
	match n:
		1:
			return "1ST"
		2:
			return "2ND"
		3:
			return "3RD"
		4:
			return "4TH"
		5:
			return "5TH"
		_:
			return "%dTH" % n
