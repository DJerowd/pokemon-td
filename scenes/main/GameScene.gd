extends Node2D

@export var enemy_scene: PackedScene
@export var tower_scene: PackedScene

@onready var path_node: Path2D = $MapWorld/TileMapLayer/Path2D
@onready var enemies_container: Node2D = $MapWorld/Enemies
@onready var towers_container: Node2D = $MapWorld/Towers
@onready var wave_manager = $Managers/WaveManager
@onready var btn_start_wave: Button = $UI/HUD/TopBar/BtnStartWave

func _ready() -> void:
	if wave_manager == null:
		push_error("GameScene: WaveManager não encontrado.")
		return

	wave_manager.enemy_scene = enemy_scene
	wave_manager.path_node = path_node
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.wave_start_failed.connect(_on_wave_start_failed)

	if btn_start_wave:
		btn_start_wave.pressed.connect(_on_btn_start_wave_pressed)
	GameManager.game_over_reached.connect(_on_game_over_reached)
	GameManager.stats_changed.connect(_refresh_hud_state)
	_refresh_hud_state()

func _on_btn_start_wave_pressed() -> void:
	if wave_manager == null or GameManager.game_over:
		return
	if wave_manager.start_next_wave():
		btn_start_wave.disabled = true
		_refresh_hud_state()

func _on_wave_completed() -> void:
	_refresh_hud_state()
	print("Onda concluída; botão liberado para a próxima.")

func _on_wave_start_failed(message: String) -> void:
	push_warning(message)
	_refresh_hud_state()

func _on_game_over_reached() -> void:
	if btn_start_wave:
		btn_start_wave.disabled = true
	print("Fim de jogo. Reinicie a partida para tentar novamente.")

func _refresh_hud_state() -> void:
	if btn_start_wave:
		btn_start_wave.disabled = GameManager.game_over or (wave_manager != null and wave_manager.is_wave_active)
