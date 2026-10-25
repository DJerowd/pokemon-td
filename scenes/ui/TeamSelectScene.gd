extends Control

const STARTER_SCENE := "res://scenes/ui/StarterSelectScene.tscn"
const GAME_SCENE := "res://scenes/main/GameScene.tscn"
const SPRITE_SHEET_PATH := "res://assets/textures/DS _ DSi - Pokemon Black 2 _ White 2 - Overworld - Pokemon (Overworld).png"
const SPRITE_FRAME_SIZE := Vector2(32, 32)
const SPRITE_FACTORY = preload("res://scripts/data/SpriteFrameFactory.gd")

@onready var storage_grid: GridContainer = %StorageGrid
@onready var team_slots_row: HBoxContainer = %TeamSlotsRow
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton
@onready var title_label: Label = $MarginContainer/MainLayout/TopSection/HeaderRow/TitleLabel
@onready var storage_title: Label = $MarginContainer/MainLayout/MiddleSection/StorageHeaderRow/StorageTitle
@onready var help_label: Label = $MarginContainer/MainLayout/MiddleSection/StorageHeaderRow/HelpLabel

var current_team_selection: Array[PokemonData] = [null, null, null, null, null, null]
var sprite_sheet: Texture2D

func _ready() -> void:
	sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	_apply_visual_style()
	populate_storage_grid()
	setup_team_slots()
	start_button.text = "INICIAR PARTIDA"
	back_button.text = "VOLTAR"
	start_button.pressed.connect(_on_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _apply_visual_style() -> void:
	title_label.text = "EQUIPE POKÉMON"
	title_label.add_theme_color_override("font_color", Color(0.83, 0.96, 1.0))
	title_label.add_theme_font_size_override("font_size", 26)
	storage_title.text = "POKÉMON DISPONÍVEIS"
	storage_title.add_theme_color_override("font_color", Color(0.35, 0.86, 1.0))
	storage_title.add_theme_font_size_override("font_size", 18)
	help_label.text = "Arraste um Pokémon para um espaço da equipe • botão direito remove"
	help_label.add_theme_color_override("font_color", Color(0.73, 0.84, 0.92))
	storage_grid.columns = 6
	var background := $Background as ColorRect
	background.color = Color(0.018, 0.045, 0.105, 1.0)
	_style_button(start_button, true)
	_style_button(back_button, false)
	for child in team_slots_row.get_children():
		if child is Control:
			child.custom_minimum_size = Vector2(132, 112)
			child.add_theme_stylebox_override("panel", _make_panel_style(Color(0.035, 0.11, 0.19, 0.98), Color(0.15, 0.72, 0.95), 2, 9))
	var storage_panel := $MarginContainer/MainLayout/StorageBottomSection as Panel
	storage_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.075, 0.14, 0.98), Color(0.1, 0.45, 0.67), 2, 12))

func _make_panel_style(fill: Color, outline: Color, border: int, corner: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = outline
	style.set_border_width_all(border)
	style.set_corner_radius_all(corner)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style

func _style_button(button: Button, primary: bool) -> void:
	button.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
	button.add_theme_font_size_override("font_size", 15)
	var normal := _make_panel_style(Color(0.025, 0.32, 0.48, 1.0) if primary else Color(0.035, 0.13, 0.23, 1.0), Color(0.23, 0.83, 1.0), 2, 7)
	var hover := _make_panel_style(Color(0.04, 0.48, 0.65, 1.0), Color(0.72, 0.97, 1.0), 2, 7)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)

func _texture_for_pokemon(pokemon: PokemonData) -> Texture2D:
	if pokemon == null:
		return null
	if pokemon.sprite != null:
		return pokemon.sprite
	if sprite_sheet == null:
		return null
	var region := Rect2(pokemon.sprite_origin, SPRITE_FRAME_SIZE)
	var bounds := Rect2(Vector2.ZERO, sprite_sheet.get_size())
	if pokemon.sprite_origin.x < 0.0 or pokemon.sprite_origin.y < 0.0 or not bounds.encloses(region):
		return null
	var texture := SPRITE_FACTORY.make_frame(sprite_sheet, region)
	pokemon.sprite = texture
	return texture

func populate_storage_grid() -> void:
	for child in storage_grid.get_children():
		storage_grid.remove_child(child)
		child.queue_free()
	for pokemon in GameManager.captured_pokemons:
		if pokemon == null:
			continue
		var card := Button.new()
		card.name = "PokemonCard_%s" % pokemon.species_name.replace(" ", "_")
		card.text = "%s\nNv. %d" % [pokemon.species_name, pokemon.level]
		card.custom_minimum_size = Vector2(126, 112)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.clip_text = true
		card.icon = _texture_for_pokemon(pokemon)
		card.add_theme_font_size_override("font_size", 14)
		card.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0))
		card.add_theme_stylebox_override("normal", _make_panel_style(Color(0.045, 0.14, 0.23, 1.0), Color(0.14, 0.42, 0.59), 1, 8))
		card.add_theme_stylebox_override("hover", _make_panel_style(Color(0.055, 0.24, 0.35, 1.0), Color(0.28, 0.85, 1.0), 2, 8))
		card.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.02, 0.32, 0.45, 1.0), Color(0.4, 0.92, 1.0), 2, 8))
		card.set_script(load("res://scripts/ui/DraggablePokemonCard.gd"))
		card.set("pokemon_data", pokemon)
		storage_grid.add_child(card)
	if GameManager.captured_pokemons.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Nenhum Pokémon no armazenamento. Volte e escolha seu inicial."
		empty_label.add_theme_color_override("font_color", Color(0.75, 0.86, 0.93))
		storage_grid.add_child(empty_label)

func setup_team_slots() -> void:
	var index := 0
	for slot_panel in team_slots_row.get_children():
		if slot_panel is Panel:
			slot_panel.set_script(load("res://scripts/ui/TeamSlot.gd"))
			slot_panel.set("slot_index", index)
			slot_panel.set("team_manager", self)
			slot_panel.set("assigned_pokemon", null)
			slot_panel.call("_update_slot_visual")
			index += 1

func assign_pokemon_to_slot(index: int, pokemon_data: PokemonData) -> void:
	if index < 0 or index >= current_team_selection.size() or pokemon_data == null:
		return
	for i in range(current_team_selection.size()):
		if i != index and current_team_selection[i] == pokemon_data:
			current_team_selection[i] = null
			var previous_panel := team_slots_row.get_child(i)
			previous_panel.set("assigned_pokemon", null)
			previous_panel.call("_update_slot_visual")
	current_team_selection[index] = pokemon_data
	print(pokemon_data.species_name, " atribuído ao espaço ", index + 1)

func clear_team_slot(index: int) -> void:
	if index < 0 or index >= current_team_selection.size():
		return
	current_team_selection[index] = null
	var slot_panel := team_slots_row.get_child(index)
	if slot_panel.has_method("_update_slot_visual"):
		slot_panel.call("_update_slot_visual")

func _on_start_button_pressed() -> void:
	var final_team: Array[PokemonData] = []
	for pokemon in current_team_selection:
		if pokemon != null and not final_team.has(pokemon):
			final_team.append(pokemon)
	if final_team.is_empty():
		push_warning("Selecione pelo menos um Pokémon antes de iniciar.")
		return
	GameManager.active_battle_team = final_team
	GameManager.deployed_pokemons.clear()
	GameManager.selected_pokemon_to_place = null
	GameManager.current_wave = 0
	GameManager.player_money = 100
	GameManager.player_lives = 10
	GameManager.pokeballs = 5
	GameManager.pokeball_inventory = {"Poké Bola": 5, "Great Ball": 2, "Ultra Ball": 1}
	GameManager.selected_pokeball = "Poké Bola"
	GameManager.inventory_items = {"Poção": 3, "Antídoto": 2, "Despertar": 1}
	GameManager.selected_battle_pokemon = null
	GameManager.game_over = false
	GameManager.stats_changed.emit()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(STARTER_SCENE)
