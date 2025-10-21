class_name PaintLayer
extends TextureRect

# 图层的图像数据
var image : Image = null

# 当前图层是否激活（可绘制）
var is_active: bool = true

# 画笔半径
var brush_r = 5
# 画笔颜色
var brush_color : Color = Color(0,0,0, 0.1)

# 是否正在绘制中
var drawing: bool = false

# 存储上一个鼠标位置，用于绘制连续线条
var last_mouse_pos: Vector2i = Vector2i.ZERO

func _ready() -> void:
	# 创建一个空白图像，大小与TextureRect相同
	image = Image.create_empty(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	# 用白色填充图像
	image.fill(Color(1,1,1,1))
	# 将图像转换为纹理并赋值给TextureRect
	texture = ImageTexture.create_from_image(image)

func _gui_input(event: InputEvent) -> void:
	# 如果图层未激活，不处理输入
	if not is_active:
		return
	# 处理鼠标按钮事件
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 左键按下时开始绘制，松开时停止绘制
			drawing = event.pressed
			if drawing:
				# 按下时在鼠标位置绘制一个圆，并记录位置
				var current_pos = get_local_mouse_position()
				last_mouse_pos = Vector2i(current_pos.x, current_pos.y)
				paint_circle(last_mouse_pos, brush_r, brush_color)
			else:
				# 松开鼠标时重置上一个位置
				last_mouse_pos = Vector2i.ZERO
	# 处理鼠标移动事件
	if event is InputEventMouseMotion and drawing:
		var current_pos = get_local_mouse_position()
		var current_pos_i = Vector2i(current_pos.x, current_pos.y)

		# 如果这是第一次移动，直接绘制
		if last_mouse_pos == Vector2i.ZERO:
			paint_circle(current_pos_i, brush_r, brush_color)
		else:
			# 在两个位置之间绘制连续的线条，避免出现断点
			draw_line_between(last_mouse_pos, current_pos_i, brush_r, brush_color)

		# 更新上一个鼠标位置
		last_mouse_pos = current_pos_i

func paint_circle(layer_pos: Vector2i, r: float, color: Color):
	# 半径小于等于0时不绘制
	if r <= 0:
		return

	# 遍历圆形范围内的所有像素点
	for x in range(max(0, int(layer_pos.x - r)), min(image.get_width() - 1, int(layer_pos.x + r)) + 1):
		for y in range(max(0, int(layer_pos.y - r)), min(image.get_height() - 1, int(layer_pos.y + r)) + 1):
			# 判断当前像素是否在圆形范围内（使用距离平方判断）
			if Vector2(x, y).distance_squared_to(layer_pos) < pow(r, 2):
				# 将该像素设置为指定颜色
				image.set_pixelv(Vector2i(x, y), color)

	# 更新纹理以显示新绘制的内容
	texture.update(image)

# 在两个点之间绘制连续的线条，防止快速移动鼠标时出现断续的笔画
func draw_line_between(from: Vector2, to: Vector2, r: float, color: Color):
	var distance = from.distance_to(to)

	# 如果两点距离很小，直接绘制终点即可
	if distance <= 1:
		paint_circle(to, r, color)
		return

	# 计算需要插值的步数（基于距离和画笔半径，确保圆形之间有重叠）
	var steps = max(2, int(distance / (r * 0.5)))

	# 在起点和终点之间进行线性插值，绘制一系列圆形形成连续线条
	for i in range(steps + 1):
		var t = float(i) / steps
		var interpolated_pos = from.lerp(to, t)
		paint_circle(Vector2i(interpolated_pos.x, interpolated_pos.y), r, color)
