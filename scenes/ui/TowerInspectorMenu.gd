extends Control

var target_pokemon: PokemonData = null
var target_tower: Node2D = null

@onready var panel_container: Control = $InspectorPanel
@onready var content_box: VBoxContainer = $InspectorPanel/VBoxContainer
@onready var lbl_title: Label = $InspectorPanel/VBoxContainer/LblTitle
@onready var lbl_stats: Label = $InspectorPanel/VBoxContainer/LblStats
@onready var lbl_item: Label = $InspectorPanel/VBoxContainer/LblItem
@onready var moves_box: HBoxContainer = $InspectorPanel/VBoxContainer/MovesBox
@onready var btn_move: Button = $InspectorPanel/VBoxContainer/ActionsRow/BtnMove
@onready var btn_remove: Button = $InspectorPanel/VBoxContainer/ActionsRow/BtnRemove
@onready var btn_close: Button = $InspectorPanel/VBoxContainer/ActionsRow/BtnClose

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_PASS
	_style_inspector()
	btn_move.pressed.connect(_on_move_pressed)
	btn_remove.pressed.connect(_on_remove_pressed)
	btn_close.pressed.connect(_close_menu)
	if target_pokemon:
		update_ui()

func _style_inspector() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.065, 0.13, 0.97)
	panel_style.border_color = Color(0.12, 0.78, 1.0, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 14.0
	panel_style.content_margin_right = 14.0
	panel_style.content_margin_top = 12.0
	panel_style.content_margin_bottom = 12.0
	$InspectorPanel.add_theme_stylebox_override("panel", panel_style)
	content_box.add_theme_constant_override("separation", 8)
	lbl_title.add_theme_font_size_override("font_size", 20)
	lbl_title.add_theme_color_override("font_color", Color(0.35, 0.9, 1.0))
	lbl_stats.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	lbl_item.add_theme_color_override("font_color", Color(0.72, 0.9, 1.0))
	btn_move.text = "MOVER"
	btn_remove.text = "RETIRAR"
	btn_close.text = "FECHAR"

func _close_menu() -> void:
	# Toda forma de fechar deve executar a mesma limpeza.
	if target_tower and is_instance_valid(target_tower):
		target_tower.set("is_selected", false)
		target_tower.queue_redraw()
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if panel_container and not panel_container.get_global_rect().has_point(get_global_mouse_position()):
			_close_menu()
			get_viewport().set_input_as_handled()

func update_ui() -> void:
	if target_pokemon == null:
		return
	lbl_title.text = "%s (Nv. %d)" % [target_pokemon.species_name, target_pokemon.level]
	var hp_text := "%.0f/%.0f" % [target_tower.get("current_hp") if target_tower and is_instance_valid(target_tower) else target_pokemon.current_hp, target_pokemon.hp]
	var status_text := target_pokemon.status_condition if not target_pokemon.status_condition.is_empty() else "Normal"
	lbl_stats.text = "HP: %s | Atq: %.1f | Def: %.1f | Vel: %.1f\nStatus: %s" % [hp_text, target_pokemon.attack, target_pokemon.defense, target_pokemon.speed, status_text]
	lbl_item.text = "Item: " + (target_pokemon.held_item if not target_pokemon.held_item.is_empty() else "Nenhum")

	for child in moves_box.get_children():
		moves_box.remove_child(child)
		child.queue_free()
	for index in range(target_pokemon.available_moves.size()):
		var move_name: String = target_pokemon.available_moves[index]
		if move_name.is_empty():
			continue
		var move_button := Button.new()
		move_button.custom_minimum_size = Vector2(0, 34)
		move_button.text = ("✓ " if index == target_pokemon.active_move_index else "") + move_name
		move_button.pressed.connect(_on_move_selected.bind(index))
		moves_box.add_child(move_button)

func _on_move_selected(index: int) -> void:
	if target_pokemon == null:
		return
	target_pokemon.active_move_index = index
	# PokemonTower consulta o golpe ativo nos dados a cada ataque.
	update_ui()

func _remove_target_tower() -> void:
	if target_tower == null or not is_instance_valid(target_tower):
		return
	var tower := target_tower
	target_tower = null
	var parent := tower.get_parent()
	if parent:
		parent.remove_child(tower)
	tower.free()

func _on_move_pressed() -> void:
	if target_pokemon == null or target_tower == null or not is_instance_valid(target_tower):
		_close_menu()
		return
	var pokemon_to_move := target_pokemon
	_remove_target_tower()
	GameManager.selected_pokemon_to_place = pokemon_to_move
	GameManager.team_changed.emit()
	queue_free()

func _on_remove_pressed() -> void:
	GameManager.selected_pokemon_to_place = null
	_remove_target_tower()
	GameManager.team_changed.emit()
	queue_free()
