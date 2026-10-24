extends Panel

var slot_index: int = 0
var assigned_pokemon: Resource = null
var team_manager = null # Referência ao script principal da cena

# Verifica se o dado arrastado é válido para soltar aqui
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("pokemon_data")

# Executado quando o jogador solta o mouse em cima do slot
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	assigned_pokemon = data["pokemon_data"]
	
	# Atualiza o texto visual do slot para mostrar o Pokémon escolhido
	for child in get_children():
		child.queue_free() # Remove texto/ícone anterior se houver
		
	var label = Label.new()
	label.text = assigned_pokemon.species_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	
	# Comunica com a tela principal
	if team_manager and team_manager.has_method("assign_pokemon_to_slot"):
		team_manager.assign_pokemon_to_slot(slot_index, assigned_pokemon)
