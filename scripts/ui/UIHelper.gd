extends RefCounted
class_name UIHelper
## Small helpers for building retro-styled Control nodes purely from code
## (no .tscn UI scenes) - a saturated colour, a dark outline, and a small
## bitmap-ish size stand in for a bespoke pixel font.

static func make_label(text: String, size: int, color: Color, h_align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	var ls := LabelSettings.new()
	ls.font_size = size
	ls.font_color = color
	ls.outline_size = 3
	ls.outline_color = Color(0, 0, 0, 1)
	l.label_settings = ls
	l.horizontal_alignment = h_align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func make_button(text: String, size: int = 12) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.custom_minimum_size = Vector2(96, 22)
	return b
