extends Node

@export var enemy_scene: PackedScene
@export var path_node: Path2D
@export var spawn_interval: float = 1.5

var current_wave: int = 0
var enemies_to_spawn: int = 0
var is_wave_active: bool = false
var spawn_failed: bool = false
var spawn_queue: Array[Dictionary] = []

signal wave_completed
signal wave_start_failed(message: String)

var spawn_timer: Timer

# Roster pré-programado: cada inimigo tem espécie, estatísticas, sprite e
# política de captura próprios. O último membro de algumas ondas é especial.
var wave_rosters: Array = [
	[
		{"name":"Bulbasaur","origin":Vector2(0, 32),"hp":40,"speed":90.0,"capturable":true,"capture_rate":0.85,"reward":25,"type":PokemonData.Type.GRASS},
		{"name":"Charmander","origin":Vector2(256, 32),"hp":36,"speed":112.0,"capturable":true,"capture_rate":0.8,"reward":25,"type":PokemonData.Type.FIRE},
		{"name":"Squirtle","origin":Vector2(448, 32),"hp":48,"speed":82.0,"capturable":true,"capture_rate":0.9,"reward":30,"type":PokemonData.Type.WATER},
		{"name":"Chikorita","origin":Vector2(0, 128),"hp":55,"speed":76.0,"capturable":true,"capture_rate":0.7,"reward":35,"type":PokemonData.Type.GRASS,"status":"Envenenado"},
		{"name":"Rival Bulbasaur","origin":Vector2(0, 32),"hp":90,"speed":72.0,"capturable":false,"capture_rate":0.0,"reward":70,"type":PokemonData.Type.GRASS}
	],
	[
		{"name":"Cyndaquil","origin":Vector2(192, 128),"hp":58,"speed":118.0,"capturable":true,"capture_rate":0.8,"reward":35,"type":PokemonData.Type.FIRE},
		{"name":"Totodile","origin":Vector2(384, 128),"hp":72,"speed":84.0,"capturable":true,"capture_rate":0.75,"reward":40,"type":PokemonData.Type.WATER},
		{"name":"Treecko","origin":Vector2(192, 2432),"hp":62,"speed":132.0,"capturable":true,"capture_rate":0.7,"reward":40,"type":PokemonData.Type.GRASS},
		{"name":"Torchic","origin":Vector2(384, 2432),"hp":66,"speed":110.0,"capturable":true,"capture_rate":0.72,"reward":40,"type":PokemonData.Type.FIRE},
		{"name":"Guardião Johto","origin":Vector2(384, 128),"hp":155,"speed":70.0,"capturable":false,"capture_rate":0.0,"reward":110,"type":PokemonData.Type.WATER,"status":"Adormecido"}
	],
	[
		{"name":"Mudkip","origin":Vector2(576, 2432),"hp":84,"speed":88.0,"capturable":true,"capture_rate":0.72,"reward":45,"type":PokemonData.Type.WATER},
		{"name":"Turtwig","origin":Vector2(0, 3488),"hp":94,"speed":76.0,"capturable":true,"capture_rate":0.7,"reward":50,"type":PokemonData.Type.GRASS},
		{"name":"Chimchar","origin":Vector2(192, 3488),"hp":78,"speed":126.0,"capturable":true,"capture_rate":0.68,"reward":50,"type":PokemonData.Type.FIRE},
		{"name":"Piplup","origin":Vector2(384, 3488),"hp":90,"speed":90.0,"capturable":true,"capture_rate":0.68,"reward":50,"type":PokemonData.Type.WATER},
		{"name":"Sentinela Sinnoh","origin":Vector2(0, 3488),"hp":230,"speed":62.0,"capturable":false,"capture_rate":0.0,"reward":160,"type":PokemonData.Type.GRASS,"status":"Envenenado"}
	],
	[
		{"name":"Snivy","origin":Vector2(0, 4800),"hp":102,"speed":140.0,"capturable":true,"capture_rate":0.65,"reward":60,"type":PokemonData.Type.GRASS},
		{"name":"Tepig","origin":Vector2(192, 4800),"hp":118,"speed":98.0,"capturable":true,"capture_rate":0.65,"reward":60,"type":PokemonData.Type.FIRE},
		{"name":"Oshawott","origin":Vector2(384, 4800),"hp":108,"speed":112.0,"capturable":true,"capture_rate":0.65,"reward":60,"type":PokemonData.Type.WATER},
		{"name":"Elite Unova","origin":Vector2(384, 4800),"hp":320,"speed":68.0,"capturable":false,"capture_rate":0.0,"reward":220,"type":PokemonData.Type.WATER,"status":"Adormecido"}
	]
]

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = maxf(0.1, spawn_interval)
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_spawn_single_enemy)
	add_child(spawn_timer)

func start_next_wave() -> bool:
	if is_wave_active or GameManager.game_over:
		return false
	if enemy_scene == null or path_node == null:
		push_error("WaveManager: configure enemy_scene e path_node no Inspector.")
		wave_start_failed.emit("Cena de inimigo ou caminho não configurado.")
		return false
	current_wave += 1
	GameManager.current_wave = current_wave
	GameManager.stats_changed.emit()
	var roster_index := mini(current_wave - 1, wave_rosters.size() - 1)
	spawn_queue.clear()
	for entry in wave_rosters[roster_index]:
		var profile: Dictionary = entry.duplicate(true)
		if current_wave > wave_rosters.size():
			var extra_scale := 1.0 + float(current_wave - wave_rosters.size()) * 0.22
			profile["hp"] = float(profile.get("hp", 50.0)) * extra_scale
			profile["reward"] = int(profile.get("reward", 25)) + (current_wave - wave_rosters.size()) * 10
		spawn_queue.append(profile)
	enemies_to_spawn = spawn_queue.size()
	spawn_failed = false
	is_wave_active = true
	print("Iniciando onda ", current_wave, " com roster pré-programado (", enemies_to_spawn, " Pokémon).")
	_spawn_single_enemy()
	if is_wave_active and enemies_to_spawn > 0:
		spawn_timer.start()
	return true

func _spawn_single_enemy() -> void:
	if GameManager.game_over:
		spawn_timer.stop()
		is_wave_active = false
		return
	if not is_wave_active:
		spawn_timer.stop()
		return
	if spawn_queue.is_empty():
		spawn_timer.stop()
		return
	if enemy_scene == null or path_node == null:
		_fail_wave("Dependência de spawn ausente durante a onda.")
		return
	var enemy := enemy_scene.instantiate()
	if not (enemy is PathFollow2D):
		enemy.free()
		_fail_wave("A cena de inimigo precisa ter PathFollow2D como nó raiz.")
		return
	var profile: Dictionary = spawn_queue.pop_front()
	var species_name := str(profile.get("name", "Pokémon"))
	var species_overrides := {
		"hp": float(profile.get("hp", 50.0)),
		"display_name": species_name
	}
	var species_exists := not StarterDatabase.get_species(species_name).is_empty()
	var wild_data := StarterDatabase.create_pokemon_data(species_name, 3 + current_wave * 2, species_overrides)
	if not species_exists:
		# Variantes especiais reutilizam os dados e o sprite de uma espécie-base,
		# mantendo nome e atributos específicos do encontro.
		var fallback_overrides := species_overrides.duplicate()
		fallback_overrides["sprite_origin"] = profile.get("origin", Vector2.ZERO)
		wild_data = StarterDatabase.create_pokemon_data("Bulbasaur", 3 + current_wave * 2, fallback_overrides)
	wild_data.current_hp = wild_data.hp
	wild_data.attack = 8.0 + current_wave * 2.0

	enemy.set("pokemon_data", wild_data)
	enemy.set("max_hp", wild_data.hp)
	enemy.set("speed", float(profile.get("speed", 100.0)))
	enemy.set("can_be_captured", bool(profile.get("capturable", true)))
	enemy.set("capture_rate", float(profile.get("capture_rate", 0.75)))
	enemy.set("reward_money", int(profile.get("reward", 25)))
	enemy.set("status_inflicted", str(profile.get("status", "")))
	enemy.set("progress_ratio", 0.0)
	path_node.add_child(enemy)
	enemies_to_spawn = spawn_queue.size()
	if spawn_queue.is_empty():
		spawn_timer.stop()

func _fail_wave(message: String) -> void:
	spawn_timer.stop()
	is_wave_active = false
	spawn_failed = true
	push_error("WaveManager: " + message)
	wave_start_failed.emit(message)

func _process(_delta: float) -> void:
	if not is_wave_active or enemies_to_spawn > 0:
		return
	if get_tree().get_nodes_in_group("enemies").is_empty():
		is_wave_active = false
		print("Onda ", current_wave, " concluída.")
		wave_completed.emit()
