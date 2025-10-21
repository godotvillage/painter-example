class_name PaintLayer
extends TextureRect

var image : Image = null

var is_active: bool = true

var brush_r = 5
var brush_color : Color = Color(0,0,0, 1)

var drawing: bool = false

func _ready() -> void:
	image = Image.create_empty(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	image.fill(Color(1,1,1,1))
	texture = ImageTexture.create_from_image(image)

func _gui_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
			if drawing:
				paint_circle(get_local_mouse_position(), brush_r, brush_color)
	if event is InputEventMouseMotion and drawing:
		paint_circle(get_local_mouse_position(), brush_r, brush_color)

func paint_circle(layer_pos: Vector2i, r: float, color: Color):
	if r <= 0:
		return

	for x in range(max(0, int(layer_pos.x - r)), min(image.get_width() - 1, int(layer_pos.x + r)) + 1):
		for y in range(max(0, int(layer_pos.y - r)), min(image.get_height() - 1, int(layer_pos.y + r)) + 1):
			if Vector2(x, y).distance_squared_to(layer_pos) < pow(r, 2):
				image.set_pixelv(Vector2i(x, y), color)

	texture.update(image)
