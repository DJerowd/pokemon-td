extends Area2D

var occupied: bool = false
var current_tower: Node2D = null

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	# Feedback visual: slots aparecem apenas durante o posicionamento.
	visible = GameManager.selected_pokemon_to_place != null and not GameManager.game_over

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var pokemon: PokemonData = GameManager.selected_pokemon_to_place
	if pokemon == null:
		return
	if GameManager.game_over or not GameManager.can_deploy_pokemon(pokemon):
		GameManager.selected_pokemon_to_place = null
		return
	if occupied:
		print("Este espaço já está ocupado.")
		return

	# Move a torre existente antes de criar a nova, para impedir cópias da mesma espécie.
	relocate_existing_pokemon(pokemon)
	if place_pokemon(pokemon):
		GameManager.selected_pokemon_to_place = null
		get_viewport().set_input_as_handled()

func relocate_existing_pokemon(pokemon_data: PokemonData) -> void:
	var towers_node := get_tree().current_scene.find_child("Towers", true, false)
	if towers_node == null:
		return
	for tower in towers_node.get_children():
		if tower.get("pokemon_data") == pokemon_data:
			# queue_free libera o slot no _exit_tree; liberamos também agora
			# porque a nova torre será criada antes do próximo frame.
			var old_slot = tower.get("slot_reference")
			if old_slot and is_instance_valid(old_slot):
				old_slot.occupied = false
				old_slot.current_tower = null
			towers_node.remove_child(tower) # _exit_tree libera o registro antes do novo deploy.
			tower.queue_free()
			break

func place_pokemon(pokemon_data: PokemonData) -> bool:
	var towers_node := get_tree().current_scene.find_child("Towers", true, false) as Node2D
	if towers_node == null:
		push_error("Não foi encontrado o nó Towers na cena de jogo.")
		return false

	var tower_scene := load("res://scenes/entities/PokemonTower.tscn") as PackedScene
	if tower_scene == null:
		push_error("Não foi possível carregar PokemonTower.tscn.")
		return false
	var tower := tower_scene.instantiate() as Node2D
	if tower == null:
		push_error("A raiz de PokemonTower.tscn precisa ser Node2D.")
		return false

	tower.set("pokemon_data", pokemon_data)
	tower.set("slot_reference", self)
	tower.z_index = 10
	towers_node.add_child(tower)
	tower.global_position = global_position
	occupied = true
	current_tower = tower
	if not GameManager.deployed_pokemons.has(pokemon_data):
		GameManager.deployed_pokemons.append(pokemon_data)
	print("Pokémon ", pokemon_data.species_name, " posicionado.")
	return true
