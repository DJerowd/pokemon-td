extends Node

## Gerencia o estado compartilhado da partida.
## A interface e as cenas devem chamar estes métodos em vez de alterar
## dinheiro, vidas ou inventário diretamente.

signal stats_changed
signal game_over_reached

var player_money: int = 100
var player_lives: int = 10
var current_wave: int = 0
var pokeballs: int = 5
var game_over: bool = false

var captured_pokemons: Array[PokemonData] = []
var active_battle_team: Array[PokemonData] = []
var deployed_pokemons: Array[PokemonData] = []
var selected_pokemon_to_place: PokemonData = null

func add_money(amount: int) -> void:
	# Recompensas negativas não fazem sentido: recuse-as para evitar bugs
	# em que uma chamada incorreta aumenta o saldo.
	if amount <= 0 or game_over:
		return
	player_money += amount
	stats_changed.emit()

func spend_money(amount: int) -> bool:
	# Um custo deve ser positivo e o saldo precisa ser suficiente.
	if amount <= 0 or player_money < amount or game_over:
		return false
	player_money -= amount
	stats_changed.emit()
	return true

func take_damage(amount: int) -> void:
	if amount <= 0 or game_over:
		return
	player_lives = maxi(0, player_lives - amount)
	stats_changed.emit()
	if player_lives == 0:
		game_over = true
		selected_pokemon_to_place = null
		game_over_reached.emit()

func use_pokeball() -> bool:
	# Centraliza o consumo para que nenhuma cena possa deixar o contador negativo.
	if game_over or pokeballs <= 0:
		return false
	pokeballs -= 1
	stats_changed.emit()
	return true

func capture_pokemon(pokemon: PokemonData) -> bool:
	if pokemon == null or game_over:
		return false
	if captured_pokemons.has(pokemon):
		return false
	captured_pokemons.append(pokemon)
	stats_changed.emit()
	return true

func is_pokemon_in_active_team(pokemon: PokemonData) -> bool:
	return pokemon != null and active_battle_team.has(pokemon)

func can_deploy_pokemon(pokemon: PokemonData) -> bool:
	# A equipe selecionada é a lista permitida durante a batalha.
	return not game_over and is_pokemon_in_active_team(pokemon)

func deploy_pokemon(pokemon: PokemonData) -> bool:
	if not can_deploy_pokemon(pokemon):
		return false
	if deployed_pokemons.has(pokemon):
		return false
	deployed_pokemons.append(pokemon)
	return true

func undeploy_pokemon(pokemon: PokemonData) -> void:
	deployed_pokemons.erase(pokemon)
