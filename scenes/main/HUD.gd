extends Control

@onready var lbl_money: Label = %LblMoney
@onready var lbl_lives: Label = %LblLives
@onready var lbl_wave: Label = %LblWave
@onready var btn_start_wave: Button = %BtnStartWave
@onready var bottom_slots_container: HBoxContainer = %SlotsContainer

func _ready() -> void:
	update_hud_stats()
	populate_player_bench()
	GameManager.stats_changed.connect(update_hud_stats)

func update_hud_stats() -> void:
	if lbl_money:
		lbl_money.text = "💰 P$: " + str(GameManager.player_money)
	if lbl_lives:
		lbl_lives.text = "❤️ Vidas: " + str(GameManager.player_lives)
	if lbl_wave:
		lbl_wave.text = "🌊 Onda: " + str(GameManager.current_wave)

func populate_player_bench() -> void:
	if bottom_slots_container == null:
		return
	for child in bottom_slots_container.get_children():
		bottom_slots_container.remove_child(child)
		child.queue_free()

	# Only the chosen battle team can be deployed. The rest remains in storage.
	for pokemon in GameManager.active_battle_team:
		if pokemon == null:
			continue
		var slot_button := Button.new()
		slot_button.text = "%s (Nv. %d)" % [pokemon.species_name, pokemon.level]
		slot_button.custom_minimum_size = Vector2(100, 60)
		slot_button.tooltip_text = "Clique para selecionar e depois clique em um espaço livre."
		slot_button.pressed.connect(_on_pokemon_selected.bind(pokemon))
		bottom_slots_container.add_child(slot_button)

func _on_pokemon_selected(pokemon: PokemonData) -> void:
	if not GameManager.can_deploy_pokemon(pokemon):
		return
	GameManager.selected_pokemon_to_place = pokemon
	print("Selecionado para posicionar: ", pokemon.species_name)
