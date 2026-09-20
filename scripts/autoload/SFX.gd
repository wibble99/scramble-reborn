extends Node
## Procedural arcade sound effects and music.
##
## Every sound is synthesised at startup as raw 16-bit PCM (square waves,
## simple noise bursts and linear envelopes) so the project ships with zero
## binary audio assets. This keeps the audio period-appropriate - short,
## punchy, single-oscillator "beeps" rather than sampled or synthesized
## modern sound design.

const SAMPLE_RATE := 22050
const POOL_SIZE := 10

var _sfx_players: Array = []
var _next_player_index := 0
var _music_player: AudioStreamPlayer
var _clips: Dictionary = {}
var _music_stream: AudioStreamWAV

var sfx_volume: float = 1.0
var music_volume: float = 0.6

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_clips()
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)
	_music_player.stream = _music_stream
	_music_player.volume_db = linear_to_db(max(music_volume, 0.001))

func play(clip_name: String, pitch: float = 1.0) -> void:
	if not _clips.has(clip_name):
		return
	var player: AudioStreamPlayer = _sfx_players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _sfx_players.size()
	player.stream = _clips[clip_name]
	player.pitch_scale = pitch
	player.volume_db = linear_to_db(max(sfx_volume, 0.001))
	player.play()

func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)

func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)
	if _music_player:
		_music_player.volume_db = linear_to_db(max(music_volume, 0.001))

func start_music() -> void:
	if _music_player and not _music_player.playing:
		_music_player.play()

func stop_music() -> void:
	if _music_player:
		_music_player.stop()

# ---------------------------------------------------------------------------
# Synthesis
# ---------------------------------------------------------------------------

func _build_clips() -> void:
	_clips["fire"] = _build_wave(0.09, func(t: float, dur: float):
		var f := lerpf(1300.0, 650.0, t / dur)
		var env := 1.0 - (t / dur)
		return _square(f, t) * env
	)

	_clips["bomb"] = _build_wave(0.22, func(t: float, dur: float):
		var f := lerpf(520.0, 120.0, t / dur)
		var env := 1.0 - (t / dur)
		return _square(f, t) * env * 0.8
	)

	_clips["explosion"] = _build_wave(0.45, func(t: float, dur: float):
		var env := pow(1.0 - (t / dur), 1.6)
		var bass := _square(70.0, t) * 0.5
		var noise := (randf() * 2.0 - 1.0) * 0.7
		return (bass + noise) * env
	)

	_clips["enemy_destroy"] = _build_wave(0.28, func(t: float, dur: float):
		var env := pow(1.0 - (t / dur), 1.4)
		var f := lerpf(900.0, 90.0, t / dur)
		var noise := (randf() * 2.0 - 1.0) * 0.5
		return (_square(f, t) * 0.6 + noise) * env
	)

	_clips["fuel_pickup"] = _build_wave(0.27, func(t: float, dur: float):
		var seg := dur / 3.0
		var step := int(clampf(t / seg, 0.0, 2.999))
		var freqs := [660.0, 880.0, 1320.0]
		var f: float = freqs[step]
		var local_t := fmod(t, seg)
		var env := 1.0 - local_t / seg
		return _square(f, t) * env * 0.7
	)

	_clips["player_death"] = _build_wave(0.8, func(t: float, dur: float):
		var env := pow(1.0 - (t / dur), 1.2)
		var f := lerpf(500.0, 40.0, t / dur)
		var noise := (randf() * 2.0 - 1.0) * 0.6
		return (_square(f, t) * 0.5 + noise) * env
	)

	_clips["warning"] = _build_wave(0.12, func(t: float, dur: float):
		var env := 1.0 - (t / dur) * 0.3
		return _square(920.0, t) * env * 0.8
	)

	_clips["game_start"] = _build_wave(0.65, func(t: float, dur: float):
		var notes := [440.0, 554.0, 659.0, 880.0]
		var seg := dur / notes.size()
		var step := int(clampf(t / seg, 0.0, float(notes.size()) - 0.001))
		var f: float = notes[step]
		var local_t := fmod(t, seg)
		var env := 1.0 - local_t / seg
		return _square(f, t) * env * 0.7
	)

	_clips["game_over"] = _build_wave(1.1, func(t: float, dur: float):
		var notes := [523.0, 466.0, 392.0, 261.0]
		var seg := dur / notes.size()
		var step := int(clampf(t / seg, 0.0, float(notes.size()) - 0.001))
		var f: float = notes[step]
		var local_t := fmod(t, seg)
		var env := 1.0 - local_t / seg
		return _square(f, t) * env * 0.75
	)

	_clips["extra_life"] = _build_wave(0.4, func(t: float, dur: float):
		var notes := [660.0, 880.0, 1100.0, 1320.0]
		var seg := dur / notes.size()
		var step := int(clampf(t / seg, 0.0, float(notes.size()) - 0.001))
		var f: float = notes[step]
		var local_t := fmod(t, seg)
		var env := 1.0 - local_t / seg
		return _square(f, t) * env * 0.7
	)

	_music_stream = _build_music_loop()

func _square(freq: float, t: float) -> float:
	var phase := fmod(t * freq, 1.0)
	return 1.0 if phase < 0.5 else -1.0

func _build_wave(duration: float, gen: Callable) -> AudioStreamWAV:
	var total_frames := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_frames * 2)
	for i in range(total_frames):
		var t := float(i) / SAMPLE_RATE
		var sample: float = clampf(gen.call(t, duration), -1.0, 1.0)
		var sample_i := int(sample * 32767.0)
		bytes.encode_s16(i * 2, sample_i)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream

func _build_music_loop() -> AudioStreamWAV:
	# A short, deterministic square-wave bass riff that loops seamlessly -
	# minimal arcade-style background music rather than a modern score.
	var bpm := 132.0
	var beat := 60.0 / bpm
	var pattern := [110.0, 110.0, 146.6, 110.0, 130.8, 110.0, 98.0, 110.0]
	var note_dur := beat * 0.5
	var duration := note_dur * pattern.size()
	var total_frames := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_frames * 2)
	for i in range(total_frames):
		var t := float(i) / SAMPLE_RATE
		var step := int(t / note_dur) % pattern.size()
		var freq: float = pattern[step]
		var local_t := fmod(t, note_dur)
		var env := 1.0 - (local_t / note_dur) * 0.85
		var sample := _square(freq, t) * env * 0.35
		var sample_i := int(clampf(sample, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample_i)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total_frames
	return stream
