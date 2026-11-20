extends Node2D

const CONTROLLER_INPUT = preload("res://Scripts/controller_input.gd")

## Title Screen - Gorgon's Quest

const COLOR_BG      := Color("1A1A2E")
const COLOR_GOLD    := Color("D4A96A")
const COLOR_MARBLE  := Color("E8DCC4")
const COLOR_WATER   := Color("4A7FB5")

var save_manager_script = preload("res://Scripts/save_manager.gd")
var save_manager: Node = null

const MENU_ITEMS := ["Nouvelle Partie", "Continuer", "Options", "Quitter"]
var selected_item: int = 0
var has_save: bool = false

var _time: float = 0.0
var _logo_anim: float = 0.0

signal menu_new_game
signal menu_continue
signal menu_options
signal menu_quit

func _ready() -> void:
	CONTROLLER_INPUT.configure()
	save_manager = save_manager_script.new()
	save_manager.name = "TitleSaveManager"
	add_child(save_manager)
	has_save = save_manager.has_save()
	selected_item = 0

func _process(delta: float) -> void:
	_time += delta
	_logo_anim = sin(_time * 1.2) * 0.015
	queue_redraw()

func _draw() -> void:
	var vp := Vector2(1920, 1080)
	draw_rect(Rect2(Vector2.ZERO, vp), COLOR_BG)
	# Vague d'eau en bas
	for i in range(0, 1920, 4):
		var wave_y: float = 920.0 + sin((i * 0.015) + _time * 2.0) * 12.0
		draw_line(Vector2(i, wave_y), Vector2(i, 1080), COLOR_WATER.darkened(0.3))
	# Etoiles
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(60):
		var sx: float = rng.randf_range(0, 1920)
		var sy: float = rng.randf_range(0, 400)
		var brightness: float = 0.4 + sin(_time * rng.randf_range(0.5, 2.0) + i) * 0.3
		draw_circle(Vector2(sx, sy), 1.5, Color(1, 1, 1, brightness))
	# Colonnes
	_draw_column(Vector2(120, 200), 600)
	_draw_column(Vector2(1800, 200), 600)
	# Logo
	# Godot 4 ignores HORIZONTAL_ALIGNMENT_CENTER when no width is given, so every text is centred by hand.
	var logo_center := Vector2(960, 280)
	var font_size: int = int(80 * (1.0 + _logo_anim))
	_draw_centered_menu_text("GORGON'S QUEST", logo_center.y + 4.0, font_size, Color(0, 0, 0, 0.6), logo_center.x + 4.0)
	_draw_centered_menu_text("GORGON'S QUEST", logo_center.y, font_size, COLOR_GOLD, logo_center.x)
	_draw_centered_menu_text("Mythologie Grecque — Clone de Kickle Cubicle",
		logo_center.y + 90.0, 24, COLOR_MARBLE.darkened(0.3), logo_center.x)
	# Separateur
	draw_line(Vector2(560, 390), Vector2(1360, 390), COLOR_GOLD.darkened(0.4), 2.0)
	draw_circle(Vector2(960, 390), 5, COLOR_GOLD)
	# Menu
	_draw_menu()
	# Pied de page
	_draw_centered_menu_text("Fleches : Naviguer    Entree : Selectionner    Echap : Quitter",
		870.0, 20, COLOR_MARBLE.darkened(0.5), 960.0)

func _draw_menu() -> void:
	var menu_top := 450.0
	var menu_spacing := 80.0
	for i in range(MENU_ITEMS.size()):
		var item_y: float = menu_top + i * menu_spacing
		var item_center := Vector2(960, item_y)
		var is_selected: bool = i == selected_item
		var is_disabled: bool = (i == 1 and not has_save)
		if is_disabled:
			_draw_centered_menu_text(MENU_ITEMS[i], item_center.y, 36, Color(0.5, 0.5, 0.5, 0.4))
			continue
		var font_size := 42 if is_selected else 36
		var text_size := _menu_text_size(MENU_ITEMS[i], font_size)
		var text_origin := Vector2(item_center.x - text_size.x * 0.5, item_center.y - text_size.y * 0.5)
		if is_selected:
			var highlight_width := maxf(400.0, text_size.x + 120.0)
			var highlight := Rect2(Vector2(item_center.x - highlight_width * 0.5, item_center.y - 30.0), Vector2(highlight_width, 60.0))
			draw_rect(highlight, COLOR_GOLD.darkened(0.6))
			draw_rect(highlight, COLOR_GOLD, false, 2.0)
			_draw_centered_menu_text("►", item_center.y, 28, COLOR_GOLD, highlight.position.x + 34.0)
			_draw_centered_menu_text("◄", item_center.y, 28, COLOR_GOLD, highlight.end.x - 34.0)
			_draw_menu_text(MENU_ITEMS[i], text_origin, font_size, COLOR_GOLD)
		else:
			_draw_menu_text(MENU_ITEMS[i], text_origin, font_size, COLOR_MARBLE)

func _menu_text_size(text: String, font_size: int) -> Vector2:
	return ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

func _draw_centered_menu_text(text: String, center_y: float, font_size: int, color: Color, center_x: float = 960.0) -> void:
	var text_size := _menu_text_size(text, font_size)
	_draw_menu_text(text, Vector2(center_x - text_size.x * 0.5, center_y - text_size.y * 0.5), font_size, color)

func _baseline_origin(top_left: Vector2, font_size: int) -> Vector2:
	"""draw_string() takes the BASELINE; the menu code works with the top-left corner of the text box."""
	return top_left + Vector2(0.0, ThemeDB.fallback_font.get_ascent(font_size))

func _draw_menu_text(text: String, origin: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, _baseline_origin(origin, font_size), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_column(pos: Vector2, height: float) -> void:
	var col_w := 30.0
	draw_rect(Rect2(pos + Vector2(-col_w * 0.5, 0), Vector2(col_w, height)),
		COLOR_MARBLE.darkened(0.15))
	for i in range(0, int(height), 20):
		draw_line(pos + Vector2(-col_w * 0.5, i), pos + Vector2(col_w * 0.5, i),
			Color(0, 0, 0, 0.08), 1.0)
	draw_rect(Rect2(pos + Vector2(-col_w * 0.8, -20), Vector2(col_w * 1.6, 20)), COLOR_MARBLE)
	draw_rect(Rect2(pos + Vector2(-col_w * 0.8, height), Vector2(col_w * 1.6, 20)), COLOR_MARBLE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_selection(1)
	elif event.is_action_pressed("ui_up"):
		_move_selection(-1)
	elif event.is_action_pressed("ui_accept"):
		_activate_selected()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _move_selection(delta: int) -> void:
	var prev: int = selected_item
	selected_item = (selected_item + delta + MENU_ITEMS.size()) % MENU_ITEMS.size()
	if selected_item == 1 and not has_save:
		selected_item = (selected_item + delta + MENU_ITEMS.size()) % MENU_ITEMS.size()
	if selected_item != prev:
		queue_redraw()

func _activate_selected() -> void:
	match selected_item:
		0:  # Nouvelle Partie
			if save_manager:
				save_manager.reset_save()
			menu_new_game.emit()
			get_tree().change_scene_to_file("res://Scenes/overworld_map.tscn")
		1:  # Continuer
			if has_save:
				menu_continue.emit()
				get_tree().change_scene_to_file("res://Scenes/overworld_map.tscn")
		2:  # Options
			menu_options.emit()
			get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")
		3:  # Quitter
			get_tree().quit()

