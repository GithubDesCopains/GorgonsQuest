extends Node

## Generates placeholder sprites with simple shapes and colors
## For prototyping before final art assets

static func create_hero_placeholder() -> Texture2D:
	"""Create a simple hero sprite (circle with direction indicator)"""
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	# Draw circle body (pastel blue for hero)
	draw_circle(img, Vector2(32, 32), 28, Color("87CEEB"))
	# Draw outline
	draw_circle_outline(img, Vector2(32, 32), 28, Color.WHITE, 2)
	# Draw face direction indicator (small circle at bottom)
	draw_circle(img, Vector2(32, 45), 5, Color.WHITE)
	
	return ImageTexture.create_from_image(img)

static func create_ground_tile() -> Texture2D:
	"""Create ground tile (sand/marble)"""
	var img = Image.create(72, 72, false, Image.FORMAT_RGBA8)
	img.fill(Color("F5DEB3"))  # Sand beige
	
	# Add simple border
	draw_rect_outline(img, Rect2(0, 0, 72, 72), Color("E5CE9D"), 2)
	
	return ImageTexture.create_from_image(img)

static func create_water_tile() -> Texture2D:
	"""Create water tile (blue)"""
	var img = Image.create(72, 72, false, Image.FORMAT_RGBA8)
	img.fill(Color("4A90C0"))  # Ocean blue
	
	# Add wave pattern (simple lines)
	for y in range(0, 72, 20):
		draw_line(img, Vector2(0, y + 10), Vector2(72, y + 10), Color("6AA5D0"), 2)
	
	return ImageTexture.create_from_image(img)

static func create_wall_tile() -> Texture2D:
	"""Create wall tile (stone)"""
	var img = Image.create(72, 72, false, Image.FORMAT_RGBA8)
	img.fill(Color("808080"))  # Gray
	
	# Stone block pattern
	draw_rect_outline(img, Rect2(2, 2, 68, 68), Color("606060"), 3)
	draw_rect_outline(img, Rect2(8, 8, 56, 56), Color("A0A0A0"), 2)
	
	return ImageTexture.create_from_image(img)

static func create_pillar_sprite() -> Texture2D:
	"""Create stone pillar"""
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	# Pillar body
	draw_rect(img, Rect2(20, 10, 24, 44), Color("A9A9A9"))
	# Pillar top
	draw_rect(img, Rect2(16, 8, 32, 8), Color("C0C0C0"))
	# Outline
	draw_rect_outline(img, Rect2(20, 10, 24, 44), Color.WHITE, 2)
	
	return ImageTexture.create_from_image(img)

static func create_soul_urn() -> Texture2D:
	"""Create soul urn collectible (golden vase)"""
	var img = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	# Urn body (golden)
	draw_circle(img, Vector2(24, 28), 16, Color("FFD700"))
	# Top neck
	draw_rect(img, Rect2(18, 12, 12, 10), Color("FFC700"))
	# Outline
	draw_circle_outline(img, Vector2(24, 28), 16, Color("FFA500"), 2)
	
	return ImageTexture.create_from_image(img)

# Helper drawing functions
static func draw_circle(img: Image, center: Vector2, radius: float, color: Color):
	for y in range(max(0, int(center.y - radius)), min(img.get_height(), int(center.y + radius + 1))):
		for x in range(max(0, int(center.x - radius)), min(img.get_width(), int(center.x + radius + 1))):
			if Vector2(x, y).distance_to(center) <= radius:
				img.set_pixel(x, y, color)

static func draw_circle_outline(img: Image, center: Vector2, radius: float, color: Color, thickness: int):
	for y in range(max(0, int(center.y - radius - thickness)), min(img.get_height(), int(center.y + radius + thickness + 1))):
		for x in range(max(0, int(center.x - radius - thickness)), min(img.get_width(), int(center.x + radius + thickness + 1))):
			var dist = Vector2(x, y).distance_to(center)
			if dist >= radius - thickness and dist <= radius + thickness:
				img.set_pixel(x, y, color)

static func draw_rect(img: Image, rect: Rect2, color: Color):
	for y in range(max(0, int(rect.position.y)), min(img.get_height(), int(rect.position.y + rect.size.y))):
		for x in range(max(0, int(rect.position.x)), min(img.get_width(), int(rect.position.x + rect.size.x))):
			img.set_pixel(x, y, color)

static func draw_rect_outline(img: Image, rect: Rect2, color: Color, thickness: int):
	# Top and bottom
	for t in range(thickness):
		for x in range(max(0, int(rect.position.x)), min(img.get_width(), int(rect.position.x + rect.size.x))):
			if rect.position.y + t < img.get_height():
				img.set_pixel(x, int(rect.position.y + t), color)
			if rect.position.y + rect.size.y - t - 1 >= 0:
				img.set_pixel(x, int(rect.position.y + rect.size.y - t - 1), color)
	
	# Left and right
	for t in range(thickness):
		for y in range(max(0, int(rect.position.y)), min(img.get_height(), int(rect.position.y + rect.size.y))):
			if rect.position.x + t < img.get_width():
				img.set_pixel(int(rect.position.x + t), y, color)
			if rect.position.x + rect.size.x - t - 1 >= 0:
				img.set_pixel(int(rect.position.x + rect.size.x - t - 1), y, color)

static func draw_line(img: Image, from: Vector2, to: Vector2, color: Color, thickness: int):
	var points = []
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var sx = 1 if from.x < to.x else -1
	var sy = 1 if from.y < to.y else -1
	var err = dx - dy
	var x = from.x
	var y = from.y
	
	while true:
		for ty in range(-thickness/2, thickness/2 + 1):
			for tx in range(-thickness/2, thickness/2 + 1):
				var px = int(x + tx)
				var py = int(y + ty)
				if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
					img.set_pixel(px, py, color)
		
		if x == to.x and y == to.y:
			break
		
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
