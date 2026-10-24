extends Node

@export var enemy_scene: PackedScene
@export var path_node: Path2D

var current_wave: int = 0
var enemies_to_spawn: int = 0
var is_wave_active: bool = false

@onready var spawn_timer = Timer.new()

# Sinal emitido quando todos os inimigos da onda forem derrotados
signal wave_completed

func _ready() -> void:
	spawn_timer.wait_time = 1.5
	spawn_timer.timeout.connect(_spawn_single_enemy)
	add_child(spawn_timer)

func start_next_wave() -> void:
	if is_wave_active:
		return
	
	current_wave += 1
	enemies_to_spawn = 3 + (current_wave * 2) # Aumenta a quantidade a cada onda
	is_wave_active = true
	print("Iniciando Onda ", current_wave)
	spawn_timer.start()

func _spawn_single_enemy() -> void:
	if enemies_to_spawn > 0 and enemy_scene and path_node:
		var enemy = enemy_scene.instantiate()
		
		# Garante que o inimigo pertença ao grupo "enemies" para contagem
		if not enemy.is_in_group("enemies"):
			enemy.add_to_group("enemies")
			
		# Adiciona o inimigo (que já é um PathFollow2D) diretamente na trilha
		path_node.add_child(enemy)
		
		# Reseta o progresso para o início da linha
		if enemy is PathFollow2D:
			enemy.progress_ratio = 0.0
		
		enemies_to_spawn -= 1
	else:
		spawn_timer.stop()

# Monitora em tempo real se a onda acabou
func _process(_delta: float) -> void:
	if is_wave_active and enemies_to_spawn == 0:
		# Conta quantos inimigos ainda estão vivos no mapa
		var enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		if enemies_alive == 0:
			is_wave_active = false
			print("Onda ", current_wave, " concluída com sucesso!")
			emit_signal("wave_completed")
