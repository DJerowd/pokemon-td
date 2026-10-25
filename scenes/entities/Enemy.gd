extends PathFollow2D

@export var max_hp: float = 50.0
var current_hp: float = 50.0
@export var speed: float = 100.0
@export var pokemon_data: PokemonData

@onready var health_bar: ProgressBar = $CharacterBody2D/ProgressBar
@onready var character_body: CharacterBody2D = $CharacterBody2D

var removed_from_game: bool = false

func _ready() -> void:
	# Desabilitar loop é essencial: com loop ativo, o inimigo volta ao início
	# do caminho antes que progress_ratio chegue ao fim.
	loop = false
	# Se houver dados de espécie, eles definem a vida inicial do inimigo.
	max_hp = maxf(1.0, pokemon_data.hp) if pokemon_data != null else maxf(1.0, max_hp)
	current_hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	add_to_group("enemies")

	if character_body:
		character_body.input_pickable = true
		if not character_body.input_event.is_connected(_on_character_body_input_event):
			character_body.input_event.connect(_on_character_body_input_event)

func _process(delta: float) -> void:
	if removed_from_game or GameManager.game_over:
		return
	progress += speed * delta
	if progress_ratio >= 1.0:
		reach_end_of_path()

func take_damage(amount: float) -> void:
	if removed_from_game or amount <= 0.0:
		return
	current_hp = maxf(0.0, current_hp - amount)
	health_bar.value = current_hp
	if current_hp <= 0.0:
		removed_from_game = true
		GameManager.add_money(50)
		queue_free()

func reach_end_of_path() -> void:
	if removed_from_game:
		return
	removed_from_game = true
	GameManager.take_damage(1)
	queue_free()

func try_to_catch() -> void:
	if removed_from_game or not GameManager.use_pokeball():
		print("Sem Pokébolas disponíveis ou partida encerrada.")
		return

	# Quanto menor o HP restante, maior a chance de captura (50% a 100%).
	var hp_ratio := clampf(current_hp / max_hp, 0.0, 1.0)
	var catch_chance := 0.5 + (1.0 - hp_ratio) * 0.5
	if randf() <= catch_chance:
		var captured_data: PokemonData = pokemon_data
		if captured_data == null:
			# O protótipo ainda não associa uma espécie a todos os spawns.
			# Criamos dados mínimos para que uma captura nunca seja perdida.
			captured_data = PokemonData.new()
			captured_data.species_name = "Pokémon selvagem"
			captured_data.hp = max_hp
			captured_data.attack = 40.0
		if GameManager.capture_pokemon(captured_data):
			print("Pokémon capturado: ", captured_data.species_name)
		else:
			print("Este Pokémon já está no inventário.")
		removed_from_game = true
		queue_free()
	else:
		print("O Pokémon escapou da Pokébola!")

func _on_character_body_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_to_catch()
		get_viewport().set_input_as_handled()
