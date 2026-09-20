extends Node
## Runtime procedural pixel-art generator.
##
## Every sprite in the game is authored as a small array of text rows (a
## "grid") where each character maps to a colour. This node turns a grid into
## a crisp, nearest-filtered ImageTexture at build time. No binary image
## assets are shipped with the project - everything is generated from code.

var _cache: Dictionary = {}

## grid: Array[String] of equal-length rows.
## palette: Dictionary mapping a single character -> Color. '.' is always transparent.
## key: optional cache key; identical keys skip regeneration.
func make_texture(grid: Array, palette: Dictionary, key: String = "") -> ImageTexture:
	if key != "" and _cache.has(key):
		return _cache[key]

	var height := grid.size()
	var width := 0
	for row in grid:
		width = max(width, (row as String).length())

	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	for y in range(height):
		var row: String = grid[y]
		for x in range(row.length()):
			var ch := row[x]
			if ch == "." or ch == " ":
				continue
			var color: Color = palette.get(ch, Color(1, 0, 1, 1))
			image.set_pixel(x, y, color)

	var texture := ImageTexture.create_from_image(image)
	if key != "":
		_cache[key] = texture
	return texture

## Convenience: builds a Sprite2D configured for crisp pixel-art scaling.
func make_sprite(grid: Array, palette: Dictionary, pixel_scale: float = 2.0, key: String = "") -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = make_texture(grid, palette, key)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.scale = Vector2(pixel_scale, pixel_scale)
	return sprite
