extends Node2D
## Top-level orchestrator: owns the persistent UI layers and builds/tears
## down the gameplay "world" (terrain + player + level manager) as the
## game moves through Game.State. Kept deliberately thin - all the actual
## rules live in the systems it wires together.

var world: Node2D = null
var level_manager: LevelManager = null
var player: Player = null

var title_screen: TitleScreen
var hud: HUD
var touch_controls: TouchControls
var pause_menu: PauseMenu
var game_over_screen: GameOverScreen
var settings_screen: SettingsScreen
var stage_banner: StageBanner

func _ready() -> void:
	randomize()
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	title_screen = TitleScreen.new()
	add_child(title_screen)

	hud = HUD.new()
	add_child(hud)

	touch_controls = TouchControls.new()
	add_child(touch_controls)

	pause_menu = PauseMenu.new()
	add_child(pause_menu)

	game_over_screen = GameOverScreen.new()
	add_child(game_over_screen)

	settings_screen = SettingsScreen.new()
	add_child(settings_screen)
	title_screen.settings_requested.connect(settings_screen.open)

	stage_banner = StageBanner.new()
	add_child(stage_banner)

	Game.state_changed.connect(_on_state_changed)
	Game.extra_life_awarded.connect(func(): SFX.play("extra_life"))
	set_process(true)

func _process(_delta: float) -> void:
	if Controls.pause_just_pressed:
		if Game.state == Game.State.PLAYING:
			Game.pause_game()
		elif Game.state == Game.State.PAUSED:
			Game.resume_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if Game.state == Game.State.PLAYING:
			Game.pause_game()
		elif Game.state == Game.State.PAUSED:
			Game.resume_game()
		elif Game.state == Game.State.TITLE:
			get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if Game.state == Game.State.PLAYING:
			Game.pause_game()

func _on_state_changed(new_state: int) -> void:
	get_tree().paused = (new_state == Game.State.PAUSED)
	match new_state:
		Game.State.PLAYING:
			if world == null:
				_build_world()
		Game.State.STAGE_CLEAR:
			_handle_stage_clear()
		Game.State.TITLE:
			_teardown_world()
		_:
			pass

func _build_world() -> void:
	world = Node2D.new()
	add_child(world)

	level_manager = LevelManager.new()
	world.add_child(level_manager)

	player = Player.new()
	world.add_child(player)
	player.level = level_manager
	level_manager.player = player
	player.died.connect(_on_player_died)

	level_manager.load_stage(Stages.get_stage_data(Game.stage_index))

func _teardown_world() -> void:
	if world:
		world.queue_free()
	world = null
	level_manager = null
	player = null

func _on_player_died() -> void:
	var is_game_over: bool = Game.lose_life()
	if is_game_over:
		SFX.play("game_over")
		return
	await get_tree().create_timer(1.2).timeout
	if player and is_instance_valid(player):
		player.reset_for_new_life()

func _handle_stage_clear() -> void:
	stage_banner.show_text("STAGE %d CLEAR" % Game.stage_index)
	SFX.play("extra_life")
	await get_tree().create_timer(2.0).timeout

	Game.begin_next_stage(Stages.STAGE_COUNT)
	if level_manager:
		level_manager.load_stage(Stages.get_stage_data(Game.stage_index))
	if player and is_instance_valid(player):
		player.reset_for_new_life()
