extends CanvasLayer
class_name TouchControls
## On-screen controls: either a free analog joystick or a 4-way digital
## D-pad (Settings > Control Type), plus dedicated FIRE and BOMB buttons
## and a small pause button. Drawn as semi-transparent overlays so they
## stay out of the way of the action underneath. Multi-touch aware: every
## control tracks its own touch index independently.

enum CtrlMode { JOYSTICK, DPAD }

const JOY_CENTER := Vector2(34.0, 176.0)
const JOY_RADIUS := 22.0

const DPAD_UP := Vector2(34.0, 150.0)
const DPAD_DOWN := Vector2(34.0, 204.0)
const DPAD_LEFT := Vector2(9.0, 177.0)
const DPAD_RIGHT := Vector2(59.0, 177.0)
const DPAD_RADIUS := 13.0

const FIRE_CENTER := Vector2(213.0, 158.0)
const BOMB_CENTER := Vector2(238.0, 196.0)
const BUTTON_RADIUS := 16.0
const PAUSE_RECT := Rect2(242.0, 3.0, 11.0, 9.0)

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

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visual = Node2D.new()
	add_child(visual)
	visual.draw.connect(_on_draw)
	set_process(true)

func _mode() -> int:
	return CtrlMode.DPAD if Save.control_type == "dpad" else CtrlMode.JOYSTICK

func _process(_delta: float) -> void:
	visible = Game.state == Game.State.PLAYING or Game.state == Game.State.PAUSED
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
	if PAUSE_RECT.has_point(pos):
		Controls.request_pause_toggle()
		return

	if _mode() == CtrlMode.JOYSTICK:
		if pos.distance_to(JOY_CENTER) <= JOY_RADIUS * 1.9 and _joy_touch_id == -2:
			_joy_touch_id = index
			_update_joy(pos)
			return
	else:
		if pos.distance_to(DPAD_UP) <= DPAD_RADIUS * 1.3 and _up_id == -2:
			_up_id = index
			_up_held = true
			_update_dpad()
			return
		if pos.distance_to(DPAD_DOWN) <= DPAD_RADIUS * 1.3 and _down_id == -2:
			_down_id = index
			_down_held = true
			_update_dpad()
			return
		if pos.distance_to(DPAD_LEFT) <= DPAD_RADIUS * 1.3 and _left_id == -2:
			_left_id = index
			_left_held = true
			_update_dpad()
			return
		if pos.distance_to(DPAD_RIGHT) <= DPAD_RADIUS * 1.3 and _right_id == -2:
			_right_id = index
			_right_held = true
			_update_dpad()
			return

	if pos.distance_to(FIRE_CENTER) <= BUTTON_RADIUS * 1.3 and _fire_touch_id == -2:
		_fire_touch_id = index
		Controls.set_touch_fire(true)
		return
	if pos.distance_to(BOMB_CENTER) <= BUTTON_RADIUS * 1.3 and _bomb_touch_id == -2:
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
	var d: Vector2 = pos - JOY_CENTER
	if d.length() > JOY_RADIUS:
		d = d.normalized() * JOY_RADIUS
	_joy_knob_offset = d
	Controls.set_touch_move(d / JOY_RADIUS)

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
		visual.draw_circle(JOY_CENTER, JOY_RADIUS, Color(1, 1, 1, 0.12))
		visual.draw_arc(JOY_CENTER, JOY_RADIUS, 0.0, TAU, 24, Color(1, 1, 1, 0.35), 1.5)
		visual.draw_circle(JOY_CENTER + _joy_knob_offset, 9.0, Color(0.39, 1.0, 0.42, 0.55))
	else:
		_draw_dpad_button(DPAD_UP, _up_held)
		_draw_dpad_button(DPAD_DOWN, _down_held)
		_draw_dpad_button(DPAD_LEFT, _left_held)
		_draw_dpad_button(DPAD_RIGHT, _right_held)

	visual.draw_circle(FIRE_CENTER, BUTTON_RADIUS, Color(1.0, 0.5, 0.2, 0.22 if _fire_touch_id == -2 else 0.4))
	visual.draw_arc(FIRE_CENTER, BUTTON_RADIUS, 0.0, TAU, 20, Color(1, 1, 1, 0.35), 1.5)

	visual.draw_circle(BOMB_CENTER, BUTTON_RADIUS, Color(1.0, 0.3, 0.2, 0.22 if _bomb_touch_id == -2 else 0.4))
	visual.draw_arc(BOMB_CENTER, BUTTON_RADIUS, 0.0, TAU, 20, Color(1, 1, 1, 0.35), 1.5)

	var font := ThemeDB.fallback_font
	visual.draw_string(font, FIRE_CENTER + Vector2(-11, 3), "FIRE", HORIZONTAL_ALIGNMENT_CENTER, 22, 8, Color(1, 1, 1, 0.8))
	visual.draw_string(font, BOMB_CENTER + Vector2(-13, 3), "BOMB", HORIZONTAL_ALIGNMENT_CENTER, 26, 8, Color(1, 1, 1, 0.8))

	visual.draw_rect(PAUSE_RECT, Color(1, 1, 1, 0.5), false, 1.0)
	visual.draw_rect(Rect2(PAUSE_RECT.position + Vector2(2, 2), Vector2(2, 5)), Color(1, 1, 1, 0.7))
	visual.draw_rect(Rect2(PAUSE_RECT.position + Vector2(6, 2), Vector2(2, 5)), Color(1, 1, 1, 0.7))

func _draw_dpad_button(center: Vector2, held: bool) -> void:
	visual.draw_circle(center, DPAD_RADIUS, Color(1, 1, 1, 0.3 if held else 0.14))
	visual.draw_arc(center, DPAD_RADIUS, 0.0, TAU, 16, Color(1, 1, 1, 0.35), 1.5)
