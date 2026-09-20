extends CanvasLayer
class_name TouchControls
## On-screen controls: either a free analog joystick or a 4-way digital
## D-pad (Settings > Control Type), plus dedicated FIRE and BOMB buttons
## and a small pause button.
##
## This node lives OUTSIDE the fixed-aspect game sub-viewport (see Main.gd)
## so it can use the *real* screen dimensions - every position below is a
## fraction of the actual window size, recomputed on resize, so the
## buttons always land in the true reachable corners of the device instead
## of being squeezed into the game's letterboxed area.

enum CtrlMode { JOYSTICK, DPAD }

const JOY_CENTER_FRAC := Vector2(0.11, 0.74)
const JOY_RADIUS_FRAC := 0.15 # relative to screen height

const FIRE_CENTER_FRAC := Vector2(0.85, 0.66)
const BOMB_CENTER_FRAC := Vector2(0.94, 0.88)
const BUTTON_RADIUS_FRAC := 0.09 # relative to screen height

const DPAD_RADIUS_FRAC := 0.08
const DPAD_GAP_FACTOR := 2.15 # spacing between dpad buttons, x DPAD_RADIUS

const PAUSE_FRAC := Vector2(0.96, 0.07)
const PAUSE_SIZE_FRAC := 0.045 # relative to screen height

var _joy_touch_id: int = -2
var _joy_knob_offset: Vector2 = Vector2.ZERO

var _up_id: int = -2
var _down_id: int = -2
var _left_id: int = -2
var _right_id: int = -2
var _up_held: bool = false
var _down_held: bool = false
var _left_held: bool = false
var _right_held: bool = false

var _fire_touch_id: int = -2
var _bomb_touch_id: int = -2

var visual: Node2D

# Cached layout, recomputed every frame from the real screen size.
var _joy_center := Vector2.ZERO
var _joy_radius := 1.0
var _fire_center := Vector2.ZERO
var _bomb_center := Vector2.ZERO
var _button_radius := 1.0
var _dpad_radius := 1.0
var _dpad_up := Vector2.ZERO
var _dpad_down := Vector2.ZERO
var _dpad_left := Vector2.ZERO
var _dpad_right := Vector2.ZERO
var _pause_rect := Rect2()

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visual = Node2D.new()
	add_child(visual)
	visual.draw.connect(_on_draw)
	set_process(true)

func _mode() -> int:
	return CtrlMode.DPAD if Save.control_type == "dpad" else CtrlMode.JOYSTICK

func _recompute_layout() -> void:
	var s: Vector2 = Vector2(get_viewport().get_visible_rect().size)
	if s.x <= 0.0 or s.y <= 0.0:
		return
	_joy_center = Vector2(s.x * JOY_CENTER_FRAC.x, s.y * JOY_CENTER_FRAC.y)
	_joy_radius = s.y * JOY_RADIUS_FRAC
	_fire_center = Vector2(s.x * FIRE_CENTER_FRAC.x, s.y * FIRE_CENTER_FRAC.y)
	_bomb_center = Vector2(s.x * BOMB_CENTER_FRAC.x, s.y * BOMB_CENTER_FRAC.y)
	_button_radius = s.y * BUTTON_RADIUS_FRAC
	_dpad_radius = s.y * DPAD_RADIUS_FRAC
	var gap: float = _dpad_radius * DPAD_GAP_FACTOR
	_dpad_up = _joy_center + Vector2(0.0, -gap)
	_dpad_down = _joy_center + Vector2(0.0, gap)
	_dpad_left = _joy_center + Vector2(-gap, 0.0)
	_dpad_right = _joy_center + Vector2(gap, 0.0)
	var pause_size: float = s.y * PAUSE_SIZE_FRAC
	_pause_rect = Rect2(Vector2(s.x * PAUSE_FRAC.x - pause_size * 0.5, s.y * PAUSE_FRAC.y - pause_size * 0.5), Vector2(pause_size, pause_size))

func _process(_delta: float) -> void:
	visible = Game.state == Game.State.PLAYING or Game.state == Game.State.PAUSED
	_recompute_layout()
	visual.queue_redraw()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start(event.index, event.position)
		else:
			_touch_end(event.index)
	elif event is InputEventScreenDrag:
		_touch_drag(event.index, event.position)

func _touch_start(index: int, pos: Vector2) -> void:
	if _pause_rect.grow(10.0).has_point(pos):
		Controls.request_pause_toggle()
		return

	if _mode() == CtrlMode.JOYSTICK:
		if pos.distance_to(_joy_center) <= _joy_radius * 1.9 and _joy_touch_id == -2:
			_joy_touch_id = index
			_update_joy(pos)
			return
	else:
		if pos.distance_to(_dpad_up) <= _dpad_radius * 1.3 and _up_id == -2:
			_up_id = index
			_up_held = true
			_update_dpad()
			return
		if pos.distance_to(_dpad_down) <= _dpad_radius * 1.3 and _down_id == -2:
			_down_id = index
			_down_held = true
			_update_dpad()
			return
		if pos.distance_to(_dpad_left) <= _dpad_radius * 1.3 and _left_id == -2:
			_left_id = index
			_left_held = true
			_update_dpad()
			return
		if pos.distance_to(_dpad_right) <= _dpad_radius * 1.3 and _right_id == -2:
			_right_id = index
			_right_held = true
			_update_dpad()
			return

	if pos.distance_to(_fire_center) <= _button_radius * 1.3 and _fire_touch_id == -2:
		_fire_touch_id = index
		Controls.set_touch_fire(true)
		return
	if pos.distance_to(_bomb_center) <= _button_radius * 1.3 and _bomb_touch_id == -2:
		_bomb_touch_id = index
		Controls.set_touch_bomb(true)
		return

func _touch_drag(index: int, pos: Vector2) -> void:
	if _mode() == CtrlMode.JOYSTICK and index == _joy_touch_id:
		_update_joy(pos)

func _touch_end(index: int) -> void:
	if index == _joy_touch_id:
		_joy_touch_id = -2
		_joy_knob_offset = Vector2.ZERO
		Controls.set_touch_move(Vector2.ZERO)
	if index == _up_id:
		_up_id = -2
		_up_held = false
		_update_dpad()
	if index == _down_id:
		_down_id = -2
		_down_held = false
		_update_dpad()
	if index == _left_id:
		_left_id = -2
		_left_held = false
		_update_dpad()
	if index == _right_id:
		_right_id = -2
		_right_held = false
		_update_dpad()
	if index == _fire_touch_id:
		_fire_touch_id = -2
		Controls.set_touch_fire(false)
	if index == _bomb_touch_id:
		_bomb_touch_id = -2
		Controls.set_touch_bomb(false)

func _update_joy(pos: Vector2) -> void:
	var d: Vector2 = pos - _joy_center
	if d.length() > _joy_radius:
		d = d.normalized() * _joy_radius
	_joy_knob_offset = d
	Controls.set_touch_move(d / _joy_radius)

func _update_dpad() -> void:
	var vy := 0.0
	if _up_held:
		vy -= 1.0
	if _down_held:
		vy += 1.0
	var hx := 0.0
	if _left_held:
		hx -= 1.0
	if _right_held:
		hx += 1.0
	Controls.set_touch_move(Vector2(hx, vy))

func _on_draw() -> void:
	if _mode() == CtrlMode.JOYSTICK:
		visual.draw_circle(_joy_center, _joy_radius, Color(1, 1, 1, 0.14))
		visual.draw_arc(_joy_center, _joy_radius, 0.0, TAU, 28, Color(1, 1, 1, 0.4), 2.0)
		visual.draw_circle(_joy_center + _joy_knob_offset, _joy_radius * 0.42, Color(0.39, 1.0, 0.42, 0.6))
	else:
		_draw_dpad_button(_dpad_up, _up_held)
		_draw_dpad_button(_dpad_down, _down_held)
		_draw_dpad_button(_dpad_left, _left_held)
		_draw_dpad_button(_dpad_right, _right_held)

	visual.draw_circle(_fire_center, _button_radius, Color(1.0, 0.5, 0.2, 0.25 if _fire_touch_id == -2 else 0.45))
	visual.draw_arc(_fire_center, _button_radius, 0.0, TAU, 24, Color(1, 1, 1, 0.4), 2.0)

	visual.draw_circle(_bomb_center, _button_radius, Color(1.0, 0.3, 0.2, 0.25 if _bomb_touch_id == -2 else 0.45))
	visual.draw_arc(_bomb_center, _button_radius, 0.0, TAU, 24, Color(1, 1, 1, 0.4), 2.0)

	var font := ThemeDB.fallback_font
	var font_size: int = int(clampf(_button_radius * 0.34, 10.0, 28.0))
	visual.draw_string(font, _fire_center - Vector2(_button_radius * 0.62, -font_size * 0.32), "FIRE", HORIZONTAL_ALIGNMENT_CENTER, _button_radius * 1.3, font_size, Color(1, 1, 1, 0.85))
	visual.draw_string(font, _bomb_center - Vector2(_button_radius * 0.72, -font_size * 0.32), "BOMB", HORIZONTAL_ALIGNMENT_CENTER, _button_radius * 1.5, font_size, Color(1, 1, 1, 0.85))

	visual.draw_rect(_pause_rect, Color(1, 1, 1, 0.55), false, 2.0)
	var bar_w: float = _pause_rect.size.x * 0.22
	var bar_h: float = _pause_rect.size.y * 0.6
	var pad: float = _pause_rect.size.x * 0.22
	visual.draw_rect(Rect2(_pause_rect.position + Vector2(pad, _pause_rect.size.y * 0.2), Vector2(bar_w, bar_h)), Color(1, 1, 1, 0.75))
	visual.draw_rect(Rect2(_pause_rect.position + Vector2(_pause_rect.size.x - pad - bar_w, _pause_rect.size.y * 0.2), Vector2(bar_w, bar_h)), Color(1, 1, 1, 0.75))

func _draw_dpad_button(center: Vector2, held: bool) -> void:
	visual.draw_circle(center, _dpad_radius, Color(1, 1, 1, 0.32 if held else 0.16))
	visual.draw_arc(center, _dpad_radius, 0.0, TAU, 20, Color(1, 1, 1, 0.4), 2.0)
