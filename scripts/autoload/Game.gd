extends Node
## Central game-state hub: score, lives, fuel, stage/loop progression and
## the overall state machine. UI and gameplay systems both talk to this
## singleton instead of each other, which keeps HUD/menus decoupled from
## the player/level implementation.

enum State { TITLE, PLAYING, PAUSED, STAGE_CLEAR, GAME_OVER }

const STARTING_LIVES := 3
const MAX_FUEL := 100.0
const FUEL_DRAIN_PER_SEC := 2.6
const EXTRA_LIFE_STEP := 10000
const GAME_H := 224.0

## Current logical play-field width in game units. Height is always fixed
## at GAME_H (224); width adapts to the real device aspect ratio so the
## game fills the whole screen with no letterboxing - see Main.gd.
var screen_w: float = 256.0

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal fuel_changed(fraction: float)
signal fuel_empty
signal state_changed(new_state: int)
signal stage_changed(stage_index: int, loop_count: int)
signal extra_life_awarded
signal high_score_beaten(new_high_score: int)

var state: int = State.TITLE
var score: int = 0
var lives: int = STARTING_LIVES
var fuel: float = MAX_FUEL
var stage_index: int = 0
var loop_count: int = 0
var _next_extra_life_score: int = EXTRA_LIFE_STEP
var stage_cleared_this_run: int = 0

func difficulty_multiplier() -> float:
	return 1.0 + float(loop_count) * 0.22

func start_new_game() -> void:
	score = 0
	lives = STARTING_LIVES
	fuel = MAX_FUEL
	stage_index = 0
	loop_count = 0
	stage_cleared_this_run = 0
	_next_extra_life_score = EXTRA_LIFE_STEP
	score_changed.emit(score)
	lives_changed.emit(lives)
	fuel_changed.emit(1.0)
	stage_changed.emit(stage_index, loop_count)
	_set_state(State.PLAYING)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	while score >= _next_extra_life_score:
		lives += 1
		_next_extra_life_score += EXTRA_LIFE_STEP
		lives_changed.emit(lives)
		extra_life_awarded.emit()

func lose_life() -> bool:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		_game_over()
		return true
	fuel = MAX_FUEL
	fuel_changed.emit(1.0)
	return false

func consume_fuel(delta: float) -> void:
	if state != State.PLAYING:
		return
	fuel = max(0.0, fuel - FUEL_DRAIN_PER_SEC * delta)
	fuel_changed.emit(fuel / MAX_FUEL)
	if fuel <= 0.0:
		fuel_empty.emit()

func add_fuel(amount: float) -> void:
	fuel = min(MAX_FUEL, fuel + amount)
	fuel_changed.emit(fuel / MAX_FUEL)

func advance_stage() -> void:
	stage_index += 1
	stage_cleared_this_run += 1
	_set_state(State.STAGE_CLEAR)

func begin_next_stage(stage_count: int) -> void:
	if stage_index >= stage_count:
		stage_index = 0
		loop_count += 1
	stage_changed.emit(stage_index, loop_count)
	_set_state(State.PLAYING)

func pause_game() -> void:
	if state == State.PLAYING:
		_set_state(State.PAUSED)

func resume_game() -> void:
	if state == State.PAUSED:
		_set_state(State.PLAYING)

func go_to_title() -> void:
	_set_state(State.TITLE)

func _game_over() -> void:
	_set_state(State.GAME_OVER)
	if Save.try_set_high_score(score):
		high_score_beaten.emit(score)

func _set_state(new_state: int) -> void:
	state = new_state
	state_changed.emit(state)
