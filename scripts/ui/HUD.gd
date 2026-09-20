extends CanvasLayer
class_name HUD
## Arcade-style heads-up display, kept to a thin strip across the top of
## the screen so it never competes with the play field or the touch
## controls docked in the bottom corners.

var score_label: Label
var high_label: Label
var stage_label: Label
var lives_label: Label
var fuel_bar: FuelBar

var _current_fuel_frac: float = 1.0
var _warn_timer: float = 0.0

func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	score_label = UIHelper.make_label("SCORE 0", 9, Palette.HUD_TEXT)
	score_label.position = Vector2(4, 2)
	root.add_child(score_label)

	high_label = UIHelper.make_label("HI %d" % Save.high_score, 9, Palette.HUD_GOLD)
	high_label.position = Vector2(88, 2)
	root.add_child(high_label)

	stage_label = UIHelper.make_label("STAGE 1", 8, Palette.WHITE)
	stage_label.position = Vector2(178, 2)
	root.add_child(stage_label)

	lives_label = UIHelper.make_label("SHIPS 3", 8, Palette.SHIP_GREEN)
	lives_label.position = Vector2(4, 13)
	root.add_child(lives_label)

	var fuel_label := UIHelper.make_label("FUEL", 7, Palette.WHITE)
	fuel_label.position = Vector2(70, 14)
	root.add_child(fuel_label)

	fuel_bar = FuelBar.new()
	fuel_bar.position = Vector2(95, 13)
	fuel_bar.size = Vector2(110, 7)
	root.add_child(fuel_bar)

	Game.score_changed.connect(func(v): score_label.text = "SCORE %d" % v)
	Game.lives_changed.connect(func(v): lives_label.text = "SHIPS %d" % maxi(v, 0))
	Game.fuel_changed.connect(_on_fuel_changed)
	Game.stage_changed.connect(_on_stage_changed)
	Game.high_score_beaten.connect(func(v): high_label.text = "HI %d" % v)

func _on_fuel_changed(frac: float) -> void:
	_current_fuel_frac = frac
	fuel_bar.set_fraction(frac)

func _on_stage_changed(stage_index: int, loop_count: int) -> void:
	var txt := "STAGE %d" % (stage_index + 1)
	if loop_count > 0:
		txt += " L%d" % (loop_count + 1)
	stage_label.text = txt

func _process(delta: float) -> void:
	visible = Game.state == Game.State.PLAYING or Game.state == Game.State.PAUSED or Game.state == Game.State.STAGE_CLEAR
	if Game.state == Game.State.PLAYING and _current_fuel_frac < 0.22:
		_warn_timer -= delta
		if _warn_timer <= 0.0:
			_warn_timer = 0.8
			SFX.play("warning")
	else:
		_warn_timer = 0.0
