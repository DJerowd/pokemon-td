extends Node2D

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
			queue_redraw()

var slot_reference: Area2D = null
var damage: float = 20.0
var attack_cooldown: float = 1.0
var current_move: String = "Investida"
var is_selected: bool = false
var current_direction: Direction = Direction.DOWN
var anim_frame: int = 0
var anim_timer: float = 0.0
@export var anim_speed: float = 0.25

var enemies_in_range: Array = []
@onready var attack_timer: Timer = $Timer
@onready var range_area: Area2D = $Area2D
@onready var click_area: Area2D = $ClickArea
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Use the sprite resource assigned in PokemonData. Do not load a hard-coded
	# file path: a missing optional sprite should not break combat logic.
	if sprite and pokemon_data and pokemon_data.sprite:
		sprite.texture = pokemon_data.sprite
	_apply_stats()

	if attack_timer:
		attack_timer.one_shot = false
		if not attack_timer.timeout.is_connected(_on_attack_timeout):
			attack_timer.timeout.connect(_on_attack_timeout)
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
	# CollisionShape2D for the range should be a CircleShape2D; its radius
	# follows the same data value used by the visible range indicator.
	if range_area:
		var shape_node := range_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is CircleShape2D and pokemon_data:
			shape_node.shape = shape_node.shape.duplicate()
			(shape_node.shape as CircleShape2D).radius = pokemon_data.attack_range

func _process(delta: float) -> void:
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_queued_for_deletion())
	if enemies_in_range.is_empty():
		return
	var target := enemies_in_range[0] as Node2D
	var direction_vector: Vector2 = target.global_position - global_position
	if absf(direction_vector.x) > absf(direction_vector.y):
		set_direction(Direction.LEFT if direction_vector.x < 0.0 else Direction.RIGHT)
	else:
		set_direction(Direction.UP if direction_vector.y < 0.0 else Direction.DOWN)
	anim_timer += delta
	if anim_timer >= anim_speed:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % 2
		update_sprite_texture()

func set_direction(new_direction: Direction) -> void:
	if current_direction != new_direction:
		current_direction = new_direction
		update_sprite_texture()

func update_sprite_texture() -> void:
	if not pokemon_data or not sprite:
		return
	# Atlas cropping is only possible when a texture and frame coordinates exist.
	if pokemon_data.sprite != null and sprite.texture != pokemon_data.sprite:
		sprite.texture = pokemon_data.sprite
	if sprite.texture is AtlasTexture:
		var atlas := sprite.texture as AtlasTexture
		var row := int(current_direction)
		if current_direction == Direction.RIGHT:
			row = int(Direction.LEFT)
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		atlas.region = pokemon_data.get_frame_region(row, anim_frame)

func _draw() -> void:
	if is_selected and pokemon_data:
		var radius := pokemon_data.attack_range
		draw_circle(Vector2.ZERO, radius, Color(0.2, 0.8, 1.0, 0.12))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(0.102, 0.902, 1.0, 0.8), 2.0)

func _on_enemy_entered(body: Node2D) -> void:
	# The Area2D usually detects the enemy's CharacterBody2D child.
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
	var target := enemies_in_range[0]
	if target.has_method("take_damage"):
		current_move = pokemon_data.get_active_move() if pokemon_data else "Investida"
		target.take_damage(damage)
		print("%s usou %s e causou %.1f de dano." % [pokemon_data.species_name if pokemon_data else "Torre", current_move, damage])

func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = true
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
	# Prevent opening several inspectors for one tower.
	for child in get_tree().current_scene.get_children():
		if child is Control and child.get_script() == load("res://scenes/ui/TowerInspectorMenu.gd"):
			if child.get("target_tower") == self:
				child.queue_free()
	var menu = inspector_scene.instantiate()
	menu.target_pokemon = pokemon_data
	menu.target_tower = self
	get_tree().current_scene.add_child(menu)

func _exit_tree() -> void:
	if pokemon_data:
		GameManager.undeploy_pokemon(pokemon_data)
	if slot_reference and is_instance_valid(slot_reference):
		slot_reference.occupied = false
		slot_reference.current_tower = null
