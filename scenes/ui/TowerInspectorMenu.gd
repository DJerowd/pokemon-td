extends Control

var target_pokemon: PokemonData = null
var target_tower: Node2D = null

@onready var panel_container: Control = $VBoxContainer
@onready var lbl_title: Label = $VBoxContainer/LblTitle
@onready var lbl_stats: Label = $VBoxContainer/LblStats
@onready var lbl_item: Label = $VBoxContainer/LblItem
@onready var moves_box: VBoxContainer = $VBoxContainer/MovesBox
@onready var btn_close: Button = $VBoxContainer/BtnClose

func _ready() -> void:
	btn_close.pressed.connect(_close_menu)
	if target_pokemon:
		update_ui()

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
	lbl_stats.text = "Ataque: %.1f | Defesa: %.1f | Velocidade: %.1f" % [target_pokemon.attack, target_pokemon.defense, target_pokemon.speed]
	lbl_item.text = "Item: " + (target_pokemon.held_item if not target_pokemon.held_item.is_empty() else "Nenhum")

	for child in moves_box.get_children():
		moves_box.remove_child(child)
		child.queue_free()
	for index in range(target_pokemon.available_moves.size()):
		var move_name: String = target_pokemon.available_moves[index]
		if move_name.is_empty():
			continue
		var move_button := Button.new()
		move_button.text = ("✓ " if index == target_pokemon.active_move_index else "") + move_name
		move_button.pressed.connect(_on_move_selected.bind(index))
		moves_box.add_child(move_button)

func _on_move_selected(index: int) -> void:
	if target_pokemon == null:
		return
	target_pokemon.active_move_index = index
	# PokemonTower consulta o golpe ativo nos dados a cada ataque.
	update_ui()
