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
		var placeholder := Label.new()
		placeholder.text = "＋\nVAZIO"
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		placeholder.add_theme_color_override("font_color", Color(0.4, 0.73, 0.86))
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(placeholder)
		return
	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 0)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sprite_view := TextureRect.new()
	sprite_view.custom_minimum_size = Vector2(64, 68)
	sprite_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite_view.texture = assigned_pokemon.sprite
	sprite_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.text = "%s\nNv. %d" % [assigned_pokemon.species_name, assigned_pokemon.level]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.91, 0.97, 1.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sprite_view)
	content.add_child(label)
	add_child(content)
