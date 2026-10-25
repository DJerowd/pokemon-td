extends Control

@onready var storage_grid: GridContainer = %StorageGrid
@onready var team_slots_row: HBoxContainer = %TeamSlotsRow
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

const STARTER_SCENE := "res://scenes/ui/StarterSelectScene.tscn"
const GAME_SCENE := "res://scenes/main/GameScene.tscn"
var current_team_selection: Array[PokemonData] = [null, null, null, null, null, null]

func _ready() -> void:
	# Não criar um Pokémon falso silenciosamente: a seleção inicial é a fonte
	# correta do inventário e os dados devem ser consistentes.
	populate_storage_grid()
	setup_team_slots()
	start_button.pressed.connect(_on_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func populate_storage_grid() -> void:
	for child in storage_grid.get_children():
		storage_grid.remove_child(child)
		child.queue_free()
	for pokemon in GameManager.captured_pokemons:
		if pokemon == null:
			continue
		var card := Button.new()
		card.text = "%s\nNv. %d" % [pokemon.species_name, pokemon.level]
		card.custom_minimum_size = Vector2(84, 64)
		card.set_script(load("res://scripts/ui/DraggablePokemonCard.gd"))
		card.set("pokemon_data", pokemon)
		storage_grid.add_child(card)

func setup_team_slots() -> void:
	var index := 0
	for slot_panel in team_slots_row.get_children():
		if slot_panel is Panel:
			slot_panel.set_script(load("res://scripts/ui/TeamSlot.gd"))
			slot_panel.set("slot_index", index)
			slot_panel.set("team_manager", self)
			index += 1

func assign_pokemon_to_slot(index: int, pokemon_data: PokemonData) -> void:
	if index < 0 or index >= current_team_selection.size() or pokemon_data == null:
		return
	# Un Pokémon ne peut occuper qu'un seul emplacement à la fois.
	for i in range(current_team_selection.size()):
		if current_team_selection[i] == pokemon_data:
			current_team_selection[i] = null
			var panel := team_slots_row.get_child(i)
			for child in panel.get_children():
				panel.remove_child(child)
				child.queue_free()
	current_team_selection[index] = pokemon_data
	print(pokemon_data.species_name, " atribuído ao slot ", index + 1)

func clear_team_slot(index: int) -> void:
	if index < 0 or index >= current_team_selection.size():
		return
	current_team_selection[index] = null

func _on_start_button_pressed() -> void:
	var final_team: Array[PokemonData] = []
	for pokemon in current_team_selection:
		if pokemon != null and not final_team.has(pokemon):
			final_team.append(pokemon)
	if final_team.is_empty():
		push_warning("Selecione pelo menos um Pokémon antes de iniciar.")
		return
	GameManager.active_battle_team = final_team
	GameManager.deployed_pokemons.clear()
	GameManager.selected_pokemon_to_place = null
	GameManager.current_wave = 0
	GameManager.player_money = 100
	GameManager.player_lives = 10
	GameManager.pokeballs = 5
	GameManager.game_over = false
	GameManager.stats_changed.emit()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(STARTER_SCENE)
