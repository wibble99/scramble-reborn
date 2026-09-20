extends Node
## Merges keyboard input (for quick desktop testing in the editor) with
## touch input from the on-screen controls into one polled input state
## that Player and the UI read from every frame.

var vy: float = 0.0 # -1 = up, +1 = down
var hx: float = 0.0 # -1 = decelerate, +1 = accelerate
var fire_held: bool = false
var bomb_held: bool = false
var pause_just_pressed: bool = false

var _touch_vy: float = 0.0
var _touch_hx: float = 0.0
var _touch_fire: bool = false
var _touch_bomb: bool = false
var _prev_pause_key: bool = false
var _touch_pause_request: bool = false

func _ready() -> void:
	# Must keep polling input while the tree is paused, otherwise the
	# pause button/key could never be read to resume the game.
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	var kb_vy := 0.0
	var kb_hx := 0.0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		kb_vy -= 1.0
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		kb_vy += 1.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		kb_hx -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		kb_hx += 1.0
	var kb_fire := Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_CTRL)
	var kb_bomb := Input.is_key_pressed(KEY_X) or Input.is_key_pressed(KEY_ALT)

	vy = clampf(kb_vy + _touch_vy, -1.0, 1.0)
	hx = clampf(kb_hx + _touch_hx, -1.0, 1.0)
	fire_held = kb_fire or _touch_fire
	bomb_held = kb_bomb or _touch_bomb

	var pause_key := Input.is_key_pressed(KEY_ESCAPE) or Input.is_key_pressed(KEY_P)
	pause_just_pressed = (pause_key and not _prev_pause_key) or _touch_pause_request
	_prev_pause_key = pause_key
	_touch_pause_request = false

func set_touch_move(v: Vector2) -> void:
	_touch_hx = clampf(v.x, -1.0, 1.0)
	_touch_vy = clampf(v.y, -1.0, 1.0)

func set_touch_fire(held: bool) -> void:
	_touch_fire = held

func set_touch_bomb(held: bool) -> void:
	_touch_bomb = held

func request_pause_toggle() -> void:
	_touch_pause_request = true
