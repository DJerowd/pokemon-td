extends Button

var pokemon_data: Resource

func _ready() -> void:
	pressed.connect(_on_card_pressed)

func _on_card_pressed() -> void:
	if pokemon_data:
		GameManager.selected_pokemon_to_place = pokemon_data
		print("Pokémon selecionado para o combate: ", pokemon_data.species_name)
