extends Node2D

enum Direction { DOWN = 0, UP = 1, LEFT = 2, RIGHT = 3 }

@export var pokemon_data: Resource:
	set(value):
		pokemon_data = value
		if pokemon_data:
			# Cálculo de dano dinâmico baseado no Ataque e Nível
			damage = pokemon_data.attack * (1.0 + (pokemon_data.level * 0.05))
			
			# Cálculo da cadência de tiro baseado na Velocidade (speed)
			attack_cooldown = max(0.2, 2.0 - (pokemon_data.speed * 0.01))
			
			# Define o golpe ativo atual com base no índice configurado
			if pokemon_data.available_moves.size() > 0:
				var move_idx = clamp(pokemon_data.active_move_index, 0, pokemon_data.available_moves.size() - 1)
				current_move = pokemon_data.available_moves[move_idx]
				
			update_sprite_texture()
			
			# Atualiza o desenho do alcance caso os dados mudem
			queue_redraw()

var slot_reference = null # Referência ao slot de origem
var damage: float = 20.0
var attack_cooldown: float = 1.0
var current_move: String = "Investida"
var is_selected: bool = false # Controla se a torre está selecionada no momento

# Variáveis para controle de Direção e Animação
var current_direction: Direction = Direction.DOWN
var anim_frame: int = 0
var anim_timer: float = 0.0
var anim_speed: float = 0.25 # Velocidade da troca de quadros da caminhada

var enemies_in_range: Array = []
@onready var attack_timer = $Timer
@onready var range_area = $Area2D
@onready var click_area = $ClickArea # Referência à área de clique do sprite
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready() -> void:
	# Garante que o Sprite2D utilize uma textura AtlasTexture
	if sprite and not (sprite.texture is AtlasTexture):
		var atlas = AtlasTexture.new()
		atlas.atlas = load("res://assets/textures/pokemon_overworld_sheet.png") # Caminho do seu Sprite Sheet
		sprite.texture = atlas

	if not attack_timer:
		attack_timer = Timer.new()
		add_child(attack_timer)
	
	attack_timer.wait_time = attack_cooldown
	if not attack_timer.timeout.is_connected(_on_attack_timeout):
		attack_timer.timeout.connect(_on_attack_timeout)
	attack_timer.start()
	
	if range_area:
		if not range_area.body_entered.is_connected(_on_enemy_entered):
			range_area.body_entered.connect(_on_enemy_entered)
		if not range_area.body_exited.is_connected(_on_enemy_exited):
			range_area.body_exited.connect(_on_enemy_exited)
			
	# Conecta o sinal de clique do Area2D do sprite
	if click_area:
		if not click_area.input_event.is_connected(_on_click_area_input_event):
			click_area.input_event.connect(_on_click_area_input_event)
			
	update_sprite_texture()
	
func _process(delta: float) -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		var direction_vector = (target.global_position - global_position).normalized()
		
		# Atualiza a direção do olhar (Cima, Baixo, Esquerda, Direita)
		if abs(direction_vector.x) > abs(direction_vector.y):
			if direction_vector.x < 0:
				set_direction(Direction.LEFT)
			else:
				set_direction(Direction.RIGHT)
		else:
			if direction_vector.y < 0:
				set_direction(Direction.UP)
			else:
				set_direction(Direction.DOWN)
				
		# Animação de passos enquanto combate/mira
		update_sprite_animation(delta)

# Atualiza a direção atual
func set_direction(new_dir: Direction) -> void:
	if current_direction != new_dir:
		current_direction = new_dir
		update_sprite_texture()

# Alterna o quadro de animação de passos
func update_sprite_animation(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= anim_speed:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % 2 # Alterna entre quadro 0 e 1
		update_sprite_texture()

# Corta o Sprite Sheet com base no Pokémon, Direção e Frame
func update_sprite_texture() -> void:
	if not pokemon_data or not sprite or not (sprite.texture is AtlasTexture):
		return
		
	var atlas_tex = sprite.texture as AtlasTexture
	var row: int = current_direction
	
	# Mapeia as direções para as linhas do Sprite Sheet usando cast ou valores de Enum
	match current_direction:
		Direction.DOWN:
			row = Direction.DOWN as int # Linha 0
		Direction.UP:
			row = Direction.UP as int   # Linha 1
		Direction.LEFT:
			row = Direction.LEFT as int # Linha 2
			sprite.flip_h = false
		Direction.RIGHT:
			row = Direction.LEFT as int # Usa a linha da esquerda espelhada
			sprite.flip_h = true
		
	if pokemon_data.has_method("get_frame_region"):
		atlas_tex.region = pokemon_data.get_frame_region(row, anim_frame)
	elif "sprite_region" in pokemon_data:
		atlas_tex.region = pokemon_data.sprite_region

# Desenha a área de alcance na tela quando a torre está selecionada
func _draw() -> void:
	if is_selected and pokemon_data:
		var radius = pokemon_data.attack_range
		# Desenha um círculo verde translúcido preenchido (Centro, Raio, Cor)
		draw_circle(Vector2.ZERO, radius, Color(0.2, 0.8, 1.0, 0.251))
		# Desenha a borda do círculo com uma linha mais forte para destaque
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(0.102, 0.902, 1.0, 0.8), 2.0)

func _on_enemy_entered(body: Node2D) -> void:
	var enemy = body.get_parent()
	if enemy and enemy not in enemies_in_range:
		enemies_in_range.append(enemy)

func _on_enemy_exited(body: Node2D) -> void:
	var enemy = body.get_parent()
	if enemy in enemies_in_range:
		enemies_in_range.erase(enemy)

func _on_attack_timeout() -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		if target.has_method("take_damage"):
			print(pokemon_data.species_name if pokemon_data else "Torre", " usou ", current_move, " contra o inimigo causando ", damage, " de dano!")
			target.take_damage(damage)

# Detecta o clique esquerdo especificamente no sprite do Pokémon através do ClickArea
func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = !is_selected
		queue_redraw()
		
		if is_selected:
			open_tower_inspector()
			
		get_viewport().set_input_as_handled()

func open_tower_inspector() -> void:
	if pokemon_data:
		print("Inspecionando torre: ", pokemon_data.species_name)
		var inspector_scene = load("res://scenes/ui/TowerInspectorMenu.tscn")
		if inspector_scene:
			var menu = inspector_scene.instantiate()
			menu.target_pokemon = pokemon_data
			menu.target_tower = self # Passa a referência da torre atual para o menu
			get_tree().current_scene.add_child(menu)

# Executado automaticamente quando a torre é apagada/removida da cena
func _exit_tree() -> void:
	if pokemon_data:
		if pokemon_data in GameManager.deployed_pokemons:
			GameManager.deployed_pokemons.erase(pokemon_data)
			
	if slot_reference and is_instance_valid(slot_reference):
		slot_reference.occupied = false
		slot_reference.current_tower = null
