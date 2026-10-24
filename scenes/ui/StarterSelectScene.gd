extends Control

@onready var title_label = $TitleLabel
@onready var pokeball_buttons = [%Pokeball1, %Pokeball2, %Pokeball3]
@onready var dialogue_label = $DialogueBox/DialogueLabel
@onready var choices_container = $DialogueBox/ChoicesContainer
@onready var btn_yes = $DialogueBox/ChoicesContainer/BtnYes
@onready var btn_no = $DialogueBox/ChoicesContainer/BtnNo
@onready var btn_left = $BtnLeft
@onready var btn_right = $BtnRight

var current_gen_index: int = 0
var selected_pokemon_info = null
var waiting_for_confirmation: bool = false

func _ready() -> void:
	choices_container.hide() # Oculta os botões YES/NO inicialmente
	setup_connections()
	update_ui()

func setup_connections() -> void:
	btn_left.pressed.connect(func(): change_generation(-1))
	btn_right.pressed.connect(func(): change_generation(1))
	
	btn_yes.pressed.connect(_on_yes_pressed)
	btn_no.pressed.connect(_on_no_pressed)
	
	for i in range(pokeball_buttons.size()):
		var btn = pokeball_buttons[i]
		# Eventos de mouse para interatividade clássica
		btn.mouse_entered.connect(func(): on_pokeball_hover(i))
		btn.pressed.connect(func(): on_pokeball_clicked(i))

func update_ui() -> void:
	var gen_data = StarterDatabase.generations[current_gen_index]
	title_label.text = "--- " + gen_data["region"] + " ---"
	
	if not waiting_for_confirmation:
		dialogue_label.text = "Escolha um Pokémon contido na Pokébola."

func change_generation(direction: int) -> void:
	if waiting_for_confirmation: return
	current_gen_index = (current_gen_index + direction) % StarterDatabase.generations.size()
	if current_gen_index < 0:
		current_gen_index = StarterDatabase.generations.size() - 1
	update_ui()

# Quando o mouse passa por cima da Pokébola (Efeito visual de destaque)
func on_pokeball_hover(index: int) -> void:
	if waiting_for_confirmation: return
	var pokemon = StarterDatabase.generations[current_gen_index]["starters"][index]
	dialogue_label.text = "Contém o Pokémon " + pokemon["name"] + " (" + pokemon["type"] + ")."

# Quando o jogador clica na Pokébola escolhida
func on_pokeball_clicked(index: int) -> void:
	if waiting_for_confirmation: return
	
	selected_pokemon_info = StarterDatabase.generations[current_gen_index]["starters"][index]
	waiting_for_confirmation = true
	
	# Exibe o diálogo clássico de confirmação com YES e NO
	dialogue_label.text = "Você quer escolher o " + selected_pokemon_info["name"] + "?"
	choices_container.show()

func _on_yes_pressed() -> void:
	print("Pokémon confirmado: ", selected_pokemon_info["name"])
	
	# Instancia o recurso PokemonData
	var starter_data: PokemonData = PokemonData.new()
	starter_data.species_name = selected_pokemon_info["name"]
	starter_data.level = 5
	
	# CORREÇÃO AQUI: Em vez de sprite_region, usamos sprite_origin
	# Se no StarterDatabase você guardou a posição inicial (Vector2), use aqui:
	if selected_pokemon_info.has("sprite_origin"):
		starter_data.sprite_origin = selected_pokemon_info["sprite_origin"]
	elif selected_pokemon_info.has("region_rect"):
		# Se region_rect for um Rect2, pegamos apenas o canto superior esquerdo (position)
		starter_data.sprite_origin = selected_pokemon_info["region_rect"].position
		
	starter_data.attack = selected_pokemon_info["attack"]
	
	GameManager.captured_pokemons.append(starter_data)
	
	# Transiciona para a cena de seleção do time
	get_tree().change_scene_to_file("res://scenes/ui/TeamSelectScene.tscn")

func _on_no_pressed() -> void:
	# Cancela a escolha e retorna ao estado normal
	waiting_for_confirmation = false
	selected_pokemon_info = null
	choices_container.hide()
	update_ui()
