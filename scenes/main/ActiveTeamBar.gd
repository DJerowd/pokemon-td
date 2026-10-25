extends HBoxContainer

func _ready() -> void:
	populate_bar()

func populate_bar() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# Cada botão representa um Pokémon escolhido para a batalha.
	# Clicar seleciona a unidade; o próximo clique em um slot a posiciona.
	for pokemon in GameManager.active_battle_team:
		if pokemon == null:
			continue
		var card := Button.new()
		card.text = "%s\nNv. %d" % [pokemon.species_name, pokemon.level]
		card.custom_minimum_size = Vector2(72, 64)
		card.tooltip_text = "Selecione e clique em um espaço vazio do mapa."
		card.pressed.connect(_on_pokemon_pressed.bind(pokemon))
		add_child(card)

func _on_pokemon_pressed(pokemon: PokemonData) -> void:
	if GameManager.can_deploy_pokemon(pokemon):
		GameManager.selected_pokemon_to_place = pokemon
