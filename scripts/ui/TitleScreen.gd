extends CanvasLayer
class_name TitleScreen
## Arcade-style title screen: original title treatment, high score, and a
## blinking start prompt. Any tap/click outside the settings button starts
## a new game, matching the "insert coin" immediacy of the source material.

signal settings_requested

var high_label: Label
var prompt_label: Label
var _blink: float = 0.0

func _ready() -> void:
	layer = 1
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Palette.VOID
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var start_btn := Button.new()
	start_btn.flat = true
	start_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	start_btn.focus_mode = Control.FOCUS_NONE
	start_btn.pressed.connect(_on_start_pressed)
	root.add_child(start_btn)

	var title := UIHelper.make_label("SCRAMBLE", 30, Palette.HUD_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(0, 36)
	title.size = Vector2(256, 36)
	root.add_child(title)

	var subtitle := UIHelper.make_label("R E B O R N", 14, Palette.HUD_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.position = Vector2(0, 70)
	subtitle.size = Vector2(256, 18)
	root.add_child(subtitle)

	high_label = UIHelper.make_label("HIGH SCORE %d" % Save.high_score, 10, Palette.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	high_label.position = Vector2(0, 108)
	high_label.size = Vector2(256, 14)
	root.add_child(high_label)

	prompt_label = UIHelper.make_label("TOUCH TO START", 11, Palette.SHIP_GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.position = Vector2(0, 148)
	prompt_label.size = Vector2(256, 16)
	root.add_child(prompt_label)

	var one_player := UIHelper.make_label("1 PLAYER", 8, Palette.GREY, HORIZONTAL_ALIGNMENT_CENTER)
	one_player.position = Vector2(0, 168)
	one_player.size = Vector2(256, 12)
	root.add_child(one_player)

	var settings_btn := UIHelper.make_button("SETTINGS", 9)
	settings_btn.position = Vector2(80, 190)
	settings_btn.pressed.connect(func(): settings_requested.emit())
	root.add_child(settings_btn)

	set_process(true)

func _on_start_pressed() -> void:
	if Game.state != Game.State.TITLE:
		return
	SFX.play("game_start")
	SFX.start_music()
	Game.start_new_game()

func _process(delta: float) -> void:
	visible = Game.state == Game.State.TITLE
	if visible:
		high_label.text = "HIGH SCORE %d" % Save.high_score
		_blink += delta
		prompt_label.visible = fmod(_blink, 1.0) < 0.65
