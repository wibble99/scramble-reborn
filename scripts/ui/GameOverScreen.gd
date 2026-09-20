extends CanvasLayer
class_name GameOverScreen
## Classic "GAME OVER" screen with final score and a new-high-score
## celebration. A short minimum display time stops an accidental extra tap
## from bouncing straight back to the title screen.

const MIN_DISPLAY_TIME := 1.5

var score_label: Label
var new_high_label: Label
var _timer: float = 0.0

func _ready() -> void:
	layer = 3
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.04, 0.88)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var continue_btn := Button.new()
	continue_btn.flat = true
	continue_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	continue_btn.focus_mode = Control.FOCUS_NONE
	continue_btn.pressed.connect(_on_continue_pressed)
	root.add_child(continue_btn)

	var title := UIHelper.make_label("GAME OVER", 26, Palette.HUD_WARN, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(title, 60.0, 32.0)
	root.add_child(title)

	score_label = UIHelper.make_label("SCORE 0", 12, Palette.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(score_label, 104.0, 16.0)
	root.add_child(score_label)

	new_high_label = UIHelper.make_label("NEW HIGH SCORE!", 11, Palette.HUD_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(new_high_label, 126.0, 16.0)
	root.add_child(new_high_label)

	var prompt := UIHelper.make_label("TOUCH TO CONTINUE", 9, Palette.GREY, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(prompt, 170.0, 14.0)
	root.add_child(prompt)

	set_process(true)

func _process(delta: float) -> void:
	var showing := Game.state == Game.State.GAME_OVER
	visible = showing
	if showing:
		_timer += delta
		score_label.text = "SCORE %d" % Game.score
		new_high_label.visible = Game.score > 0 and Game.score >= Save.high_score
	else:
		_timer = 0.0

func _on_continue_pressed() -> void:
	if _timer < MIN_DISPLAY_TIME:
		return
	SFX.stop_music()
	Game.go_to_title()
