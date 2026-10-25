extends Control

const SPRITE_SHEET_PATH := "res://assets/textures/DS _ DSi - Pokemon Black 2 _ White 2 - Overworld - Pokemon (Overworld).png"
const SPRITE_FRAME_SIZE := Vector2(32, 32)
const SPRITE_FACTORY = preload("res://scripts/data/SpriteFrameFactory.gd")

@onready var title_label: Label = $TitleLabel
@onready var pokeball_buttons: Array[TextureButton] = [%Pokeball1, %Pokeball2, %Pokeball3]
@onready var dialogue_label: Label = $DialogueBox/DialogueLabel
@onready var choices_container: HBoxContainer = $DialogueBox/ChoicesContainer
@onready var btn_yes: Button = $DialogueBox/ChoicesContainer/BtnYes
@onready var btn_no: Button = $DialogueBox/ChoicesContainer/BtnNo
@onready var btn_left: Button = $BtnLeft
@onready var btn_right: Button = $BtnRight
@onready var preview_name: Label = $HoverPreviewPanel/PreviewContent/PreviewName
@onready var preview_sprite: TextureRect = $HoverPreviewPanel/PreviewContent/PreviewSprite

var current_gen_index: int = 0
var selected_pokemon_info: Dictionary = {}
var waiting_for_confirmation: bool = false
var sprite_sheet: Texture2D

func _ready() -> void:
	sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	_add_background_tint()
	choices_container.hide()
	$HoverPreviewPanel.hide()
	_style_screen()
	btn_left.pressed.connect(_on_previous_generation)
	btn_right.pressed.connect(_on_next_generation)
	btn_yes.pressed.connect(_on_yes_pressed)
	btn_no.pressed.connect(_on_no_pressed)
	for index in range(pokeball_buttons.size()):
		var button := pokeball_buttons[index]
		button.mouse_entered.connect(on_pokeball_hover.bind(index))
		button.pressed.connect(on_pokeball_clicked.bind(index))
	update_ui()

func _add_background_tint() -> void:
	var tint := ColorRect.new()
	tint.name = "Black2BlueTint"
	tint.color = Color(0.015, 0.055, 0.12, 0.24)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tint)
	move_child(tint, 1)

func _style_screen() -> void:
	title_label.add_theme_color_override("font_color", Color(0.78, 0.94, 1.0))
	title_label.add_theme_font_size_override("font_size", 26)
	preview_name.add_theme_color_override("font_color", Color(0.35, 0.88, 1.0))
	preview_name.add_theme_font_size_override("font_size", 20)
	preview_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_sprite.custom_minimum_size = Vector2(96, 96)
	preview_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.09, 0.18, 0.94)
	panel_style.border_color = Color(0.15, 0.78, 1.0, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_top = 8.0
	panel_style.content_margin_bottom = 8.0
	$HoverPreviewPanel.add_theme_stylebox_override("panel", panel_style)
	$HoverPreviewPanel.custom_minimum_size = Vector2(148, 132)
	$HoverPreviewPanel.position = Vector2(22, 58)
	dialogue_label.add_theme_color_override("font_color", Color(0.92, 0.97, 1.0))
	dialogue_label.add_theme_font_size_override("font_size", 18)
	for button in [btn_left, btn_right, btn_yes, btn_no]:
		button.add_theme_color_override("font_color", Color(0.9, 0.97, 1.0))
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.04, 0.19, 0.32, 0.96)
		normal.border_color = Color(0.16, 0.72, 1.0)
		normal.set_border_width_all(2)
		normal.set_corner_radius_all(6)
		button.add_theme_stylebox_override("normal", normal)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.08, 0.35, 0.52, 1.0)
		hover.border_color = Color(0.5, 0.95, 1.0)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", hover)

func update_ui() -> void:
	if StarterDatabase.generations.is_empty():
		title_label.text = "Nenhum inicial disponível"
		return
	var generation: Dictionary = StarterDatabase.generations[current_gen_index]
	title_label.text = "ESCOLHA SEU INICIAL  •  %s" % str(generation.get("region", "Região desconhecida"))
	if not waiting_for_confirmation:
		choices_container.hide()
		dialogue_label.text = "Escolha uma Pokébola para conhecer seu parceiro."

func _create_starter_texture(starter: Dictionary) -> Texture2D:
	if sprite_sheet == null:
		return null
	var origin: Vector2 = starter.get("sprite_origin", Vector2.ZERO)
	var rect := Rect2(origin, SPRITE_FRAME_SIZE)
	var bounds := Rect2(Vector2.ZERO, sprite_sheet.get_size())
	if origin.x < 0.0 or origin.y < 0.0 or not bounds.encloses(rect):
		return null
	return SPRITE_FACTORY.make_frame(sprite_sheet, rect)

func _on_previous_generation() -> void:
	change_generation(-1)

func _on_next_generation() -> void:
	change_generation(1)

func change_generation(direction: int) -> void:
	if waiting_for_confirmation or StarterDatabase.generations.is_empty():
		return
	current_gen_index = posmod(current_gen_index + direction, StarterDatabase.generations.size())
	update_ui()

func on_pokeball_hover(index: int) -> void:
	if waiting_for_confirmation:
		return
	var starters: Array = StarterDatabase.generations[current_gen_index].get("starters", [])
	if index < 0 or index >= starters.size() or not starters[index] is Dictionary:
		return
	var starter: Dictionary = starters[index]
	var starter_name := str(starter.get("name", "Pokémon desconhecido"))
	var starter_type := str(starter.get("type", "Tipo desconhecido"))
	dialogue_label.text = "%s  •  Tipo: %s\nHP %d | Atq %d | Def %d | Vel %d" % [
		starter_name, starter_type, int(starter.get("hp", 0)),
		int(starter.get("attack", 0)), int(starter.get("defense", 0)),
		int(starter.get("speed", 0))
	]
	# A prévia de sprite só aparece após clicar em uma Pokébola.

func on_pokeball_clicked(index: int) -> void:
	if waiting_for_confirmation:
		return
	var starters: Array = StarterDatabase.generations[current_gen_index].get("starters", [])
	if index < 0 or index >= starters.size() or not starters[index] is Dictionary:
		return
	var starter: Dictionary = starters[index]
	if not starter.has("name"):
		push_warning("Não foi possível selecionar o Pokémon: dados incompletos.")
		return
	selected_pokemon_info = starter
	waiting_for_confirmation = true
	preview_name.text = str(starter.get("name", "Pokémon"))
	preview_sprite.texture = _create_starter_texture(starter)
	if preview_sprite.texture == null:
		dialogue_label.text = "%s não tem um recorte de sprite verificado nesta spritesheet.\nTipo: %s | HP %d | Atq %d | Def %d | Vel %d" % [
			str(starter.get("name", "Pokémon")), str(starter.get("type", "Normal")),
			int(starter.get("hp", 0)), int(starter.get("attack", 0)),
			int(starter.get("defense", 0)), int(starter.get("speed", 0))
		]
	$HoverPreviewPanel.show()
	$HoverPreviewPanel.scale = Vector2(0.92, 0.92)
	var preview_tween := create_tween()
	preview_tween.set_trans(Tween.TRANS_BACK)
	preview_tween.set_ease(Tween.EASE_OUT)
	preview_tween.tween_property($HoverPreviewPanel, "scale", Vector2.ONE, 0.2)
	if preview_sprite.texture != null:
		dialogue_label.text = "Deseja escolher %s?\nTipo: %s • HP %d • Atq %d • Def %d • Vel %d" % [
			str(starter.get("name", "este Pokémon")), str(starter.get("type", "Normal")),
			int(starter.get("hp", 0)), int(starter.get("attack", 0)),
			int(starter.get("defense", 0)), int(starter.get("speed", 0))
		]
	else:
		dialogue_label.text += "\nDeseja escolher este inicial?"
	btn_yes.text = "SIM"
	btn_no.text = "VOLTAR"
	choices_container.show()

func _on_yes_pressed() -> void:
	if selected_pokemon_info.is_empty():
		return
	var starter_data := StarterDatabase.create_pokemon_data(str(selected_pokemon_info.get("name", "Pokémon")), 5, selected_pokemon_info)
	starter_data.sprite = _create_starter_texture(selected_pokemon_info)
	GameManager.captured_pokemons.clear()
	GameManager.capture_pokemon(starter_data)
	GameManager.active_battle_team.clear()
	GameManager.stats_changed.emit()
	get_tree().change_scene_to_file("res://scenes/ui/TeamSelectScene.tscn")

func _species_id(species_name: String) -> int:
	return absi(species_name.to_lower().hash()) % 100000

func _on_no_pressed() -> void:
	waiting_for_confirmation = false
	selected_pokemon_info.clear()
	choices_container.hide()
	btn_yes.text = "SIM"
	btn_no.text = "VOLTAR"
	preview_name.text = ""
	preview_sprite.texture = null
	$HoverPreviewPanel.hide()
	$HoverPreviewPanel.scale = Vector2.ONE
	update_ui()

