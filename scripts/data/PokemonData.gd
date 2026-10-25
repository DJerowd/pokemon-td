class_name PokemonData
extends Resource

# NONE representa explicitamente a ausência de segundo tipo.
enum Type { NORMAL, FIRE, WATER, GRASS, ELECTRIC, ICE, FIGHTING, POISON, GROUND, FLYING, PSYCHIC, BUG, ROCK, GHOST, DRAGON, NONE }

@export_category("Informações Básicas")
@export var id: int = 1
@export var species_name: String = "Bulbasaur"
@export var level: int = 5
@export var primary_type: Type = Type.GRASS
@export var secondary_type: Type = Type.NONE
@export var sprite: Texture2D
@export var shiny_sprite: Texture2D

@export_category("Configuração do Sprite Sheet (Overworld)")
@export var sprite_origin: Vector2 = Vector2.ZERO
@export var frame_size: Vector2 = Vector2(32, 32)

@export_category("Estatísticas Base")
@export var hp: float = 45.0
@export var current_hp: float = 0.0
@export var status_condition: String = ""
@export var attack: float = 49.0
@export var special_attack: float = 65.0
@export var defense: float = 49.0
@export var special_defense: float = 65.0
@export var speed: float = 45.0
@export var attack_range: float = 150.0
## Número de ataques por segundo, não segundos entre ataques.
@export var attack_speed: float = 1.0

@export_category("Passiva e Equipamento")
@export var ability: String = ""
@export var held_item: String = ""

@export_category("Sistema de Golpes (Até 4)")
@export var available_moves: Array[String] = ["Investida", "Chicote de Cipó", "", ""]
@export var active_move_index: int = 0

func get_frame_region(direction_row: int, frame_column: int) -> Rect2:
	# Converte a origem e o índice do frame em um retângulo da textura.
	return Rect2(
		sprite_origin.x + frame_column * frame_size.x,
		sprite_origin.y + direction_row * frame_size.y,
		frame_size.x,
		frame_size.y
	)

func get_active_move() -> String:
	if available_moves.is_empty():
		return "Investida"
	var index := clampi(active_move_index, 0, available_moves.size() - 1)
	if available_moves[index].is_empty():
		return "Investida"
	return available_moves[index]
