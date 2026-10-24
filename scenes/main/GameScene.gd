extends Node2D

@export var enemy_scene: PackedScene # Arraste Enemy.tscn aqui no Inspector
@export var tower_scene: PackedScene # Arraste PokemonTower.tscn aqui no Inspector

@onready var path_node = $MapWorld/TileMapLayer/Path2D
@onready var enemies_container = $MapWorld/Enemies
@onready var towers_container = $MapWorld/Towers
@onready var wave_manager = $Managers/WaveManager
@onready var btn_start_wave = $UI/HUD/TopBar/BtnStartWave

func _ready() -> void:
	if wave_manager:
		wave_manager.enemy_scene = enemy_scene
		wave_manager.path_node = path_node
		
		# Conecta o sinal de onda concluída para reativar o botão
		if not wave_manager.is_connected("wave_completed", _on_wave_completed):
			wave_manager.connect("wave_completed", _on_wave_completed)
	
	if btn_start_wave:
		if not btn_start_wave.pressed.is_connected(_on_btn_start_wave_pressed):
			btn_start_wave.pressed.connect(_on_btn_start_wave_pressed)

func _on_btn_start_wave_pressed() -> void:
	if wave_manager and wave_manager.has_method("start_next_wave"):
		GameManager.current_wave += 1
		btn_start_wave.disabled = true
		print("Iniciando Onda ", GameManager.current_wave)
		wave_manager.start_next_wave()

func _on_wave_completed() -> void:
	if btn_start_wave:
		btn_start_wave.disabled = false # Reativa o botão para a próxima onda
		print("Botão de iniciar onda liberado!")
