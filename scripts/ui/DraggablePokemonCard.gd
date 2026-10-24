extends Button

var pokemon_data: Resource

# Método nativo do Godot acionado ao iniciar o arrasto
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not pokemon_data:
		return null
		
	# Cria uma pré-visualização visual flutuante enquanto arrasta o mouse
	var preview = Label.new()
	preview.text = pokemon_data.species_name
	preview.add_theme_color_override("font_color", Color.YELLOW)
	set_drag_preview(preview)
	
	# Retorna os dados que estão sendo transportados
	return { "pokemon_data": pokemon_data }
