extends Control

@onready var lbl_money: Label = %LblMoney
@onready var lbl_lives: Label = %LblLives
@onready var lbl_wave: Label = %LblWave

func _ready() -> void:
	update_hud_stats()
	# Atualiza a interface por sinal, sem consultar o estado a cada frame.
	GameManager.stats_changed.connect(update_hud_stats)

func update_hud_stats() -> void:
	if lbl_money:
		lbl_money.text = "💰 P$: " + str(GameManager.player_money)
	if lbl_lives:
		lbl_lives.text = "❤️ Vidas: " + str(GameManager.player_lives)
	if lbl_wave:
		lbl_wave.text = "🌊 Onda: " + str(GameManager.current_wave)
