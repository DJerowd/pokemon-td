extends Camera2D

@export var pan_speed: float = 600.0
@export_range(0.2, 2.0, 0.1) var min_zoom: float = 0.8
@export_range(0.2, 3.0, 0.1) var max_zoom: float = 1.5

var dragging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# Botão do meio ou direito inicia/encerra o arrasto.
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
			dragging = event.pressed
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(0.1)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(-0.1)
	elif event is InputEventMouseMotion and dragging:
		# Dividir pelo zoom mantém a velocidade de arrasto consistente na tela.
		position -= event.relative / zoom

func _change_zoom(amount: float) -> void:
	var target := clampf(zoom.x + amount, min_zoom, max_zoom)
	zoom = Vector2.ONE * target

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if direction != Vector2.ZERO:
		position += direction.normalized() * pan_speed * delta
