extends Control

@onready var storage_grid = %StorageGrid
@onready var team_slots_row = %TeamSlotsRow
@onready var start_button = %StartButton
@onready var back_button = %BackButton

# Vetor para guardar os 6 slots do time (preenchidos com null inicialmente)
var current_team_selection: Array = [null, null, null, null, null, null]

func _ready() -> void:
	# Garante que há pelo menos um Pokémon inicial se o inventário estiver vazio
	if GameManager.captured_pokemons.is_empty():
		var dummy_starter = PokemonData.new()
		dummy_starter.name = "Bulbasaur"
		dummy_starter.base_damage = 25.0
		dummy_starter.attack_range = 160.0
		GameManager.captured_pokemons.append(dummy_starter)

	populate_storage_grid()
	setup_team_slots()

	# Conecta os botões superiores
	start_button.pressed.connect(_on_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

# 1. Popula o Storage (Grid inferior azul) com os Pokémon capturados
func populate_storage_grid() -> void:
	for child in storage_grid.get_children():
		child.queue_free()
		
	for pokemon in GameManager.captured_pokemons:
		var item_card = Button.new()
		item_card.text = pokemon.species_name + "\nLvl " + str(pokemon.level)
		item_card.custom_minimum_size = Vector2(64, 64)
		
		# Define os dados que serão arrastados quando o jogador segurar este botão
		item_card.set_script(load("res://scripts/ui/DraggablePokemonCard.gd"))
		item_card.pokemon_data = pokemon
		
		storage_grid.add_child(item_card)

# 2. Configura os 6 slots de cima para aceitarem o "Drop" (Soltar)
func setup_team_slots() -> void:
	var index = 0
	for slot_panel in team_slots_row.get_children():
		if slot_panel is Panel:
			slot_panel.set_script(load("res://scripts/ui/TeamSlot.gd"))
			slot_panel.slot_index = index
			slot_panel.team_manager = self
			index += 1

# Método chamado pelos slots quando um Pokémon é solto neles
func assign_pokemon_to_slot(index: int, pokemon_data: Resource) -> void:
	if index >= 0 and index < current_team_selection.size():
		current_team_selection[index] = pokemon_data
		print("Pokémon ", pokemon_data.species_name, " posicionado no slot de time ", index + 1)

# 3. Botão Start: Valida o time e inicia a partida
func _on_start_button_pressed() -> void:
	var final_team = []
	for p in current_team_selection:
		if p != null:
			final_team.append(p)

	if final_team.size() > 0:
		GameManager.active_battle_team = final_team
		print("Time confirmado com ", final_team.size(), " Pokémon! Iniciando fase...")
		get_tree().change_scene_to_file("res://scenes/main/GameScene.tscn")
	else:
		print("Você precisa selecionar pelo menos 1 Pokémon para ir para a batalha!")

# 4. Botão Back: Retorna ao menu anterior (ou reinicia)
func _on_back_button_pressed() -> void:
	print("Botão Back pressionado.")
