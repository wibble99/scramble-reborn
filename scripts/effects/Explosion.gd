extends Node2D
class_name Explosion
## A small burst of expanding, fading pixel chunks - deliberately blocky and
## hand-drawn rather than a smooth modern particle system, to match the
## look of late-1970s arcade hardware.

var _life: float = 0.0
var _duration: float = 0.0
var _chunks: Array = []

func activate(pos: Vector2, big: bool = false) -> void:
	position = pos
	z_index = 50
	_life = 0.0
	_duration = 0.75 if big else 0.4
	_chunks.clear()
	var count := 16 if big else 9
	for i in range(count):
		var angle := randf() * TAU
		var speed := randf_range(24.0, 80.0) * (1.5 if big else 1.0)
		_chunks.append({
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"pos": Vector2.ZERO,
			"size": randf_range(1.5, 3.5) * (1.6 if big else 1.0),
		})
	queue_redraw()

func _process(delta: float) -> void:
	_life += delta
	for chunk in _chunks:
		chunk.pos += chunk.vel * delta
	queue_redraw()

func is_done() -> bool:
	return _life >= _duration

func _draw() -> void:
	if _duration <= 0.0 or _life >= _duration:
		return
	var t := _life / _duration
	var color := _color_for(t)
	for chunk in _chunks:
		var s: float = chunk.size * (1.0 - t * 0.5)
		if s <= 0.1:
			continue
		draw_rect(Rect2(chunk.pos - Vector2(s, s) * 0.5, Vector2(s, s)), color)

func _color_for(t: float) -> Color:
	if t < 0.25:
		return Palette.EXPLOSION_1
	elif t < 0.55:
		return Palette.EXPLOSION_2
	else:
		var fade_t: float = (t - 0.55) / 0.45
		return Color(Palette.EXPLOSION_3.r, Palette.EXPLOSION_3.g, Palette.EXPLOSION_3.b, 1.0 - fade_t)
