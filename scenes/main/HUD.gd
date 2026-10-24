extends Control

@onready var lbl_money = %LblMoney
@onready var lbl_lives = %LblLives
@onready var lbl_wave = %LblWave
@onready var btn_start_wave = %BtnStartWave
@onready var bottom_slots_container = %SlotsContainer

func _ready() -> void:
	update_hud_stats()
	populate_player_bench()

func _process(_delta: float) -> void:
	update_hud_stats()

func update_hud_stats() -> void:
	if lbl_money:
		lbl_money.text = "💰 P$: " + str(GameManager.player_money)
	if lbl_lives:
		lbl_lives.text = "❤️ Vidas: " + str(GameManager.player_lives)
	if lbl_wave:
		lbl_wave.text = "🌊 Onda: " + str(GameManager.current_wave)

# Cria dinamicamente os slots de Pokémon na barra inferior com base no time do jogador
func populate_player_bench() -> void:
	if not bottom_slots_container:
		return
		
	for child in bottom_slots_container.get_children():
		child.queue_free()
		
	for pokemon in GameManager.captured_pokemons:
		var slot_btn = Button.new()
		slot_btn.text = pokemon.species_name + " (Lvl " + str(pokemon.level) + ")"
		slot_btn.custom_minimum_size = Vector2(100, 60)
		
		# Ao clicar no Pokémon da barra inferior, ele fica selecionado para posicionamento no mapa
		slot_btn.pressed.connect(func():
			GameManager.selected_pokemon_to_place = pokemon
			print("Selecionado para posicionar: ", pokemon.species_name)
		)
		
		bottom_slots_container.add_child(slot_btn)
