extends Node
## Top-level orchestrator. Gameplay (terrain/player/enemies) and every
## "arcade screen" (title, HUD, pause, game over, settings) render inside a
## SubViewport that fills the real screen exactly - no letterboxing. Height
## is fixed at Game.GAME_H (224, preserving the terrain's authored vertical
## proportions); width tracks the device's actual aspect ratio each resize
## (Game.screen_w), so a wider phone simply reveals more of the play field
## instead of shrinking into a fixed-aspect box.
##
## TouchControls is the one exception: it lives OUTSIDE the sub-view, as a
## direct child of Main, positioned using the *actual* screen size in real
## pixels, so the joystick/fire/bomb buttons are always in the reachable
## corners of the phone regardless of the game's internal resolution.

var game_viewport: SubViewport
var game_container: SubViewportContainer

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

	var display_layer := CanvasLayer.new()
	display_layer.layer = 0
	add_child(display_layer)

	game_viewport = SubViewport.new()
	game_viewport.size = Vector2i(int(Game.screen_w), int(Game.GAME_H))
	game_viewport.transparent_bg = false
	game_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	game_viewport.handle_input_locally = false
	game_viewport.snap_2d_transforms_to_pixel = true
	game_viewport.snap_2d_vertices_to_pixel = true

	# stretch=false here deliberately: with stretch=true, SubViewportContainer
	# forces SubViewport.size to always equal its own size and silently
	# rejects manual resizing, which defeats the whole point of a fixed
	# low-res internal canvas. Instead the sub-viewport renders at its
	# native (small) resolution and the CONTAINER itself is scaled up as a
	# plain node transform in _update_game_resolution() below.
	game_container = SubViewportContainer.new()
	game_container.stretch = false
	game_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	game_container.mouse_filter = Control.MOUSE_FILTER_PASS
	display_layer.add_child(game_container)
	game_container.add_child(game_viewport)

	title_screen = TitleScreen.new()
	game_viewport.add_child(title_screen)

	hud = HUD.new()
	game_viewport.add_child(hud)

	pause_menu = PauseMenu.new()
	game_viewport.add_child(pause_menu)

	game_over_screen = GameOverScreen.new()
	game_viewport.add_child(game_over_screen)

	settings_screen = SettingsScreen.new()
	game_viewport.add_child(settings_screen)
	title_screen.settings_requested.connect(settings_screen.open)

	stage_banner = StageBanner.new()
	game_viewport.add_child(stage_banner)

	touch_controls = TouchControls.new()
	add_child(touch_controls)

	Game.state_changed.connect(_on_state_changed)
	Game.extra_life_awarded.connect(func(): SFX.play("extra_life"))

	get_viewport().size_changed.connect(_update_game_resolution)
	call_deferred("_update_game_resolution")

	set_process(true)

func _update_game_resolution() -> void:
	var real_size: Vector2 = Vector2(get_viewport().get_visible_rect().size)
	if real_size.x <= 0.0 or real_size.y <= 0.0:
		return
	var aspect: float = real_size.x / real_size.y
	var w: float = roundf(Game.GAME_H * aspect)
	w = maxf(w, 64.0)
	Game.screen_w = w

	game_viewport.size = Vector2i(int(w), int(Game.GAME_H))
	game_container.size = Vector2(w, Game.GAME_H)
	var k: float = real_size.y / Game.GAME_H
	game_container.scale = Vector2(k, k)
	game_container.position = Vector2.ZERO

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
	game_viewport.add_child(world)
	game_viewport.move_child(world, 0)

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
