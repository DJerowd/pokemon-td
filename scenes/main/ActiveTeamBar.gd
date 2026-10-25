extends HBoxContainer

const SPRITE_SHEET_PATH := "res://assets/textures/DS _ DSi - Pokemon Black 2 _ White 2 - Overworld - Pokemon (Overworld).png"
const SPRITE_FACTORY = preload("res://scripts/data/SpriteFrameFactory.gd")

var sprite_sheet: Texture2D

func _ready() -> void:
	sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	populate_bar()
	if not GameManager.team_changed.is_connected(populate_bar):
		GameManager.team_changed.connect(populate_bar)

func populate_bar() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for pokemon in GameManager.active_battle_team:
		if pokemon == null or GameManager.deployed_pokemons.has(pokemon):
			continue
		var card := Button.new()
		card.text = "%s\nNv. %d" % [pokemon.species_name, pokemon.level]
		card.custom_minimum_size = Vector2(92, 72)
		card.tooltip_text = "Selecione e clique em um espaço vazio do mapa."
		card.icon = _get_pokemon_sprite(pokemon)
		card.expand_icon = true
		card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		card.add_theme_font_size_override("font_size", 11)
		card.add_theme_color_override("font_color", Color(0.9, 0.97, 1.0))
		card.pressed.connect(_on_pokemon_pressed.bind(pokemon))
		add_child(card)

func _get_pokemon_sprite(pokemon: PokemonData) -> Texture2D:
	if pokemon.sprite != null:
		return pokemon.sprite
	if sprite_sheet == null:
		return null
	var frame_size := pokemon.frame_size if pokemon.frame_size.x > 0.0 else Vector2(32, 32)
	var rect := Rect2(pokemon.sprite_origin, frame_size)
	var texture := SPRITE_FACTORY.make_frame(sprite_sheet, rect)
	pokemon.sprite = texture
	return texture

func _on_pokemon_pressed(pokemon: PokemonData) -> void:
	if GameManager.can_deploy_pokemon(pokemon) and not GameManager.deployed_pokemons.has(pokemon):
		GameManager.selected_pokemon_to_place = pokemon
