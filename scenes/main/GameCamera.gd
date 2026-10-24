extends Camera2D

@export var pan_speed: float = 600.0
@export var min_zoom: float = 0.8
@export var max_zoom: float = 1.5

var dragging: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# Movimento por clique e arrasto (Botão do Meio ou Direito do mouse)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			drag_start_mouse_pos = event.global_position
			
	elif event is InputEventMouseMotion and dragging:
		# Desloca a câmera inversamente ao movimento do mouse
		position -= event.relative / zoom

	# Zoom com a roda do mouse
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = clamp(zoom + Vector2(0.1, 0.1), Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clamp(zoom - Vector2(0.1, 0.1), Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _process(delta: float) -> void:
	# Movimento alternativo pelas setas do teclado ou WASD
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D): input_dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_D) == false and Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W): input_dir.y -= 1
	
	if input_dir != Vector2.ZERO:
		position += input_dir.normalized() * pan_speed * delta
