extends PathFollow2D

@export var max_hp: float = 50.0
var current_hp: float
@export var speed: float = 100.0
@export var pokemon_data: Resource # Referência aos dados do Pokémon

@onready var health_bar = $CharacterBody2D/ProgressBar
@onready var character_body = $CharacterBody2D

func _ready() -> void:
	current_hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	# Adiciona o inimigo ao grupo para o WaveManager conseguir contá-lo
	if not is_in_group("enemies"):
		add_to_group("enemies")
		
	# Como o PathFollow2D não recebe input direto, ativamos o pickable no CharacterBody2D e conectamos o sinal
	if character_body:
		character_body.input_pickable = true
		if not character_body.input_event.is_connected(_on_character_body_input_event):
			character_body.input_event.connect(_on_character_body_input_event)

func _process(delta: float) -> void:
	# Move o inimigo ao longo do Path2D
	progress += speed * delta
	
	# Se chegar ao final do caminho
	if progress_ratio >= 1.0:
		GameManager.player_lives -= 1
		queue_free() # Remove o inimigo da tela

func take_damage(amount: float) -> void:
	current_hp -= amount
	health_bar.value = current_hp
	if current_hp <= 0:
		GameManager.player_money += 50 # Recompensa em dinheiro
		queue_free()

# Função chamada quando o jogador clica no inimigo para tentar capturá-lo
func try_to_catch() -> void:
	if GameManager.has("pokeballs") and GameManager.pokeballs > 0:
		GameManager.pokeballs -= 1
		# Chance simulada de captura com base na vida restante
		var catch_chance = 0.5 + (1.0 - (current_hp / max_hp)) * 0.5
		if randf() <= catch_chance:
			print("Pokémon capturado com sucesso!")
			if pokemon_data:
				GameManager.captured_pokemons.append(pokemon_data)
			queue_free()
		else:
			print("O Pokémon escapou da Pokéball!")
	else:
		print("Sem Pokéballs restantes!")
		

# Recebe o evento de clique repassado pelo CharacterBody2D filho
func _on_character_body_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_to_catch()
		get_viewport().set_input_as_handled() # Impede que o clique atravesse para o mapa
