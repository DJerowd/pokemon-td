extends Panel

var slot_index: int = 0
var assigned_pokemon: PokemonData = null
var team_manager: Node = null

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("pokemon_data") is PokemonData

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var pokemon: PokemonData = data.get("pokemon_data")
	if pokemon == null:
		return
	assigned_pokemon = pokemon
	_update_slot_visual()
	if team_manager and team_manager.has_method("assign_pokemon_to_slot"):
		team_manager.assign_pokemon_to_slot(slot_index, pokemon)

func _gui_input(event: InputEvent) -> void:
	# Clique direito remove a escolha atual, útil para corrigir o time.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		assigned_pokemon = null
		_update_slot_visual()
		if team_manager and team_manager.has_method("clear_team_slot"):
			team_manager.clear_team_slot(slot_index)
		accept_event()

func _update_slot_visual() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	if assigned_pokemon == null:
		return
	var label := Label.new()
	label.text = assigned_pokemon.species_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
