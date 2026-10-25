extends Button
## Botão de inventário com suporte a arrastar e soltar no campo de batalha.

var item_name: String = ""
var inventory_kind: String = "item"

func _get_drag_data(_at_position: Vector2) -> Variant:
	if disabled or item_name.is_empty():
		return null
	var preview := Label.new()
	preview.text = "◉ " + item_name
	preview.add_theme_font_size_override("font_size", 16)
	preview.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	preview.add_theme_color_override("font_shadow_color", Color.BLACK)
	preview.add_theme_constant_override("shadow_offset_x", 2)
	preview.add_theme_constant_override("shadow_offset_y", 2)
	set_drag_preview(preview)
	return {
		"item_name": item_name,
		"kind": inventory_kind
	}
