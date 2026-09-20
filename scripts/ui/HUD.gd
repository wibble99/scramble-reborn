extends CanvasLayer
class_name HUD
## Arcade-style heads-up display matching the original's layout: "1UP" and
## score top-left, "HIGH SCORE" and its value centred, a per-stage progress
## bar below that, and a segmented fuel gauge with ship-icon lives docked
## along the bottom edge.

var score_label: Label
var high_label: Label
var stage_bar: StageProgressBar
var fuel_bar: FuelBar
var lives_root: Control

var _current_fuel_frac: float = 1.0
var _warn_timer: float = 0.0
var _lives_icons: Array = []

func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var up_label := UIHelper.make_label("1UP", 8, Palette.HUD_WARN, HORIZONTAL_ALIGNMENT_LEFT)
	up_label.position = Vector2(4, 1)
	root.add_child(up_label)

	score_label = UIHelper.make_label("0", 10, Palette.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
	score_label.position = Vector2(4, 9)
	root.add_child(score_label)

	var high_title := UIHelper.make_label("HIGH SCORE", 8, Palette.HUD_WARN, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(high_title, 1.0, 9.0)
	root.add_child(high_title)

	high_label = UIHelper.make_label("%d" % Save.high_score, 10, Palette.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(high_label, 9.0, 10.0)
	root.add_child(high_label)

	stage_bar = StageProgressBar.new()
	stage_bar.anchor_left = 0.0
	stage_bar.anchor_right = 1.0
	stage_bar.offset_left = 3.0
	stage_bar.offset_right = -3.0
	stage_bar.offset_top = 20.0
	stage_bar.offset_bottom = 29.0
	root.add_child(stage_bar)

	lives_root = Control.new()
	lives_root.position = Vector2(4, 202)
	lives_root.size = Vector2(1, 1)
	root.add_child(lives_root)

	var fuel_label := UIHelper.make_label("FUEL", 8, Palette.WHITE)
	fuel_label.position = Vector2(4, 214)
	root.add_child(fuel_label)

	fuel_bar = FuelBar.new()
	fuel_bar.anchor_left = 0.0
	fuel_bar.anchor_right = 1.0
	fuel_bar.offset_left = 32.0
	fuel_bar.offset_right = -4.0
	fuel_bar.offset_top = 214.0
	fuel_bar.offset_bottom = 221.0
	root.add_child(fuel_bar)

	Game.score_changed.connect(func(v): score_label.text = "%d" % v)
	Game.lives_changed.connect(_on_lives_changed)
	Game.fuel_changed.connect(_on_fuel_changed)
	Game.stage_changed.connect(_on_stage_changed)
	Game.high_score_beaten.connect(func(v): high_label.text = "%d" % v)

func _on_fuel_changed(frac: float) -> void:
	_current_fuel_frac = frac
	fuel_bar.set_fraction(frac)

func _on_stage_changed(stage_index: int, _loop_count: int) -> void:
	stage_bar.set_current_stage(stage_index)

func _on_lives_changed(lives: int) -> void:
	for icon in _lives_icons:
		icon.queue_free()
	_lives_icons.clear()
	var reserve: int = maxi(lives - 1, 0)
	for i in range(reserve):
		var icon := PixelArt.make_sprite(Sprites.PLAYER_SHIP, Sprites.player_palette(), 0.6, "player_ship")
		icon.position = Vector2(10 + i * 14, 0)
		lives_root.add_child(icon)
		_lives_icons.append(icon)

func _process(delta: float) -> void:
	visible = Game.state == Game.State.PLAYING or Game.state == Game.State.PAUSED or Game.state == Game.State.STAGE_CLEAR
	if Game.state == Game.State.PLAYING and _current_fuel_frac < 0.22:
		_warn_timer -= delta
		if _warn_timer <= 0.0:
			_warn_timer = 0.8
			SFX.play("warning")
	else:
		_warn_timer = 0.0
