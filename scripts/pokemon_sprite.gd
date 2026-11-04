extends Sprite2D
## Flood only the edge-connected backdrop, preserving white eyes/highlights.
@export var pokemon: String = "pikachu"

func _ready() -> void:
	var image: Image = load("res://assets/sprites/%s.png" % pokemon).get_image()
	image.convert(Image.FORMAT_RGBA8)
	var background := image.get_pixel(0, 0)
	var pending: Array[Vector2i] = []
	var size := image.get_size()
	for x in size.x:
		pending.append(Vector2i(x, 0))
		pending.append(Vector2i(x, size.y - 1))
	for y in size.y:
		pending.append(Vector2i(0, y))
		pending.append(Vector2i(size.x - 1, y))
	while not pending.is_empty():
		var p: Vector2i = pending.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= size.x or p.y >= size.y:
			continue
		if image.get_pixelv(p) != background:
			continue
		image.set_pixelv(p, Color.TRANSPARENT)
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			pending.append(p + step)
	texture = ImageTexture.create_from_image(image)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
