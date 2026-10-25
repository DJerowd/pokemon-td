extends Node

## Gerencia o estado compartilhado da partida.
## A interface e as cenas devem chamar estes métodos em vez de alterar
## dinheiro, vidas ou inventário diretamente.

signal stats_changed
signal game_over_reached
signal team_changed

var player_money: int = 100
var player_lives: int = 10
var current_wave: int = 0
var pokeballs: int = 5
var inventory_items: Dictionary = {"Poção": 3, "Antídoto": 2, "Despertar": 1}
var pokeball_inventory: Dictionary = {"Poké Bola": 5, "Great Ball": 2, "Ultra Ball": 1}
var selected_pokeball: String = "Poké Bola"
var selected_battle_pokemon: PokemonData = null
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

func use_pokeball(ball_name: String = "") -> bool:
	# Mantém compatibilidade com chamadas antigas sem argumento.
	var chosen_ball := ball_name if not ball_name.is_empty() else selected_pokeball
	var amount := int(pokeball_inventory.get(chosen_ball, 0))
	if game_over or amount <= 0:
		return false
	pokeball_inventory[chosen_ball] = amount - 1
	selected_pokeball = chosen_ball
	pokeballs = int(pokeball_inventory.get("Poké Bola", 0))
	stats_changed.emit()
	return true

func cycle_pokeball() -> String:
	var available: Array[String] = []
	for ball_name in pokeball_inventory.keys():
		if int(pokeball_inventory[ball_name]) > 0:
			available.append(str(ball_name))
	if available.is_empty():
		selected_pokeball = ""
	else:
		var current_index := available.find(selected_pokeball)
		selected_pokeball = available[(current_index + 1) % available.size()]
	stats_changed.emit()
	return selected_pokeball

func get_capture_bonus(ball_name: String) -> float:
	match ball_name:
		"Great Ball":
			return 1.25
		"Ultra Ball":
			return 1.5
		_:
			return 1.0

func use_item(item_name: String, target: PokemonData) -> bool:
	if game_over or target == null or int(inventory_items.get(item_name, 0)) <= 0:
		return false
	match item_name:
		"Poção":
			var tower := _find_deployed_tower(target)
			if tower != null and tower.has_method("heal"):
				if not bool(tower.call("heal", 20.0)):
					return false
				target.current_hp = float(tower.get("current_hp"))
			else:
				var max_hp := maxf(1.0, target.hp)
				var current_hp := target.current_hp if target.current_hp > 0.0 else max_hp
				if current_hp >= max_hp:
					return false
				target.current_hp = minf(max_hp, current_hp + 20.0)
		"Antídoto":
			if target.status_condition != "Envenenado":
				return false
			target.status_condition = ""
		"Despertar":
			if target.status_condition != "Adormecido":
				return false
			target.status_condition = ""
		_:
			return false
	inventory_items[item_name] = int(inventory_items[item_name]) - 1
	stats_changed.emit()
	team_changed.emit()
	return true

func capture_pokemon(pokemon: PokemonData) -> bool:
	if pokemon == null or game_over:
		return false
	if captured_pokemons.has(pokemon):
		return false
	captured_pokemons.append(pokemon)
	# Capturas entram automaticamente na equipe ativa enquanto houver espaço.
	# Se os seis espaços já estiverem ocupados, o Pokémon fica no armazenamento.
	if active_battle_team.size() < 6 and not active_battle_team.has(pokemon):
		active_battle_team.append(pokemon)
	stats_changed.emit()
	team_changed.emit()
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
	team_changed.emit()
	return true

func undeploy_pokemon(pokemon: PokemonData) -> void:
	if deployed_pokemons.has(pokemon):
		deployed_pokemons.erase(pokemon)
		team_changed.emit()

func _find_deployed_tower(pokemon: PokemonData) -> Node:
	for candidate in get_tree().get_nodes_in_group("towers"):
		if is_instance_valid(candidate) and candidate.get("pokemon_data") == pokemon:
			return candidate
	return null

## Reinicia os dados voláteis de uma partida sem alterar os recursos cadastrados.
func reset_match() -> void:
	player_money = 100
	player_lives = 10
	current_wave = 0
	pokeballs = 5
	inventory_items = {"Poção": 3, "Antídoto": 2, "Despertar": 1}
	pokeball_inventory = {"Poké Bola": 5, "Great Ball": 2, "Ultra Ball": 1}
	selected_pokeball = "Poké Bola"
	selected_battle_pokemon = null
	game_over = false
	captured_pokemons.clear()
	active_battle_team.clear()
	deployed_pokemons.clear()
	selected_pokemon_to_place = null
	stats_changed.emit()
	team_changed.emit()
