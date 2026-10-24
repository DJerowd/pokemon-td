extends HBoxContainer

func _ready() -> void:
	populate_bar()

func populate_bar() -> void:
	for child in get_children():
		child.queue_free()
		
	# Cria mini-cards para cada Pokémon do time ativo escolhido na seleção
	for pokemon in GameManager.active_battle_team:
		if pokemon:
			var card = Button.new()
			card.text = pokemon.species_name + "\nLvl " + str(pokemon.level)
			card.custom_minimum_size = Vector2(64, 64)
			
			# Anexa o script de arrastar para a barra de time
			card.set_script(load("res://scripts/ui/DraggableTeamCard.gd"))
			card.pokemon_data = pokemon
			
			add_child(card)
