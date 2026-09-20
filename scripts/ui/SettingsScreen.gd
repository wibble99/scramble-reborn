extends CanvasLayer
class_name SettingsScreen
## Standalone settings overlay reachable from the title screen: sound and
## music volume, control scheme, and haptic feedback. Everything persists
## immediately to the Save autoload.

signal closed

var _sfx_slider: HSlider
var _music_slider: HSlider
var _control_option: OptionButton
var _vibration_check: CheckButton

func _ready() -> void:
	layer = 2
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var bg := ColorRect.new()
	bg.color = Palette.VOID
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var title := UIHelper.make_label("SETTINGS", 18, Palette.HUD_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(0, 14)
	title.size = Vector2(256, 24)
	root.add_child(title)

	var sfx_label := UIHelper.make_label("SFX VOLUME", 9, Palette.WHITE)
	sfx_label.position = Vector2(30, 54)
	root.add_child(sfx_label)
	_sfx_slider = HSlider.new()
	_sfx_slider.position = Vector2(140, 54)
	_sfx_slider.size = Vector2(90, 12)
	_sfx_slider.min_value = 0.0
	_sfx_slider.max_value = 1.0
	_sfx_slider.step = 0.05
	_sfx_slider.value_changed.connect(func(v): Save.set_sfx_volume(v); SFX.play("fire"))
	root.add_child(_sfx_slider)

	var music_label := UIHelper.make_label("MUSIC VOLUME", 9, Palette.WHITE)
	music_label.position = Vector2(30, 76)
	root.add_child(music_label)
	_music_slider = HSlider.new()
	_music_slider.position = Vector2(140, 76)
	_music_slider.size = Vector2(90, 12)
	_music_slider.min_value = 0.0
	_music_slider.max_value = 1.0
	_music_slider.step = 0.05
	_music_slider.value_changed.connect(func(v): Save.set_music_volume(v))
	root.add_child(_music_slider)

	var control_label := UIHelper.make_label("CONTROL TYPE", 9, Palette.WHITE)
	control_label.position = Vector2(30, 98)
	root.add_child(control_label)
	_control_option = OptionButton.new()
	_control_option.add_item("JOYSTICK", 0)
	_control_option.add_item("D-PAD", 1)
	_control_option.position = Vector2(140, 96)
	_control_option.size = Vector2(90, 18)
	_control_option.item_selected.connect(_on_control_selected)
	root.add_child(_control_option)

	var vibration_label := UIHelper.make_label("VIBRATION", 9, Palette.WHITE)
	vibration_label.position = Vector2(30, 122)
	root.add_child(vibration_label)
	_vibration_check = CheckButton.new()
	_vibration_check.position = Vector2(140, 116)
	_vibration_check.toggled.connect(func(v): Save.set_vibration_enabled(v))
	root.add_child(_vibration_check)

	var back_btn := UIHelper.make_button("BACK", 11)
	back_btn.position = Vector2(80, 170)
	back_btn.pressed.connect(close)
	root.add_child(back_btn)

func open() -> void:
	_sfx_slider.value = Save.sfx_volume
	_music_slider.value = Save.music_volume
	_control_option.select(1 if Save.control_type == "dpad" else 0)
	_vibration_check.button_pressed = Save.vibration_enabled
	visible = true

func close() -> void:
	visible = false
	closed.emit()

func _on_control_selected(idx: int) -> void:
	Save.set_control_type("dpad" if idx == 1 else "joystick")
