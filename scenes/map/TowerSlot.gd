extends Area2D

var occupied: bool = false
var current_tower: Node2D = null

func _ready() -> void:
	# O slot começa invisível até que o jogador selecione um Pokémon para posicionar
	visible = false

func _process(_delta: float) -> void:
	# O slot só fica visível se houver um Pokémon selecionado na barra inferior
	visible = (GameManager.selected_pokemon_to_place != null)

# O Godot 2D detecta cliques em nós Area2D se 'Input Pickable' estiver ativado no Inspetor
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Só prossegue se houver um Pokémon selecionado para posicionar
		if GameManager.selected_pokemon_to_place == null:
			return
			
		var pokemon = GameManager.selected_pokemon_to_place
		
		# Se este slot específico já estiver ocupado por outra torre, não faz nada
		if occupied:
			print("Este slot já está ocupado!")
			return
			
		# NOVO: Se o Pokémon já estiver posicionado em outro slot, removemos ele de lá primeiro (Relocação)
		relocate_existing_pokemon(pokemon)
		
		# Posiciona a torre neste novo slot
		place_pokemon(pokemon)
		
		# Desseleciona o Pokémon automaticamente após o posicionamento
		GameManager.selected_pokemon_to_place = null
		get_viewport().set_input_as_handled()

# Função para encontrar e mover a torre caso o Pokémon já esteja no mapa
func relocate_existing_pokemon(pokemon_data: Resource) -> void:
	var towers_node = get_tree().current_scene.find_child("Towers", true, false)
	if towers_node:
		for tower in towers_node.get_children():
			if "pokemon_data" in tower and tower.pokemon_data == pokemon_data:
				# Libera o slot antigo onde a torre estava
				if "slot_reference" in tower and tower.slot_reference and is_instance_valid(tower.slot_reference):
					tower.slot_reference.occupied = false
					tower.slot_reference.current_tower = null
				# Remove a torre antiga do mapa
				tower.queue_free()
				break
				
	# Remove temporariamente da lista de deployed para evitar duplicatas na lista global
	if pokemon_data in GameManager.deployed_pokemons:
		GameManager.deployed_pokemons.erase(pokemon_data)

func place_pokemon(pokemon_data: Resource) -> void:
	occupied = true
	GameManager.deployed_pokemons.append(pokemon_data)
	
	# Carrega e instancia a torre do Pokémon
	var tower_scene = load("res://scenes/entities/PokemonTower.tscn")
	if tower_scene:
		var tower = tower_scene.instantiate()
		tower.pokemon_data = pokemon_data
		tower.global_position = global_position # Posiciona exatamente no centro do slot
		tower.slot_reference = self # Guarda referência para liberar o slot caso o Pokémon saia
		
		# GARANTE A SOBREPOSIÇÃO: Z-Index maior faz a torre aparecer por cima do slot
		tower.z_index = 10
		
		# Adiciona ao container de torres na cena principal
		var towers_node = get_tree().current_scene.find_child("Towers", true, false)
		if towers_node:
			towers_node.add_child(tower)
		else:
			get_tree().current_scene.add_child(tower)
			
		current_tower = tower
		print("Pokémon ", pokemon_data.species_name, " posicionado com sucesso no slot!")
