extends Node

@export var enemy_scene: PackedScene
@export var path_node: Path2D
@export var spawn_interval: float = 1.5

var current_wave: int = 0
var enemies_to_spawn: int = 0
var is_wave_active: bool = false
var spawn_failed: bool = false

signal wave_completed
signal wave_start_failed(message: String)

var spawn_timer: Timer

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
	enemies_to_spawn = 3 + current_wave * 2
	spawn_failed = false
	is_wave_active = true
	print("Iniciando onda ", current_wave, " (", enemies_to_spawn, " inimigos).")
	_spawn_single_enemy()
	if is_wave_active and enemies_to_spawn > 0:
		spawn_timer.start()
	return true

func _spawn_single_enemy() -> void:
	if not is_wave_active:
		spawn_timer.stop()
		return
	if enemies_to_spawn <= 0:
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

	# Dados mínimos tornam HP e captura previsíveis até existir uma tabela de inimigos.
	var wild_data := PokemonData.new()
	wild_data.species_name = "Pokémon selvagem"
	wild_data.hp = 50.0 + current_wave * 5.0
	wild_data.attack = 40.0
	enemy.pokemon_data = wild_data
	path_node.add_child(enemy)
	enemy.progress_ratio = 0.0
	enemies_to_spawn -= 1

	if enemies_to_spawn <= 0:
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
