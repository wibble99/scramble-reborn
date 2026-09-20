extends Node2D
class_name TerrainSystem
## Builds the full stage terrain up front from a hand-authored heightmap
## (a list of {x, ceiling, floor} keyframes) and slides it left each frame
## as the world scrolls. A typical stage only has ~100 keyframe intervals,
## so building everything up front (rather than streaming chunks) keeps
## this system simple while staying comfortably within a mobile frame
## budget; offscreen segments are culled from rendering and collision.

const CULL_MARGIN := 420.0

var keyframes: Array = []
var stage_length: float = 0.0
var _segments: Array = []

func build(stage_terrain: Array) -> void:
	clear()
	keyframes = stage_terrain
	if keyframes.is_empty():
		return
	stage_length = keyframes[keyframes.size() - 1].x
	for i in range(keyframes.size() - 1):
		var a: Dictionary = keyframes[i]
		var b: Dictionary = keyframes[i + 1]
		var seg := TerrainSegment.new()
		seg.setup(b.x - a.x, a.ceiling, b.ceiling, a.floor, b.floor)
		add_child(seg)
		_segments.append({"node": seg, "world_x": a.x})

func clear() -> void:
	for entry in _segments:
		entry.node.queue_free()
	_segments.clear()
	keyframes.clear()
	stage_length = 0.0

func update_scroll(scroll_distance: float) -> void:
	for entry in _segments:
		var screen_x: float = entry.world_x - scroll_distance
		entry.node.position.x = screen_x
		var offscreen: bool = screen_x < -CULL_MARGIN or screen_x > CULL_MARGIN + Game.screen_w
		entry.node.visible = not offscreen
		entry.node.monitorable = not offscreen

func ceiling_at(world_x: float) -> float:
	return _interp(world_x, "ceiling")

func floor_at(world_x: float) -> float:
	return _interp(world_x, "floor")

func _interp(world_x: float, field: String) -> float:
	if keyframes.is_empty():
		return 0.0
	var last: int = keyframes.size() - 1
	if world_x <= keyframes[0].x:
		return keyframes[0][field]
	if world_x >= keyframes[last].x:
		return keyframes[last][field]
	for i in range(last):
		var a: Dictionary = keyframes[i]
		var b: Dictionary = keyframes[i + 1]
		if world_x >= a.x and world_x <= b.x:
			var t: float = (world_x - a.x) / (b.x - a.x)
			return lerpf(a[field], b[field], t)
	return keyframes[last][field]
