class_name SpriteFrameFactory
extends RefCounted

## Extrai um frame de uma spritesheet, remove a cor sólida do fundo e
## recorta margens transparentes para normalizar o tamanho visual.
static var _cache: Dictionary = {}

static func make_frame(sheet: Texture2D, rect: Rect2) -> Texture2D:
	if sheet == null:
		return null
	var key := "%s:%d:%d:%d:%d" % [sheet.get_instance_id(), int(rect.position.x), int(rect.position.y), int(rect.size.x), int(rect.size.y)]
	if _cache.has(key):
		return _cache[key] as Texture2D
	var source := sheet.get_image()
	if source == null or source.is_empty():
		return null
	var frame_rect := Rect2i(Vector2i(rect.position), Vector2i(rect.size))
	var bounds := Rect2i(Vector2i.ZERO, source.get_size())
	if frame_rect.size.x <= 0 or frame_rect.size.y <= 0 or not bounds.encloses(frame_rect):
		return null
	var frame := source.get_region(frame_rect)
	frame.convert(Image.FORMAT_RGBA8)
	_remove_solid_corner_background(frame)
	var alpha_bounds := _find_alpha_bounds(frame)
	if alpha_bounds.size.x <= 0 or alpha_bounds.size.y <= 0:
		return null
	if alpha_bounds != Rect2i(Vector2i.ZERO, frame.get_size()):
		frame = frame.get_region(alpha_bounds)
	var texture := ImageTexture.create_from_image(frame)
	_cache[key] = texture
	return texture

static func _remove_solid_corner_background(frame: Image) -> void:
	var w := frame.get_width()
	var h := frame.get_height()
	if w < 2 or h < 2:
		return
	var points := [Vector2i(0, 0), Vector2i(w - 1, 0), Vector2i(0, h - 1), Vector2i(w - 1, h - 1)]
	var colors: Array[Color] = []
	for point in points:
		colors.append(frame.get_pixelv(point))
	var key_color := colors[0]
	var best_count := 0
	for candidate in colors:
		var count := 0
		for color in colors:
			if color.distance_to(candidate) < 0.08:
				count += 1
		if count > best_count:
			best_count = count
			key_color = candidate
	# Só aplica chroma key se pelo menos dois cantos confirmarem um fundo comum.
	if best_count < 2 or key_color.a < 0.95:
		return
	for y in range(h):
		for x in range(w):
			var pixel := frame.get_pixel(x, y)
			if pixel.a > 0.95 and pixel.distance_to(key_color) < 0.12:
				pixel.a = 0.0
				frame.set_pixel(x, y, pixel)

static func _find_alpha_bounds(frame: Image) -> Rect2i:
	var min_x := frame.get_width()
	var min_y := frame.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(frame.get_height()):
		for x in range(frame.get_width()):
			if frame.get_pixel(x, y).a > 0.05:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
