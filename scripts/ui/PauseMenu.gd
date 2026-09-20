extends CanvasLayer
class_name PauseMenu
## Pause overlay with quick volume access and a way back to the title
## screen. Stays responsive while the SceneTree itself is paused because
## every node here uses PROCESS_MODE_ALWAYS.

func _ready() -> void:
	layer = 6
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var title := UIHelper.make_label("PAUSED", 20, Palette.HUD_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(title, 26.0, 26.0)
	root.add_child(title)

	# A fixed-width panel, horizontally centred regardless of screen width.
	var panel := Control.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.offset_left = -100.0
	panel.offset_right = 100.0
	panel.offset_top = 0.0
	panel.offset_bottom = 224.0
	root.add_child(panel)

	var sfx_label := UIHelper.make_label("SFX", 9, Palette.WHITE)
	sfx_label.position = Vector2(0, 70)
	panel.add_child(sfx_label)

	var sfx_slider := HSlider.new()
	sfx_slider.position = Vector2(35, 70)
	sfx_slider.size = Vector2(100, 12)
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = Save.sfx_volume
	sfx_slider.value_changed.connect(func(v): Save.set_sfx_volume(v))
	panel.add_child(sfx_slider)

	var music_label := UIHelper.make_label("MUSIC", 9, Palette.WHITE)
	music_label.position = Vector2(0, 90)
	panel.add_child(music_label)

	var music_slider := HSlider.new()
	music_slider.position = Vector2(35, 90)
	music_slider.size = Vector2(100, 12)
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = Save.music_volume
	music_slider.value_changed.connect(func(v): Save.set_music_volume(v))
	panel.add_child(music_slider)

	var resume_btn := UIHelper.make_button("RESUME", 11)
	resume_btn.position = Vector2(18, 120)
	resume_btn.pressed.connect(func(): Game.resume_game())
	panel.add_child(resume_btn)

	var quit_btn := UIHelper.make_button("QUIT TO TITLE", 10)
	quit_btn.position = Vector2(8, 150)
	quit_btn.pressed.connect(_on_quit_pressed)
	panel.add_child(quit_btn)

	set_process(true)

func _on_quit_pressed() -> void:
	SFX.stop_music()
	Game.go_to_title()

func _process(_delta: float) -> void:
	visible = Game.state == Game.State.PAUSED
