extends Control

@onready var lbl_money: Label = %LblMoney
@onready var lbl_lives: Label = %LblLives
@onready var lbl_wave: Label = %LblWave
@onready var lbl_selected_ball: Label = %LblSelectedBall
@onready var btn_cycle_ball: Button = %BtnCycleBall
@onready var btn_potion: Button = %BtnPotion
@onready var btn_status_heal: Button = %BtnStatusHeal

func _ready() -> void:
	update_hud_stats()
	# Atualiza a interface por sinal, sem consultar o estado a cada frame.
	GameManager.stats_changed.connect(update_hud_stats)
	btn_cycle_ball.pressed.connect(_on_cycle_ball_pressed)
	btn_potion.pressed.connect(_on_potion_pressed)
	btn_status_heal.pressed.connect(_on_status_heal_pressed)

func update_hud_stats() -> void:
	if lbl_money:
		lbl_money.text = "💰 P$: " + str(GameManager.player_money)
	if lbl_lives:
		lbl_lives.text = "❤️ Vidas: " + str(GameManager.player_lives)
	if lbl_wave:
		lbl_wave.text = "🌊 Onda: " + str(GameManager.current_wave)
	if lbl_selected_ball:
		var ball_name := GameManager.selected_pokeball if not GameManager.selected_pokeball.is_empty() else "Sem Pokébolas"
		lbl_selected_ball.text = "%s: %d" % [ball_name, int(GameManager.pokeball_inventory.get(ball_name, 0))]
	if btn_potion:
		btn_potion.text = "Poção (%d)" % int(GameManager.inventory_items.get("Poção", 0))
		btn_potion.disabled = GameManager.selected_battle_pokemon == null or int(GameManager.inventory_items.get("Poção", 0)) <= 0
	if btn_status_heal:
		btn_status_heal.text = "Status A:%d D:%d" % [int(GameManager.inventory_items.get("Antídoto", 0)), int(GameManager.inventory_items.get("Despertar", 0))]
		var target: PokemonData = GameManager.selected_battle_pokemon
		btn_status_heal.disabled = target == null or target.status_condition not in ["Envenenado", "Adormecido"] or (int(GameManager.inventory_items.get("Antídoto", 0)) <= 0 and int(GameManager.inventory_items.get("Despertar", 0)) <= 0)

func _on_cycle_ball_pressed() -> void:
	var chosen := GameManager.cycle_pokeball()
	if chosen.is_empty():
		print("Você não possui Pokébolas disponíveis.")
	else:
		print("Pokébola selecionada: ", chosen)
	update_hud_stats()

func _on_potion_pressed() -> void:
	if GameManager.selected_battle_pokemon == null:
		print("Clique em um Pokémon posicionado para selecionar o alvo do item.")
		return
	if GameManager.use_item("Poção", GameManager.selected_battle_pokemon):
		print("Poção utilizada em ", GameManager.selected_battle_pokemon.species_name)
	else:
		print("Não foi possível usar a Poção: alvo com HP cheio ou item indisponível.")
	update_hud_stats()

func _on_status_heal_pressed() -> void:
	if GameManager.selected_battle_pokemon == null:
		print("Clique em um Pokémon posicionado para selecionar o alvo do item.")
		return
	var target := GameManager.selected_battle_pokemon
	if GameManager.use_item("Antídoto", target) or GameManager.use_item("Despertar", target):
		print("Condição de status removida de ", target.species_name)
	else:
		print("O Pokémon não tem envenenamento/sono ou os itens acabaram.")
	update_hud_stats()
