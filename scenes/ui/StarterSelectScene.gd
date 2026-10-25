extends Control

@onready var title_label: Label = $TitleLabel
@onready var pokeball_buttons: Array[TextureButton] = [%Pokeball1, %Pokeball2, %Pokeball3]
@onready var dialogue_label: Label = $DialogueBox/DialogueLabel
@onready var choices_container: HBoxContainer = $DialogueBox/ChoicesContainer
@onready var btn_yes: Button = $DialogueBox/ChoicesContainer/BtnYes
@onready var btn_no: Button = $DialogueBox/ChoicesContainer/BtnNo
@onready var btn_left: Button = $BtnLeft
@onready var btn_right: Button = $BtnRight
@onready var preview_name: Label = $HoverPreviewPanel/PreviewName
@onready var preview_sprite: TextureRect = $HoverPreviewPanel/PreviewSprite

var current_gen_index: int = 0
var selected_pokemon_info: Dictionary = {}
var waiting_for_confirmation: bool = false

func _ready() -> void:
	choices_container.hide()
	btn_left.pressed.connect(_on_previous_generation)
	btn_right.pressed.connect(_on_next_generation)
	btn_yes.pressed.connect(_on_yes_pressed)
	btn_no.pressed.connect(_on_no_pressed)
	for index in range(pokeball_buttons.size()):
		var button := pokeball_buttons[index]
		button.mouse_entered.connect(on_pokeball_hover.bind(index))
		button.pressed.connect(on_pokeball_clicked.bind(index))
	update_ui()

func update_ui() -> void:
	var generation: Dictionary = StarterDatabase.generations[current_gen_index]
	title_label.text = "--- %s ---" % generation["region"]
	if not waiting_for_confirmation:
		dialogue_label.text = "Escolha um Pokémon contido na Pokébola."
	preview_name.text = ""
	preview_sprite.texture = null

func _on_previous_generation() -> void:
	change_generation(-1)

func _on_next_generation() -> void:
	change_generation(1)

func change_generation(direction: int) -> void:
	if waiting_for_confirmation:
		return
	current_gen_index = posmod(current_gen_index + direction, StarterDatabase.generations.size())
	update_ui()

func on_pokeball_hover(index: int) -> void:
	if waiting_for_confirmation:
		return
	var starter: Dictionary = StarterDatabase.generations[current_gen_index]["starters"][index]
	dialogue_label.text = "Contém %s (%s)." % [starter["name"], starter["type"]]
	preview_name.text = starter["name"]
	# O banco guarda a coordenada do sprite, não a imagem. Até uma textura
	# válida ser configurada no recurso, o preview permanece sem textura.

func on_pokeball_clicked(index: int) -> void:
	if waiting_for_confirmation:
		return
	selected_pokemon_info = StarterDatabase.generations[current_gen_index]["starters"][index]
	waiting_for_confirmation = true
	dialogue_label.text = "Deseja escolher %s?" % selected_pokemon_info["name"]
	choices_container.show()

func _on_yes_pressed() -> void:
	if selected_pokemon_info.is_empty():
		return
	var starter_data := PokemonData.new()
	starter_data.id = _species_id(selected_pokemon_info["name"])
	starter_data.species_name = selected_pokemon_info["name"]
	starter_data.level = 5
	starter_data.sprite_origin = selected_pokemon_info.get("sprite_origin", Vector2.ZERO)
	starter_data.hp = float(selected_pokemon_info.get("hp", 45))
	starter_data.attack = float(selected_pokemon_info.get("attack", 49))
	var type_name: String = str(selected_pokemon_info.get("type", ""))
	if type_name.contains("Fogo"):
		starter_data.primary_type = PokemonData.Type.FIRE
	elif type_name.contains("Água"):
		starter_data.primary_type = PokemonData.Type.WATER
	else:
		starter_data.primary_type = PokemonData.Type.GRASS
	starter_data.secondary_type = PokemonData.Type.NONE
	if type_name.contains("Veneno"):
		starter_data.secondary_type = PokemonData.Type.POISON
	GameManager.captured_pokemons.clear()
	GameManager.capture_pokemon(starter_data)
	GameManager.active_battle_team.clear()
	GameManager.stats_changed.emit()
	get_tree().change_scene_to_file("res://scenes/ui/TeamSelectScene.tscn")

func _species_id(species_name: String) -> int:
	# A tabela ainda não possui IDs nacionais; hash fornece um ID estável
	# para este protótipo. Troque por IDs oficiais ao expandir a base de dados.
	return absi(species_name.to_lower().hash()) % 100000

func _on_no_pressed() -> void:
	waiting_for_confirmation = false
	selected_pokemon_info.clear()
	choices_container.hide()
	update_ui()
