extends Node2D

const CONTROLLER_INPUT = preload("res://Scripts/controller_input.gd")

## Overworld Map - Carte du Monde de Gorgon's Quest
## Affiche un chemin insulaire avec cases de niveau à sélectionner

const TILE_SIZE := 80          # Taille d'une case sur la carte
const PATH_COLOR   := Color("D4A96A")   # Sable doré
const LOCKED_COLOR := Color("6B6B8A")   # Violet-gris verrouillé
const OPEN_COLOR   := Color("E8DCC4")   # Beige ouvert
const DONE_COLOR   := Color("7EC8A4")   # Vert complété
const BOSS_COLOR   := Color("C04040")   # Rouge boss
const HERO_COLOR   := Color("4A90E2")   # Bleu héros

# Chemin des cases, commun aux quatre mondes : 19 niveaux de puzzle + 1 boss (Constants.LEVELS_PER_WORLD)
# Chaque entrée = offset depuis l'origine en cases [col, row]
const LEVEL_PATH := [
	Vector2i(0, 6),   # Niveau 1
	Vector2i(1, 6),   # Niveau 2
	Vector2i(2, 6),   # Niveau 3
	Vector2i(3, 6),   # Niveau 4
	Vector2i(4, 6),   # Niveau 5
	Vector2i(4, 5),   # Niveau 6
	Vector2i(5, 5),   # Niveau 7
	Vector2i(5, 4),   # Niveau 8
	Vector2i(6, 4),   # Niveau 9
	Vector2i(7, 4),   # Niveau 10
	Vector2i(7, 3),   # Niveau 11
	Vector2i(8, 3),   # Niveau 12
	Vector2i(8, 2),   # Niveau 13
	Vector2i(9, 2),   # Niveau 14
	Vector2i(9, 1),   # Niveau 15
	Vector2i(10, 1),  # Niveau 16
	Vector2i(11, 1),  # Niveau 17
	Vector2i(11, 0),  # Niveau 18
	Vector2i(12, 0),  # Niveau 19
	Vector2i(13, 0),  # Niveau 20 (Boss)
]

var save_manager: Node = null
var current_world: int = 1
var selected_index: int = 0   # Case actuellement mise en surbrillance
var max_unlocked: int = 1     # Dernier niveau accessible (1-based)

signal level_chosen(world: int, level: int)

func _ready() -> void:
	CONTROLLER_INPUT.configure()
	var session = get_node("/root/GameSession")
	current_world = session.selected_world
	save_manager = load("res://Scripts/save_manager.gd").new()
	add_child(save_manager)
	max_unlocked = save_manager.get_max_level(current_world)
	selected_index = clampi(max_unlocked - 1, 0, LEVEL_PATH.size() - 1)
	queue_redraw()

func _draw() -> void:
	_draw_path_connections()
	_draw_level_nodes()
	_draw_hero_cursor()

func _draw_path_connections() -> void:
	for i in range(LEVEL_PATH.size() - 1):
		var a: Vector2 = _node_center(i)
		var b: Vector2 = _node_center(i + 1)
		var unlocked: bool = (i + 1) < max_unlocked
		var col: Color = PATH_COLOR if unlocked else LOCKED_COLOR.darkened(0.3)
		draw_line(a, b, col, 6.0)

func _draw_level_nodes() -> void:
	for i in range(LEVEL_PATH.size()):
		var center: Vector2 = _node_center(i)
		var level_num: int = i + 1
		var is_boss: bool = level_num == Constants.BOSS_LEVEL
		var is_done: bool  = level_num < max_unlocked
		var is_open: bool  = level_num == max_unlocked
		var is_locked: bool = level_num > max_unlocked
		var is_selected: bool = i == selected_index

		# Cercle de fond
		var radius := 32.0 if is_boss else 24.0
		var fill_col := DONE_COLOR if is_done else (OPEN_COLOR if is_open else LOCKED_COLOR)
		if is_boss:
			fill_col = BOSS_COLOR if (is_done or is_open) else LOCKED_COLOR
		draw_circle(center, radius, fill_col)

		# Bordure sélection
		if is_selected:
			draw_arc(center, radius + 6.0, 0.0, TAU, 32, Color.WHITE, 3.0)

		# Numéro ou icône
		var label := "☠" if is_boss else str(level_num)
		if is_locked:
			label = "🔒" if is_boss else "?"
		draw_string(ThemeDB.fallback_font, center + Vector2(-10, 8), label,
			HORIZONTAL_ALIGNMENT_CENTER, -1, 20,
			Color.WHITE if not is_locked else Color(1,1,1,0.4))

func _draw_hero_cursor() -> void:
	var center := _node_center(selected_index)
	# Petit triangle au-dessus de la case sélectionnée
	var tip := center + Vector2(0, -44)
	var pts := PackedVector2Array([
		tip, tip + Vector2(-10, 18), tip + Vector2(10, 18)
	])
	draw_colored_polygon(pts, HERO_COLOR)

func _node_center(index: int) -> Vector2:
	var grid_pos: Vector2i = LEVEL_PATH[index]
	var origin := Vector2(80, 80)
	return origin + Vector2(grid_pos) * TILE_SIZE + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)

# ── Input ────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		_move_cursor(1)
	elif event.is_action_pressed("ui_left"):
		_move_cursor(-1)
	elif event.is_action_pressed("ui_up"):
		_move_cursor(-1)
	elif event.is_action_pressed("ui_down"):
		_move_cursor(1)
	elif event.is_action_pressed("ui_accept"):
		_select_level()

func _move_cursor(delta: int) -> void:
	var new_idx := clampi(selected_index + delta, 0, min(max_unlocked - 1, LEVEL_PATH.size() - 1))
	if new_idx != selected_index:
		selected_index = new_idx
		queue_redraw()

func _select_level() -> void:
	var level_num := selected_index + 1
	if level_num > max_unlocked:
		return
	print("Overworld: launching World %d Level %d" % [current_world, level_num])
	var session = get_node("/root/GameSession")
	session.selected_world = current_world
	session.selected_level = level_num
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# ── API publique ─────────────────────────────────────────────

func unlock_next_level() -> void:
	"""Appelée après victoire pour débloquer le niveau suivant avec animation"""
	if max_unlocked < LEVEL_PATH.size():
		max_unlocked += 1
		selected_index = max_unlocked - 1
		# Animation de déblocage
		var tween := create_tween()
		tween.tween_method(_flash_new_node.bind(selected_index), 0.0, 1.0, 0.8)
		tween.tween_callback(queue_redraw)
	queue_redraw()

func _flash_new_node(_t: float, _idx: int) -> void:
	queue_redraw()

func refresh_from_save() -> void:
	"""Recharge la progression depuis SaveManager"""
	if save_manager:
		max_unlocked = save_manager.get_max_level(current_world)
	selected_index = clampi(max_unlocked - 1, 0, LEVEL_PATH.size() - 1)
	queue_redraw()
