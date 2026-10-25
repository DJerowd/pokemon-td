extends Control

const ITEM_BUTTON_SCRIPT = preload("res://scripts/ui/InventoryItemButton.gd")
const ITEM_SHEET_PATH := "res://assets/ui/pokemon_items.png"
const BAG_SHEET_PATH := "res://assets/ui/pokemon_bags.png"
const BALL_SHEET_PATH := "res://assets/ui/pokeballs_bw.png"
const STARTER_SCENE_PATH := "res://scenes/ui/StarterSelectScene.tscn"

const ITEM_ICON_INDEX := {
	"Poção": 25,
	"Antídoto": 26,
	"Despertar": 27
}
const BALL_COLUMN := {
	"Poké Bola": 3,
	"Great Ball": 2,
	"Ultra Ball": 1
}

@onready var lbl_money: Label = %LblMoney
@onready var lbl_lives: Label = %LblLives
@onready var lbl_wave: Label = %LblWave
@onready var lbl_selected_ball: Label = %LblSelectedBall
@onready var btn_cycle_ball: Button = %BtnCycleBall
@onready var btn_potion: Button = %BtnPotion
@onready var btn_status_heal: Button = %BtnStatusHeal
@onready var btn_menu: Button = %BtnMenu

var bag_button: Button
var bag_panel: PanelContainer
var bag_list: VBoxContainer
var menu_panel: PanelContainer
var pending_item_name: String = ""
var drag_preview: Control
var bag_sheet: Texture2D
var item_sheet: Texture2D
var ball_sheet: Texture2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_to_group("battle_hud")
	update_hud_stats()
	GameManager.stats_changed.connect(update_hud_stats)
	GameManager.team_changed.connect(update_hud_stats)

	# Os botões antigos permanecem no arquivo de cena por compatibilidade,
	# mas a seleção de itens e bolas passa a ser feita pela bolsa.
	btn_cycle_ball.hide()
	btn_potion.hide()
	btn_status_heal.hide()
	btn_menu.pressed.connect(_toggle_menu)

	_load_optional_sheets()
	_create_bag_button()
	_create_bag_panel()
	_create_menu_panel()
	_create_confirm_dialog()
	_create_drag_preview()
	_create_bag_icon()

func _load_optional_sheets() -> void:
	if ResourceLoader.exists(ITEM_SHEET_PATH):
		item_sheet = load(ITEM_SHEET_PATH) as Texture2D
	if ResourceLoader.exists(BAG_SHEET_PATH):
		bag_sheet = load(BAG_SHEET_PATH) as Texture2D
	if ResourceLoader.exists(BALL_SHEET_PATH):
		ball_sheet = load(BALL_SHEET_PATH) as Texture2D

func update_hud_stats() -> void:
	if lbl_money:
		lbl_money.text = "P$: " + str(GameManager.player_money)
	if lbl_lives:
		lbl_lives.text = "Vidas: " + str(GameManager.player_lives)
	if lbl_wave:
		lbl_wave.text = "Onda: " + str(GameManager.current_wave)
	if lbl_selected_ball:
		var ball_name := GameManager.selected_pokeball if not GameManager.selected_pokeball.is_empty() else "Sem Pokébolas"
		lbl_selected_ball.text = "%s: %d" % [ball_name, int(GameManager.pokeball_inventory.get(ball_name, 0))]
	if is_instance_valid(bag_panel) and bag_panel.visible:
		_rebuild_bag_list()

func _create_bag_button() -> void:
	bag_button = Button.new()
	bag_button.name = "BagButton"
	bag_button.tooltip_text = "Abrir bolsa de itens e Pokébolas"
	bag_button.text = "BOLSA"
	bag_button.custom_minimum_size = Vector2(82, 72)
	bag_button.anchor_left = 1.0
	bag_button.anchor_top = 1.0
	bag_button.anchor_right = 1.0
	bag_button.anchor_bottom = 1.0
	bag_button.offset_left = -100.0
	bag_button.offset_top = -88.0
	bag_button.offset_right = -18.0
	bag_button.offset_bottom = -16.0
	bag_button.pressed.connect(_toggle_bag)
	add_child(bag_button)

func _create_bag_icon() -> void:
	if bag_sheet == null or bag_button == null:
		return
	var icon_texture := AtlasTexture.new()
	icon_texture.atlas = bag_sheet
	icon_texture.region = Rect2(0, 0, 72, 76)
	bag_button.icon = icon_texture
	bag_button.text = ""
	bag_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _create_bag_panel() -> void:
	bag_panel = PanelContainer.new()
	bag_panel.name = "BagPanel"
	bag_panel.visible = false
	bag_panel.custom_minimum_size = Vector2(300, 340)
	bag_panel.anchor_left = 1.0
	bag_panel.anchor_top = 1.0
	bag_panel.anchor_right = 1.0
	bag_panel.anchor_bottom = 1.0
	bag_panel.offset_left = -330.0
	bag_panel.offset_top = -450.0
	bag_panel.offset_right = -18.0
	bag_panel.offset_bottom = -100.0
	bag_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.055, 0.12, 0.24, 0.98), Color(0.25, 0.78, 0.96)))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	bag_panel.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)
	bag_list = VBoxContainer.new()
	bag_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_list.add_theme_constant_override("separation", 6)
	scroll.add_child(bag_list)
	add_child(bag_panel)
	_rebuild_bag_list()

func _rebuild_bag_list() -> void:
	if bag_list == null:
		return
	for child in bag_list.get_children():
		child.queue_free()
	_add_section_title("ITENS")
	for item_name in ["Poção", "Antídoto", "Despertar"]:
		_add_inventory_entry(str(item_name), int(GameManager.inventory_items.get(item_name, 0)), "item")
	_add_section_title("POKÉ BOLAS")
	for ball_name in ["Poké Bola", "Great Ball", "Ultra Ball"]:
		_add_inventory_entry(str(ball_name), int(GameManager.pokeball_inventory.get(ball_name, 0)), "ball")

func _add_section_title(title: String) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_color_override("font_color", Color(0.48, 0.88, 1.0))
	label.add_theme_font_size_override("font_size", 15)
	bag_list.add_child(label)

func _add_inventory_entry(entry_name: String, count: int, kind: String) -> void:
	var button := Button.new()
	button.set_script(ITEM_BUTTON_SCRIPT)
	button.set("item_name", entry_name)
	button.set("inventory_kind", kind)
	button.text = "%s    × %d" % [entry_name, count]
	button.custom_minimum_size = Vector2(260, 38)
	button.disabled = count <= 0
	var icon_texture := _get_inventory_icon(entry_name, kind)
	if icon_texture:
		button.icon = icon_texture
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(_on_inventory_entry_pressed.bind(entry_name, kind))
	bag_list.add_child(button)

func _get_inventory_icon(entry_name: String, kind: String) -> Texture2D:
	if kind == "ball":
		if ball_sheet == null:
			return null
		var col := int(BALL_COLUMN.get(entry_name, 3))
		return _make_atlas(ball_sheet, Rect2(4 + col * 41, 4, 32, 32))
	if item_sheet == null:
		return null
	var index := int(ITEM_ICON_INDEX.get(entry_name, 0))
	var cell := 27.0
	return _make_atlas(item_sheet, Rect2((index % 16) * cell, floori(float(index) / 16.0) * cell, 24, 24))

func _make_atlas(sheet: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = region
	return atlas

func _make_panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _create_menu_panel() -> void:
	menu_panel = PanelContainer.new()
	menu_panel.name = "PauseMenu"
	menu_panel.visible = false
	menu_panel.custom_minimum_size = Vector2(250, 190)
	menu_panel.anchor_left = 1.0
	menu_panel.anchor_right = 1.0
	menu_panel.anchor_top = 0.0
	menu_panel.anchor_bottom = 0.0
	menu_panel.offset_left = -270.0
	menu_panel.offset_top = 72.0
	menu_panel.offset_right = -18.0
	menu_panel.offset_bottom = 266.0
	menu_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.055, 0.12, 0.24, 0.98), Color(0.96, 0.78, 0.18)))
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	menu_panel.add_child(list)
	var title := Label.new()
	title.text = "MENU DA PARTIDA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(title)
	var resume := Button.new()
	resume.text = "Continuar"
	resume.pressed.connect(_close_menu)
	list.add_child(resume)
	var restart := Button.new()
	restart.text = "Reiniciar partida"
	restart.pressed.connect(_restart_match)
	list.add_child(restart)
	var quit := Button.new()
	quit.text = "Desistir da partida"
	quit.pressed.connect(_confirm_give_up)
	list.add_child(quit)
	add_child(menu_panel)

func _create_confirm_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.name = "GiveUpConfirmation"
	dialog.title = "Desistir da partida?"
	dialog.dialog_text = "Seu progresso desta partida será perdido. Voltar à seleção inicial?"
	dialog.ok_button_text = "Desistir"
	dialog.cancel_button_text = "Continuar jogando"
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog.confirmed.connect(_give_up)
	dialog.canceled.connect(_close_menu)
	add_child(dialog)

func _create_drag_preview() -> void:
	drag_preview = Label.new()
	drag_preview.name = "ItemDragPreview"
	drag_preview.visible = false
	drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_preview.add_theme_color_override("font_color", Color.WHITE)
	drag_preview.add_theme_color_override("font_shadow_color", Color.BLACK)
	drag_preview.add_theme_constant_override("shadow_offset_x", 2)
	drag_preview.add_theme_constant_override("shadow_offset_y", 2)
	drag_preview.add_theme_font_size_override("font_size", 22)
	add_child(drag_preview)

func _process(_delta: float) -> void:
	if drag_preview and drag_preview.visible:
		drag_preview.position = get_viewport().get_mouse_position() + Vector2(12, 12)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if bag_panel.visible and not bag_panel.get_global_rect().has_point(event.position) and not bag_button.get_global_rect().has_point(event.position):
			bag_panel.hide()
		if pending_item_name != "" and not bag_panel.get_global_rect().has_point(event.position) and not bag_button.get_global_rect().has_point(event.position):
			var target := _find_tower_at_screen_position(event.position)
			if target:
				_apply_item_to_tower(pending_item_name, target)
				pending_item_name = ""
				drag_preview.visible = false

func _toggle_bag() -> void:
	if bag_panel.visible:
		bag_panel.hide()
	else:
		_rebuild_bag_list()
		bag_panel.show()
		if menu_panel.visible:
			menu_panel.hide()

func _on_inventory_entry_pressed(entry_name: String, kind: String) -> void:
	if kind == "ball":
		if int(GameManager.pokeball_inventory.get(entry_name, 0)) <= 0:
			return
		GameManager.selected_pokeball = entry_name
		GameManager.stats_changed.emit()
		pending_item_name = ""
	else:
		if int(GameManager.inventory_items.get(entry_name, 0)) <= 0:
			return
		pending_item_name = entry_name
		drag_preview.text = "↘ " + entry_name
		drag_preview.visible = true
	bag_panel.hide()
	update_hud_stats()

func _toggle_menu() -> void:
	if menu_panel.visible:
		_close_menu()
	else:
		menu_panel.show()
		bag_panel.hide()
		get_tree().paused = true

func _close_menu() -> void:
	menu_panel.hide()
	get_tree().paused = false

func _restart_match() -> void:
	get_tree().paused = false
	GameManager.reset_match()
	get_tree().change_scene_to_file(STARTER_SCENE_PATH)

func _confirm_give_up() -> void:
	var dialog := get_node("GiveUpConfirmation") as ConfirmationDialog
	dialog.popup_centered()
	menu_panel.hide()

func _give_up() -> void:
	get_tree().paused = false
	GameManager.reset_match()
	get_tree().change_scene_to_file(STARTER_SCENE_PATH)

func play_capture_animation(target: Node2D, ball_name: String, was_captured: bool) -> void:
	if not is_instance_valid(target):
		return
	var start := bag_button.get_global_rect().get_center()
	var target_world := target.global_position
	var camera := get_viewport().get_camera_2d()
	var target_screen: Vector2 = get_viewport().get_canvas_transform() * target_world
	if camera == null:
		target_screen = get_viewport().get_mouse_position()
	var flight := TextureRect.new()
	flight.name = "CaptureBallFlight"
	flight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flight.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flight.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flight.size = Vector2(38, 38)
	flight.position = start - flight.size / 2.0
	flight.z_index = 200
	var column := int(BALL_COLUMN.get(ball_name, 3))
	if ball_sheet:
		flight.texture = _make_atlas(ball_sheet, Rect2(4 + column * 41, 4, 32, 32))
	else:
		var fallback := Label.new()
		fallback.text = "🔴"
		fallback.add_theme_font_size_override("font_size", 28)
		flight.add_child(fallback)
	add_child(flight)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(flight, "position", target_screen - flight.size / 2.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	if not is_instance_valid(flight):
		return
	if ball_sheet:
		# O atlas de Black/White organiza várias poses verticalmente.
		for frame_row in [1, 2, 3, 4, 3, 2, 1, 0]:
			if not is_instance_valid(flight):
				return
			flight.texture = _make_atlas(ball_sheet, Rect2(4 + column * 41, 4 + frame_row * 41, 32, 32))
			await get_tree().create_timer(0.07, true, false, true).timeout
	var close_tween := create_tween()
	close_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	close_tween.tween_property(flight, "scale", Vector2(0.2, 0.2), 0.16)
	close_tween.parallel().tween_property(flight, "modulate:a", 0.0, 0.16)
	await close_tween.finished
	if is_instance_valid(flight):
		flight.queue_free()
	var result_label := Label.new()
	result_label.z_index = 220
	result_label.add_theme_font_size_override("font_size", 18)
	result_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	result_label.add_theme_constant_override("shadow_offset_x", 2)
	result_label.add_theme_constant_override("shadow_offset_y", 2)
	if was_captured:
		result_label.text = "CAPTURADO!"
		result_label.position = target_screen + Vector2(-55, -42)
		result_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.58))
	else:
		result_label.text = "ESCAPOU!"
		result_label.position = target_screen + Vector2(-45, -42)
		result_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.45))
	add_child(result_label)
	var result_tween := create_tween()
	result_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	result_tween.tween_property(result_label, "position:y", result_label.position.y - 24.0, 0.45)
	result_tween.parallel().tween_property(result_label, "modulate:a", 0.0, 0.75)
	result_tween.tween_callback(result_label.queue_free)

func _find_tower_at_screen_position(screen_position: Vector2) -> Node:
	var world_position := get_viewport().get_canvas_transform().affine_inverse() * screen_position
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hits := get_viewport().world_2d.direct_space_state.intersect_point(query, 16)
	for hit in hits:
		var collider := hit.get("collider") as Node
		if collider == null:
			continue
		if collider.is_in_group("towers"):
			return collider
		var parent := collider.get_parent()
		if parent and parent.is_in_group("towers"):
			return parent
	return null

func _find_enemy_at_screen_position(screen_position: Vector2) -> Node:
	var world_position := get_viewport().get_canvas_transform().affine_inverse() * screen_position
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hits := get_viewport().world_2d.direct_space_state.intersect_point(query, 16)
	for hit in hits:
		var collider := hit.get("collider") as Node
		if collider == null:
			continue
		if collider.is_in_group("enemies"):
			return collider
		var parent := collider.get_parent()
		if parent and parent.is_in_group("enemies"):
			return parent
	return null

func _apply_item_to_tower(item_name: String, tower: Node) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	var pokemon: PokemonData = tower.get("pokemon_data")
	if pokemon == null:
		return
	if GameManager.use_item(item_name, pokemon):
		print("%s utilizado em %s." % [item_name, pokemon.species_name])
	else:
		print("Não foi possível usar %s neste Pokémon." % item_name)
	update_hud_stats()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") in ["item", "ball"]

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var target: Node = _find_enemy_at_screen_position(get_viewport().get_mouse_position()) if data.get("kind", "") == "ball" else _find_tower_at_screen_position(get_viewport().get_mouse_position())
	if target == null:
		pending_item_name = ""
		drag_preview.visible = false
		return
	if data.get("kind", "") == "ball":
		var ball_name := str(data.get("item_name", "Poké Bola"))
		if int(GameManager.pokeball_inventory.get(ball_name, 0)) > 0:
			GameManager.selected_pokeball = ball_name
			target.call("try_to_catch", ball_name)
	else:
		_apply_item_to_tower(str(data.get("item_name", "")), target)
	pending_item_name = ""
	drag_preview.visible = false
