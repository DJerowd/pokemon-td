extends PathFollow2D

const SPRITE_SHEET_PATH := "res://assets/textures/DS _ DSi - Pokemon Black 2 _ White 2 - Overworld - Pokemon (Overworld).png"
const SPRITE_FACTORY = preload("res://scripts/data/SpriteFrameFactory.gd")

@export var max_hp: float = 50.0
@export var speed: float = 100.0
@export var can_be_captured: bool = true
@export_range(0.05, 1.0, 0.05) var capture_rate: float = 0.8
@export var reward_money: int = 25
@export var status_inflicted: String = ""
@export var pokemon_data: PokemonData

var current_hp: float = 50.0
var removed_from_game: bool = false
var anim_timer: float = 0.0
var anim_frame: int = 0
var current_direction: int = 3
var tower_attack_timer: float = 0.0
var sprite_sheet: Texture2D

@onready var health_bar: ProgressBar = $CharacterBody2D/ProgressBar
@onready var character_body: CharacterBody2D = $CharacterBody2D
@onready var sprite: Sprite2D = $CharacterBody2D/Sprite2D

func _ready() -> void:
	loop = false
	rotates = false # O PathFollow2D não deve girar o sprite junto com a tangente da curva.
	sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	max_hp = maxf(1.0, pokemon_data.hp) if pokemon_data != null else maxf(1.0, max_hp)
	current_hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	add_to_group("enemies")
	if character_body:
		character_body.input_pickable = true
		if not character_body.input_event.is_connected(_on_character_body_input_event):
			character_body.input_event.connect(_on_character_body_input_event)
	_update_sprite()

func _process(delta: float) -> void:
	if removed_from_game or GameManager.game_over:
		return
	var previous_progress := maxf(0.0, progress - 3.0)
	var next_progress := minf(get_parent_path_length(), progress + 3.0)
	var previous_direction := current_direction
	var curve := get_parent_curve()
	if curve:
		var direction_vector: Vector2 = curve.sample_baked(next_progress) - curve.sample_baked(previous_progress)
		# A spritesheet is not rotated: keep a horizontal facing direction.
		# At sharp/vertical turns, retain the last direction instead of
		# rapidly switching to side/upside-down frames due to curve jitter.
		var horizontal_strength := absf(direction_vector.x)
		var vertical_strength := absf(direction_vector.y)
		if horizontal_strength > vertical_strength * 1.35 and horizontal_strength > 0.05:
			current_direction = 3 if direction_vector.x > 0.0 else 2
	if current_direction != previous_direction:
		_update_sprite()
	anim_timer += delta
	tower_attack_timer += delta
	_attack_nearby_tower()
	if anim_timer >= 0.24:
		anim_timer = fmod(anim_timer, 0.24)
		anim_frame = (anim_frame + 1) % 2
		_update_sprite()
	progress += speed * delta
	if progress_ratio >= 1.0:
		reach_end_of_path()

func _attack_nearby_tower() -> void:
	if tower_attack_timer < 1.25:
		return
	var target_tower: Node2D = null
	var nearest_distance := 28.0
	for candidate in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			target_tower = candidate as Node2D
	if target_tower and target_tower.has_method("take_damage"):
		target_tower.call("take_damage", 8.0, status_inflicted)
		tower_attack_timer = 0.0

func get_parent_curve() -> Curve2D:
	var path := get_parent() as Path2D
	return path.curve if path else null

func get_parent_path_length() -> float:
	var path := get_parent() as Path2D
	return path.curve.get_baked_length() if path and path.curve else progress

func _update_sprite() -> void:
	if sprite == null or sprite_sheet == null or pokemon_data == null:
		return
	var rect := pokemon_data.get_frame_region(current_direction, anim_frame)
	if rect.position.x < 0.0 or rect.position.y < 0.0 or rect.end.x > sprite_sheet.get_width() or rect.end.y > sprite_sheet.get_height():
		return
	var texture := SPRITE_FACTORY.make_frame(sprite_sheet, rect)
	if texture:
		sprite.texture = texture
		sprite.centered = true
		sprite.scale = Vector2(1.5, 1.5)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func take_damage(amount: float) -> void:
	if removed_from_game or amount <= 0.0:
		return
	current_hp = maxf(0.0, current_hp - amount)
	health_bar.value = current_hp
	if current_hp <= 0.0:
		removed_from_game = true
		GameManager.add_money(reward_money)
		queue_free()

func reach_end_of_path() -> void:
	if removed_from_game:
		return
	removed_from_game = true
	GameManager.take_damage(1)
	queue_free()

func try_to_catch() -> void:
	if removed_from_game:
		return
	if not can_be_captured:
		print("%s é um Pokémon especial e não pode ser capturado." % (pokemon_data.species_name if pokemon_data else "Este inimigo"))
		return
	var ball_name := GameManager.selected_pokeball
	if ball_name.is_empty() or not GameManager.use_pokeball(ball_name):
		print("Você não possui essa Pokébola.")
		return
	var hp_ratio := clampf(current_hp / max_hp, 0.0, 1.0)
	var base_chance := 0.35 + (1.0 - hp_ratio) * 0.55
	var catch_chance := clampf(base_chance * capture_rate * GameManager.get_capture_bonus(ball_name), 0.05, 0.95)
	if randf() <= catch_chance:
		var captured_data: PokemonData
		if pokemon_data:
			captured_data = pokemon_data.duplicate(true) as PokemonData
		else:
			captured_data = PokemonData.new()
		if captured_data.species_name.is_empty():
			captured_data.species_name = "Pokémon selvagem"
		captured_data.current_hp = maxf(1.0, minf(current_hp, captured_data.hp))
		if GameManager.capture_pokemon(captured_data):
			print("Pokémon capturado com %s: %s" % [ball_name, captured_data.species_name])
		else:
			print("Este Pokémon já está no inventário.")
		removed_from_game = true
		queue_free()
	else:
		print("%s escapou da %s!" % [pokemon_data.species_name if pokemon_data else "O Pokémon", ball_name])

func _on_character_body_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_to_catch()
		get_viewport().set_input_as_handled()
