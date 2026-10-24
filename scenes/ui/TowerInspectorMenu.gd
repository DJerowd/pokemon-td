extends Control

var target_pokemon: Resource = null # Recebe o PokemonData da torre clicada
var target_tower: Node2D = null # Referência à torre que abriu o menu

@onready var panel_container = $VBoxContainer # Painel ou container principal do menu
@onready var lbl_title = $VBoxContainer/LblTitle
@onready var lbl_stats = $VBoxContainer/LblStats
@onready var lbl_item = $VBoxContainer/LblItem
@onready var moves_box = $VBoxContainer/MovesBox
@onready var btn_close = $VBoxContainer/BtnClose

func _ready() -> void:
	if target_pokemon:
		update_ui()
	
	btn_close.pressed.connect(func(): queue_free())

func _close_menu() -> void:
	# Oculta a área de alcance da torre associada antes de fechar
	if target_tower and is_instance_valid(target_tower):
		target_tower.is_selected = false
		target_tower.queue_redraw()
	
	queue_free()

# Detecta cliques fora do painel principal para fechar o menu automaticamente
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if panel_container:
			# Verifica se a posição global do mouse está fora da área ocupada pelo menu
			var global_rect = panel_container.get_global_rect()
			if not global_rect.has_point(get_global_mouse_position()):
				_close_menu()
				get_viewport().set_input_as_handled()

func update_ui() -> void:
	# 1. Atualiza títulos e estatísticas
	lbl_title.text = target_pokemon.species_name + " (Lvl " + str(target_pokemon.level) + ")"
	lbl_stats.text = "Atk: " + str(target_pokemon.attack) + " | Def: " + str(target_pokemon.defense) + " | Spd: " + str(target_pokemon.speed)
	lbl_item.text = "Item Segurado: " + (target_pokemon.held_item if target_pokemon.held_item != "" else "Nenhum")
	
	# 2. Limpa e cria botões interativos para os golpes disponíveis
	for child in moves_box.get_children():
		child.queue_free()
		
	for i in range(target_pokemon.available_moves.size()):
		var move_name = target_pokemon.available_moves[i]
		if move_name != "":
			var move_btn = Button.new()
			move_btn.text = move_name
			
			# Destaca visualmente qual é o golpe ativo atualmente
			if i == target_pokemon.active_move_index:
				move_btn.modulate = Color.GREEN_YELLOW
				
			# Ao clicar, muda o golpe ativo do Pokémon em tempo real
			move_btn.pressed.connect(func():
				target_pokemon.active_move_index = i
				print("Golpe ativo alterado para: ", move_name)
				update_ui() # Atualiza o destaque visual
			)
			
			moves_box.add_child(move_btn)
