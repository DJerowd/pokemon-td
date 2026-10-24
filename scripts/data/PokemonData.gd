class_name PokemonData
extends Resource

enum Type { NORMAL, FIRE, WATER, GRASS, ELECTRIC, ICE, FIGHTING, POISON, GROUND, FLYING, PSYCHIC, BUG, ROCK, GHOST, DRAGON }

@export_category("Informações Básicas")
@export var id: int = 1
@export var species_name: String = "Bulbasaur"
@export var level: int = 5
@export var primary_type: Type = Type.GRASS
@export var secondary_type: Type = Type.POISON
@export var sprite: Texture2D
@export var shiny_sprite: Texture2D

@export_category("Configuração do Sprite Sheet (Overworld)")
@export var sprite_origin: Vector2 = Vector2(0, 32) # Posição (X, Y) inicial do Pokémon no Sheet
@export var frame_size: Vector2 = Vector2(32, 32)   # Tamanho de cada frame (geralmente 32x32)

@export_category("Estatísticas Base")
@export var hp: float = 45.0
@export var attack: float = 49.0
@export var special_attack: float = 65.0
@export var defense: float = 49.0
@export var special_defense: float = 65.0
@export var speed: float = 45.0          # Velocidade base do Pokémon
@export var attack_range: float = 150.0   # Alcance da torre no mapa
@export var attack_speed: float = 1.0     # Frequência de ataques por segundo

@export_category("Passiva e Equipamento")
@export var ability: String = "Chlorophyll"
@export var held_item: String = "" # Ex: "Leftovers", "Choice Specs"

@export_category("Sistema de Golpes (Até 4)")
@export var available_moves: Array[String] = ["Investida", "Chicote de Cipó", "", ""]
@export var active_move_index: int = 0 # Índice de 0 a 3 do golpe selecionado atualmente

# Método utilitário para calcular a região exata de cada frame
func get_frame_region(direction_row: int, frame_column: int) -> Rect2:
	var posX = sprite_origin.x + (frame_column * frame_size.x)
	var posY = sprite_origin.y + (direction_row * frame_size.y)
	return Rect2(posX, posY, frame_size.x, frame_size.y)
