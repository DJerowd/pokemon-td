extends Node2D

const SPRITE_FACTORY = preload("res://scripts/data/SpriteFrameFactory.gd")
const SPRITE_SHEET_PATH := "res://assets/textures/DS _ DSi - Pokemon Black 2 _ White 2 - Overworld - Pokemon (Overworld).png"

enum Direction { DOWN = 0, UP = 1, LEFT = 2, RIGHT = 3 }

@export var pokemon_data: PokemonData:
	set(value):
		pokemon_data = value
		if value == null:
			return
		damage = maxf(1.0, value.attack) * (1.0 + maxf(0, value.level - 1) * 0.05)
		attack_cooldown = 1.0 / maxf(0.1, value.attack_speed)
		current_move = value.get_active_move()
		if is_node_ready():
			_apply_stats()
			update_sprite_texture()

var slot_reference: Area2D = null
var damage: float = 20.0
var attack_cooldown: float = 1.0
var current_move: String = "Investida"
var is_selected: bool = false
var current_direction: Direction = Direction.DOWN
var anim_frame: int = 0
var anim_timer: float = 0.0
@export var anim_speed: float = 0.22
@export var sprite_display_size: float = 48.0

var enemies_in_range: Array = []
var sprite_sheet: Texture2D
var invalid_sprite_warning_shown: bool = false
var current_hp: float = 1.0
var max_hp: float = 1.0
var status_attack_timer: float = 0.0
@onready var attack_timer: Timer = $Timer
@onready var range_area: Area2D = $Area2D
@onready var click_area: Area2D = $ClickArea
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("towers")
	max_hp = maxf(1.0, pokemon_data.hp) if pokemon_data else 1.0
	current_hp = clampf(pokemon_data.current_hp if pokemon_data and pokemon_data.current_hp > 0.0 else max_hp, 1.0, max_hp)
	if pokemon_data:
		pokemon_data.current_hp = current_hp
	sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	if sprite:
		sprite.centered = true
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_stats()
	if attack_timer:
		attack_timer.one_shot = false
		if not attack_timer.timeout.is_connected(_on_attack_timeout):
			attack_timer.timeout.connect(_on_attack_timeout)
		attack_timer.wait_time = attack_cooldown
		attack_timer.start()
	if range_area:
		if not range_area.body_entered.is_connected(_on_enemy_entered):
			range_area.body_entered.connect(_on_enemy_entered)
		if not range_area.body_exited.is_connected(_on_enemy_exited):
			range_area.body_exited.connect(_on_enemy_exited)
	if click_area and not click_area.input_event.is_connected(_on_click_area_input_event):
		click_area.input_event.connect(_on_click_area_input_event)
	update_sprite_texture()

func _apply_stats() -> void:
	if attack_timer:
		attack_timer.wait_time = attack_cooldown
	if range_area and pokemon_data:
		var shape_node := range_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is CircleShape2D:
			shape_node.shape = shape_node.shape.duplicate()
			(shape_node.shape as CircleShape2D).radius = pokemon_data.attack_range

func _process(delta: float) -> void:
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_queued_for_deletion())
	# A animação precisa continuar mesmo sem inimigos no alcance.
	if not enemies_in_range.is_empty():
		var target := enemies_in_range[0] as Node2D
		if target:
			var direction_vector: Vector2 = target.global_position - global_position
			if absf(direction_vector.x) > absf(direction_vector.y):
				set_direction(Direction.LEFT if direction_vector.x < 0.0 else Direction.RIGHT)
			else:
				set_direction(Direction.UP if direction_vector.y < 0.0 else Direction.DOWN)
	anim_timer += delta
	if anim_timer >= maxf(0.05, anim_speed):
		anim_timer = fmod(anim_timer, maxf(0.05, anim_speed))
		anim_frame = (anim_frame + 1) % 2
		update_sprite_texture()

func set_direction(new_direction: Direction) -> void:
	if current_direction != new_direction:
		current_direction = new_direction
		anim_frame = 0
		update_sprite_texture()

func update_sprite_texture() -> void:
	if not pokemon_data or not sprite or sprite_sheet == null:
		return
	var frame_size := pokemon_data.frame_size
	if frame_size.x <= 0.0 or frame_size.y <= 0.0:
		frame_size = Vector2(32, 32)
	var frame_rect := pokemon_data.get_frame_region(int(current_direction), anim_frame)
	if frame_rect.position.x < 0.0 or frame_rect.position.y < 0.0 or frame_rect.end.x > sprite_sheet.get_width() or frame_rect.end.y > sprite_sheet.get_height():
		if not invalid_sprite_warning_shown:
			push_warning("Sprite fora dos limites para %s; confira sprite_origin/frame_size." % pokemon_data.species_name)
			invalid_sprite_warning_shown = true
		return
	var texture := SPRITE_FACTORY.make_frame(sprite_sheet, frame_rect)
	if texture == null:
		return
	sprite.texture = texture
	# Cada frame continua com o mesmo canvas-base. A escala é calculada para
	# que espécies de desenhos diferentes tenham dimensões visuais consistentes.
	var largest_dimension := maxf(frame_size.x, frame_size.y)
	var scale_factor := sprite_display_size / maxf(1.0, largest_dimension)
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.flip_h = false

func take_damage(amount: float, inflicted_status: String = "") -> void:
	if amount <= 0.0 or not is_inside_tree():
		return
	current_hp = maxf(0.0, current_hp - amount)
	if pokemon_data:
		pokemon_data.current_hp = current_hp
		if not inflicted_status.is_empty():
			pokemon_data.status_condition = inflicted_status
	if current_hp <= 0.0:
		if GameManager.selected_battle_pokemon == pokemon_data:
			GameManager.selected_battle_pokemon = null
		queue_free()
	else:
		GameManager.stats_changed.emit()

func heal(amount: float) -> bool:
	if amount <= 0.0 or current_hp >= max_hp:
		return false
	current_hp = minf(max_hp, current_hp + amount)
	if pokemon_data:
		pokemon_data.current_hp = current_hp
	GameManager.stats_changed.emit()
	return true

func _draw() -> void:
	if is_selected and pokemon_data:
		var radius := pokemon_data.attack_range
		draw_circle(Vector2.ZERO, radius, Color(0.2, 0.8, 1.0, 0.12))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(0.102, 0.902, 1.0, 0.8), 2.0)

func _on_enemy_entered(body: Node2D) -> void:
	var enemy := body.get_parent() as Node2D
	if enemy and enemy.is_in_group("enemies") and not enemies_in_range.has(enemy):
		enemies_in_range.append(enemy)

func _on_enemy_exited(body: Node2D) -> void:
	var enemy := body.get_parent() as Node2D
	enemies_in_range.erase(enemy)

func _on_attack_timeout() -> void:
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_queued_for_deletion())
	if enemies_in_range.is_empty():
		return
	var target: Variant = enemies_in_range[0]
	if target != null and is_instance_valid(target) and target.has_method("take_damage"):
		current_move = pokemon_data.get_active_move() if pokemon_data else "Investida"
		target.call("take_damage", damage)

func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = true
		GameManager.selected_battle_pokemon = pokemon_data
		GameManager.stats_changed.emit()
		queue_redraw()
		open_tower_inspector()
		get_viewport().set_input_as_handled()

func open_tower_inspector() -> void:
	if pokemon_data == null:
		return
	var inspector_scene := load("res://scenes/ui/TowerInspectorMenu.tscn") as PackedScene
	if inspector_scene == null:
		push_warning("Cena TowerInspectorMenu.tscn não encontrada.")
		return
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	var ui_layer := current_scene.find_child("UI", true, false) as CanvasLayer
	if ui_layer == null:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "TowerInspectorLayer"
		current_scene.add_child(ui_layer)
	for child in ui_layer.get_children():
		if child is Control and child.get_script() == load("res://scenes/ui/TowerInspectorMenu.gd"):
			child.queue_free()
	var menu := inspector_scene.instantiate() as Control
	menu.set("target_pokemon", pokemon_data)
	menu.set("target_tower", self)
	menu.z_index = 100
	ui_layer.add_child(menu)

func _exit_tree() -> void:
	if pokemon_data:
		GameManager.undeploy_pokemon(pokemon_data)
	if slot_reference and is_instance_valid(slot_reference):
		slot_reference.occupied = false
		slot_reference.current_tower = null
