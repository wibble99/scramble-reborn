extends CanvasLayer
class_name StageBanner
## Brief "STAGE X CLEAR" banner shown between stages.

var label: Label

func _ready() -> void:
	layer = 4
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	label = UIHelper.make_label("", 16, Palette.HUD_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	UIHelper.layout_full_width(label, 92.0, 24.0)
	root.add_child(label)

	set_process(true)

func show_text(text: String) -> void:
	label.text = text

func _process(_delta: float) -> void:
	visible = Game.state == Game.State.STAGE_CLEAR
