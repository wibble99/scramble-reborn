extends Node
## Local persistence for the high score and player settings.
## Uses Godot's ConfigFile, stored under user:// (app-private storage on
## Android), so it survives app restarts without any extra dependencies.

const SAVE_PATH := "user://scramble_save.cfg"

var high_score: int = 0
var sfx_volume: float = 1.0
var music_volume: float = 0.6
var control_type: String = "joystick" # "joystick" or "dpad"
var vibration_enabled: bool = true

func _ready() -> void:
	load_data()

func load_data() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK:
		high_score = cfg.get_value("scores", "high_score", 0)
		sfx_volume = cfg.get_value("settings", "sfx_volume", 1.0)
		music_volume = cfg.get_value("settings", "music_volume", 0.6)
		control_type = cfg.get_value("settings", "control_type", "joystick")
		vibration_enabled = cfg.get_value("settings", "vibration_enabled", true)
	SFX.set_sfx_volume(sfx_volume)
	SFX.set_music_volume(music_volume)

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("scores", "high_score", high_score)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "control_type", control_type)
	cfg.set_value("settings", "vibration_enabled", vibration_enabled)
	cfg.save(SAVE_PATH)

func try_set_high_score(score: int) -> bool:
	if score > high_score:
		high_score = score
		save_data()
		return true
	return false

func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)
	SFX.set_sfx_volume(sfx_volume)
	save_data()

func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)
	SFX.set_music_volume(music_volume)
	save_data()

func set_control_type(t: String) -> void:
	control_type = t
	save_data()

func set_vibration_enabled(v: bool) -> void:
	vibration_enabled = v
	save_data()
