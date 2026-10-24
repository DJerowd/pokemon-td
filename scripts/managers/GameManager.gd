extends Node

# Recursos globais da partida
var player_money: int = 100
var player_lives: int = 10
var current_wave: int = 0

# Inventário do Jogador (Pokémon capturados)
var captured_pokemons = []

# Time ativo selecionado para a batalha (1 a 6 Pokémon)
var active_battle_team = []

# Nova lista para controlar quais Pokémon do time já estão posicionados no mapa
var deployed_pokemons = []

# Armazena o Pokémon selecionado na barra inferior para posicionamento
var selected_pokemon_to_place = null

func add_money(amount: int) -> void:
	player_money += amount
	print("Dinheiro atual: ", player_money)

func spend_money(amount: int) -> bool:
	if player_money >= amount:
		player_money -= amount
		return true
	return false

func take_damage(amount: int) -> void:
	player_lives -= amount
	if player_lives <= 0:
		print("Game Over!")
		# Lógica de fim de jogo
