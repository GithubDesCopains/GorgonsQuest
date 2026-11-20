extends Control

class GridView extends Control:
	signal cell_selected(position: Vector2i)
	signal cell_erased(position: Vector2i)
	signal stroke_started

	var document: Dictionary = {}
	var tile_size: float = 40.0
	var _last_cell := Vector2i(-1, -1)

	func _draw() -> void:
		var grid: Array = document.get("grid", [])
		var font := ThemeDB.fallback_font
		for y in range(mini(grid.size(), Constants.GRID_ROWS)):
			var row := str(grid[y])
			for x in range(mini(row.length(), Constants.GRID_COLS)):
				var rect := Rect2(Vector2(x * tile_size, y * tile_size), Vector2.ONE * tile_size)
				draw_rect(rect, _tile_color(row.substr(x, 1)))
				draw_rect(rect, Color(0.12, 0.16, 0.2, 0.55), false, 1.0)
				var marker := _marker_at(Vector2i(x, y))
				if not marker.is_empty():
					draw_string(font, rect.position + Vector2(3, 25), marker, HORIZONTAL_ALIGNMENT_LEFT, tile_size - 4.0, 13, Color.WHITE)
		_draw_doors()

	func _tile_color(code: String) -> Color:
		match code:
			".": return Color("#c8b98f")
			"#": return Color("#d9873f")
			"~": return Color("#3284b7")
			"i": return Color("#b5e5ee")
			"b": return Color("#9a9a94")
			"o": return Color("#2b6e96")
			"v": return Color("#9a7bc8")
		return Color.MAGENTA

	func _marker_at(pos: Vector2i) -> String:
		var markers: Array[String] = []
		if _position_matches(document.get("player_start", []), pos):
			markers.append("P")
		for urn in document.get("soul_urns", []):
			if _position_matches(urn.get("pos", []) if typeof(urn) == TYPE_DICTIONARY else urn, pos):
				markers.append("U")
		for enemy in document.get("enemies", []):
			if _position_matches(enemy.get("pos", []), pos):
				markers.append("E")
		for spawner in document.get("spawners", []):
			if _position_matches(spawner.get("pos", []), pos):
				markers.append("S")
		for key in ["springs", "rotators", "warps", "one_way_gates", "conveyors"]:
			for entry in document.get(key, []):
				if _position_matches(entry.get("pos", []), pos):
					var letter: String = {"springs": "R", "rotators": "T", "warps": "W", "one_way_gates": "1", "conveyors": "C"}[key]
					# Springs, gates and belts show where they point.
					markers.append(letter + {"right": "→", "down": "↓", "left": "←", "up": "↑"}.get(str(entry.get("direction", "")).to_lower(), ""))
		for slippery in document.get("slippery_tiles", []):
			if _position_matches(slippery.get("pos", []) if typeof(slippery) == TYPE_DICTIONARY else slippery, pos):
				markers.append("I")
		for block in document.get("push_blocks", []):
			if _position_matches(block.get("pos", []) if typeof(block) == TYPE_DICTIONARY else block, pos):
				markers.append("K")
		for bonus in document.get("bonus_items", []):
			if _position_matches(bonus.get("pos", []), pos):
				markers.append("G" if str(bonus.get("kind", "ambrosia")) == "ambrosia" else "O")
		for mirror in document.get("mirrors", []):
			if _position_matches(mirror.get("pos", []), pos):
				markers.append("M" + ("\\" if str(mirror.get("orientation", "slash")) == "backslash" else "/"))
		for plate in document.get("switches", []):
			if _position_matches(plate.get("pos", []), pos):
				markers.append("Z" + str(plate.get("id", "")))
		var boss: Dictionary = document.get("boss", {})
		if not boss.is_empty() and _position_matches(boss.get("pos", []), pos):
			markers.append("B")
		return "".join(markers)

	func _draw_doors() -> void:
		"""A door sits on the EDGE between its cell and the neighbour it points to: draw it as a thick line there."""
		var arrows := {"right": Vector2.RIGHT, "down": Vector2.DOWN, "left": Vector2.LEFT, "up": Vector2.UP}
		for door in document.get("doors", []):
			var pos: Array = door.get("pos", [0, 0])
			var dir: Vector2 = arrows.get(str(door.get("direction", "right")).to_lower(), Vector2.RIGHT)
			var center := (Vector2(float(pos[0]), float(pos[1])) + Vector2(0.5, 0.5)) * tile_size
			var edge := center + dir * tile_size * 0.5
			var along := Vector2(dir.y, dir.x)  # perpendicular to the pointing direction
			draw_line(edge - along * tile_size * 0.5, edge + along * tile_size * 0.5, Color("1A1418"), 9.0)
			draw_line(edge - along * tile_size * 0.5, edge + along * tile_size * 0.5, _id_color(str(door.get("id", ""))), 5.0)

	func _id_color(id: String) -> Color:
		var palette := [Color("E0645C"), Color("5C9BE0"), Color("6CC070"), Color("EBC34F"), Color("A97BD6"), Color("EE9A4D")]
		return palette[absi(id.hash()) % palette.size()]

	func _position_matches(value: Variant, pos: Vector2i) -> bool:
		return typeof(value) == TYPE_ARRAY and value.size() == 2 and int(value[0]) == pos.x and int(value[1]) == pos.y

	func _cell_at(local_position: Vector2) -> Vector2i:
		var cell := Vector2i(floori(local_position.x / tile_size), floori(local_position.y / tile_size))
		if cell.x < 0 or cell.x >= Constants.GRID_COLS or cell.y < 0 or cell.y >= Constants.GRID_ROWS:
			return Vector2i(-1, -1)
		return cell

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
			var cell := _cell_at(event.position)
			if cell.x >= 0:
				stroke_started.emit()
				_last_cell = cell
				if event.button_index == MOUSE_BUTTON_LEFT:
					cell_selected.emit(cell)
				else:
					cell_erased.emit(cell)
		elif event is InputEventMouseButton and not event.pressed:
			_last_cell = Vector2i(-1, -1)
		elif event is InputEventMouseMotion and _last_cell.x >= 0:
			var cell := _cell_at(event.position)
			if cell.x >= 0 and cell != _last_cell:
				_last_cell = cell
				if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
					cell_erased.emit(cell)
				elif event.button_mask & MOUSE_BUTTON_MASK_LEFT:
					cell_selected.emit(cell)

const LEVEL_CHECKER = preload("res://Scripts/level_checker.gd")
const TEST_LEVEL_PATH := "user://editor_test_level.json"
const MAX_UNDO := 100
const TILE_CODES := {".": "Sol", "#": "Mur", "~": "Eau", "i": "Glace", "b": "Pilier cassable", "o": "Trou d'eau", "v": "Case violette (héros seul)"}
const ENEMY_TYPES := LEVEL_CHECKER.ENEMY_TYPES   # one list shared with the level checker
const BOSS_TYPES := ["cyclops", "hydra", "chimera", "medusa", "generic"]
const TOOLS := [
	"Terrain", "Départ joueur", "Urne", "Ennemi", "Générateur", "Ressort",
	"Rotateur", "Téléporteur", "Sol glissant", "Porte unidirectionnelle",
	"Tapis roulant", "Boss", "Effacer",
	"Bloc poussable", "Bonus glace (points)", "Bonus boule P",
	"Miroir", "Interrupteur", "Porte"
]

var document: Dictionary = {}
var current_path := ""
var dirty := false
var loading_document := false
var active_tool := 0
var pending_action: Callable
var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []

var grid_view: GridView
var path_label: Label
var tool_picker: OptionButton
var terrain_picker: OptionButton
var enemy_picker: OptionButton
var direction_picker: OptionButton
var rotator_picker: OptionButton
var name_edit: LineEdit
var world_spin: SpinBox
var level_spin: SpinBox
var time_spin: SpinBox
var pattern_edit: LineEdit
var pair_edit: LineEdit
var mirror_picker: OptionButton
var link_edit: LineEdit  # id shared by a switch and its doors
var interval_spin: SpinBox
var boss_enabled: CheckBox
var boss_type_picker: OptionButton
var boss_name_edit: LineEdit
var boss_health_spin: SpinBox
var boss_minion_picker: OptionButton
var boss_interval_spin: SpinBox
var boss_arena_pos_edit: LineEdit
var boss_arena_size_edit: LineEdit
var file_dialog: FileDialog
var notice_dialog: AcceptDialog
var confirm_dialog: ConfirmationDialog

func _ready() -> void:
	_build_interface()
	if not _restore_after_test_play():
		_new_document()

func _restore_after_test_play() -> bool:
	"""Reopen the document being edited when returning from a test play."""
	var session = get_node_or_null("/root/GameSession")
	if session == null or not session.is_custom_level():
		return false
	var restored := _read_document(TEST_LEVEL_PATH)
	current_path = session.editor_source_path
	session.custom_level_path = ""
	session.editor_source_path = ""
	if restored.is_empty():
		return false
	document = restored
	undo_stack.clear()
	redo_stack.clear()
	_sync_controls()
	# The edited level may differ from the file on disk, so keep the save prompt armed.
	dirty = true
	return true

func _read_document(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or not event.ctrl_pressed:
		return
	match event.keycode:
		KEY_Z:
			if event.shift_pressed:
				_redo()
			else:
				_undo()
			get_viewport().set_input_as_handled()
		KEY_Y:
			_redo()
			get_viewport().set_input_as_handled()
		KEY_S:
			_save()
			get_viewport().set_input_as_handled()

func _push_undo() -> void:
	undo_stack.append(document.duplicate(true))
	if undo_stack.size() > MAX_UNDO:
		undo_stack.pop_front()
	redo_stack.clear()

func _undo() -> void:
	if undo_stack.is_empty():
		return
	redo_stack.append(document.duplicate(true))
	document = undo_stack.pop_back()
	dirty = true
	_sync_controls()
	dirty = true

func _redo() -> void:
	if redo_stack.is_empty():
		return
	undo_stack.append(document.duplicate(true))
	document = redo_stack.pop_back()
	_sync_controls()
	dirty = true

func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)
	root.add_theme_constant_override("margin_left", 16)
	root.add_theme_constant_override("margin_top", 12)

	var header := HBoxContainer.new()
	root.add_child(header)
	_add_button(header, "Nouveau", _request_new)
	_add_button(header, "Ouvrir…", _open_dialog)
	_add_button(header, "Enregistrer", _save)
	_add_button(header, "Enregistrer sous…", _save_as_dialog)
	_add_button(header, "Annuler (Ctrl+Z)", _undo)
	_add_button(header, "Rétablir (Ctrl+Y)", _redo)
	_add_button(header, "Vérifier", _check_level)
	_add_button(header, "Tester le niveau", _test_level)
	path_label = Label.new()
	path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_label.text = "Nouveau niveau"
	header.add_child(path_label)

	var content := HSplitContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(content)

	var grid_panel := PanelContainer.new()
	grid_panel.custom_minimum_size = Vector2(670, 0)
	content.add_child(grid_panel)
	var grid_column := VBoxContainer.new()
	grid_panel.add_child(grid_column)
	var grid_info := Label.new()
	grid_info.text = "Grille 16 × 15 — clic gauche pour placer l’outil sélectionné"
	grid_column.add_child(grid_info)
	grid_view = GridView.new()
	grid_view.custom_minimum_size = Vector2(640, 600)
	grid_view.cell_selected.connect(_on_cell_selected)
	grid_view.cell_erased.connect(_on_cell_erased)
	grid_view.stroke_started.connect(_push_undo)
	grid_column.add_child(grid_view)
	var legend := Label.new()
	legend.text = "P départ · U urne · E ennemi · S générateur · R ressort · T rotateur · W téléporteur · I glissant · 1 porte · C tapis · K bloc poussable · G bonus glace · O boule P · M/ M\\ miroir · Z interrupteur (+ id) · trait coloré = porte · B boss"
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	grid_column.add_child(legend)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(390, 0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var panel := VBoxContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(panel)

	_add_heading(panel, "Niveau")
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Nom du niveau"
	_add_labeled(panel, "Nom", name_edit)
	world_spin = _add_spin(panel, "Monde", 1, 4, 1, 1)
	level_spin = _add_spin(panel, "Niveau", 1, 99, 1, 1)
	time_spin = _add_spin(panel, "Temps limite (s)", 1, 9999, 90, 1)

	_add_heading(panel, "Outil de placement")
	tool_picker = OptionButton.new()
	for index in range(TOOLS.size()):
		tool_picker.add_item(TOOLS[index], index)
	tool_picker.item_selected.connect(func(index: int): active_tool = index)
	_add_labeled(panel, "Outil", tool_picker)

	terrain_picker = OptionButton.new()
	for code in TILE_CODES:
		terrain_picker.add_item("%s (%s)" % [TILE_CODES[code], code])
	_add_labeled(panel, "Terrain à peindre", terrain_picker)

	enemy_picker = OptionButton.new()
	for enemy_type in ENEMY_TYPES:
		enemy_picker.add_item(enemy_type)
	_add_labeled(panel, "Type d’ennemi", enemy_picker)
	pattern_edit = LineEdit.new()
	pattern_edit.text = "right,left"
	pattern_edit.placeholder_text = "Ex.: right,left,up"
	_add_labeled(panel, "Patrouille", pattern_edit)

	direction_picker = OptionButton.new()
	for direction in ["right", "down", "left", "up"]:
		direction_picker.add_item(direction)
	_add_labeled(panel, "Direction", direction_picker)
	rotator_picker = OptionButton.new()
	rotator_picker.add_item("Sens horaire (+1)", 1)
	rotator_picker.add_item("Sens antihoraire (-1)", -1)
	_add_labeled(panel, "Rotation", rotator_picker)
	pair_edit = LineEdit.new()
	pair_edit.text = "A"
	_add_labeled(panel, "Identifiant de paire warp", pair_edit)
	mirror_picker = OptionButton.new()
	mirror_picker.add_item("slash")
	mirror_picker.add_item("backslash")
	_add_labeled(panel, "Miroir (/ ou \\)", mirror_picker)
	link_edit = LineEdit.new()
	link_edit.text = "A"
	link_edit.placeholder_text = "Ex.: A, B, rouge…"
	_add_labeled(panel, "Identifiant interrupteur / porte", link_edit)
	interval_spin = _add_spin(panel, "Intervalle générateur (s)", 0.2, 60, 5, 0.1)

	_add_heading(panel, "Boss (facultatif)")
	boss_enabled = CheckBox.new()
	boss_enabled.text = "Activer la configuration de boss"
	panel.add_child(boss_enabled)
	boss_type_picker = _add_option(panel, "Type", BOSS_TYPES)
	boss_name_edit = _add_line(panel, "Nom", "Gardien")
	boss_health_spin = _add_spin(panel, "Points de vie", 1, 99, 3, 1)
	boss_minion_picker = _add_option(panel, "Type de sbire", ENEMY_TYPES)
	boss_interval_spin = _add_spin(panel, "Intervalle sbires (s)", 0.2, 60, 4, 0.1)
	boss_arena_pos_edit = _add_line(panel, "Arène origine x,y", "4,3")
	boss_arena_size_edit = _add_line(panel, "Arène taille l,h", "9,9")
	var help := Label.new()
	help.text = "Pour placer le boss, activez sa configuration puis choisissez l’outil « Boss » et cliquez dans la grille. Les positions sont en coordonnées x,y, depuis le coin supérieur gauche."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(help)

	for control in [name_edit, world_spin, level_spin, time_spin, pattern_edit, pair_edit, interval_spin, boss_enabled, boss_type_picker, boss_name_edit, boss_health_spin, boss_minion_picker, boss_interval_spin, boss_arena_pos_edit, boss_arena_size_edit]:
		if control is LineEdit:
			control.text_changed.connect(_on_metadata_changed)
		elif control is SpinBox:
			control.value_changed.connect(_on_metadata_changed)
		elif control is CheckBox:
			control.toggled.connect(_on_metadata_changed)
		elif control is OptionButton:
			control.item_selected.connect(_on_metadata_changed)

	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.json", "Niveaux JSON")
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)
	notice_dialog = AcceptDialog.new()
	add_child(notice_dialog)
	confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.confirmed.connect(_confirm_pending_action)
	add_child(confirm_dialog)

func _add_heading(parent: VBoxContainer, title: String) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 18)
	parent.add_child(label)

func _add_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)

func _add_labeled(parent: VBoxContainer, title: String, control: Control) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = title
	label.custom_minimum_size.x = 150
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	parent.add_child(row)

func _add_line(parent: VBoxContainer, title: String, initial: String) -> LineEdit:
	var edit := LineEdit.new()
	edit.text = initial
	_add_labeled(parent, title, edit)
	return edit

func _add_spin(parent: VBoxContainer, title: String, minimum: float, maximum: float, initial: float, step: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.value = initial
	spin.step = step
	_add_labeled(parent, title, spin)
	return spin

func _add_option(parent: VBoxContainer, title: String, items: Array) -> OptionButton:
	var option := OptionButton.new()
	for item in items:
		option.add_item(str(item))
	_add_labeled(parent, title, option)
	return option

func _select_text(option: OptionButton, value: String) -> void:
	"""Select value, appending it first if a loaded file uses a type missing from the list."""
	for index in range(option.item_count):
		if option.get_item_text(index) == value:
			option.select(index)
			return
	option.add_item(value)
	option.select(option.item_count - 1)

func _new_document() -> void:
	document = {
		"world": 1,
		"level": 1,
		"name": "Nouveau niveau",
		"time_limit": 90,
		"player_start": [1, 1],
		"grid": [],
		"soul_urns": [],
		"enemies": [],
		"spawners": [],
		"springs": [],
		"rotators": [],
		"warps": [],
		"slippery_tiles": [],
		"one_way_gates": [],
		"conveyors": [],
		"push_blocks": [],
		"bonus_items": [],
		"mirrors": [],
		"switches": [],
		"doors": []
	}
	for y in range(Constants.GRID_ROWS):
		var row := ""
		for x in range(Constants.GRID_COLS):
			row += "#" if x == 0 or y == 0 or x == Constants.GRID_COLS - 1 or y == Constants.GRID_ROWS - 1 else "."
		document["grid"].append(row)
	current_path = ""
	dirty = false
	_sync_controls()

func _sync_controls() -> void:
	loading_document = true
	name_edit.text = str(document.get("name", ""))
	world_spin.value = int(document.get("world", 1))
	level_spin.value = int(document.get("level", 1))
	time_spin.value = int(document.get("time_limit", 90))
	var boss: Dictionary = document.get("boss", {})
	boss_enabled.button_pressed = not boss.is_empty()
	_select_text(boss_type_picker, str(boss.get("type", "cyclops")))
	boss_name_edit.text = str(boss.get("name", "Gardien"))
	boss_health_spin.value = int(boss.get("health", 3))
	_select_text(boss_minion_picker, str(boss.get("minion_type", "noggle")))
	boss_interval_spin.value = float(boss.get("spawn_interval", 4.0))
	boss_arena_pos_edit.text = _array_to_text(boss.get("arena_pos", [4, 3]))
	boss_arena_size_edit.text = _array_to_text(boss.get("arena_size", [9, 9]))
	path_label.text = current_path if not current_path.is_empty() else "Nouveau niveau"
	grid_view.document = document
	grid_view.queue_redraw()
	loading_document = false

func _on_metadata_changed(_value: Variant = null) -> void:
	if not loading_document:
		dirty = true

func _on_cell_selected(pos: Vector2i) -> void:
	match active_tool:
		0:
			var codes := TILE_CODES.keys()
			var code: String = codes[terrain_picker.selected]
			var row: String = document["grid"][pos.y]
			document["grid"][pos.y] = row.substr(0, pos.x) + code + row.substr(pos.x + 1)
		1:
			document["player_start"] = [pos.x, pos.y]
		2:
			_remove_position_entries("soul_urns", pos)
			document["soul_urns"].append([pos.x, pos.y])
		3:
			_add_entity("enemies", {"type": enemy_picker.get_item_text(enemy_picker.selected), "pos": [pos.x, pos.y], "pattern": _pattern_names()})
		4:
			_add_entity("spawners", {"type": enemy_picker.get_item_text(enemy_picker.selected), "pos": [pos.x, pos.y], "pattern": _pattern_names(), "interval": interval_spin.value})
		5:
			_place_or_rotate("springs", pos)
		6:
			_add_entity("rotators", {"pos": [pos.x, pos.y], "quarter_turns": rotator_picker.get_selected_id()})
		7:
			_add_entity("warps", {"pos": [pos.x, pos.y], "pair_id": pair_edit.text.strip_edges() if not pair_edit.text.strip_edges().is_empty() else "A"})
		8:
			_remove_position_entries("slippery_tiles", pos)
			document["slippery_tiles"].append([pos.x, pos.y])
		9:
			_place_or_rotate("one_way_gates", pos)
		10:
			_place_or_rotate("conveyors", pos)
		11:
			if boss_enabled.button_pressed:
				document["boss"] = _boss_document(pos)
			else:
				_show_notice("Cochez d’abord « Activer la configuration de boss ».")
		12:
			_erase_at(pos)
		13:
			_remove_position_entries("push_blocks", pos)
			document["push_blocks"].append([pos.x, pos.y])
		14:
			_add_entity("bonus_items", {"pos": [pos.x, pos.y], "kind": "ambrosia"})
		15:
			_add_entity("bonus_items", {"pos": [pos.x, pos.y], "kind": "gorgon_orb"})
		16:
			_place_mirror(pos)
		17:
			_add_entity("switches", {"pos": [pos.x, pos.y], "id": _link_id()})
		18:
			_place_door(pos)
	dirty = true
	grid_view.queue_redraw()

func _on_cell_erased(pos: Vector2i) -> void:
	_erase_at(pos)
	dirty = true
	grid_view.queue_redraw()

func _place_or_rotate(key: String, pos: Vector2i) -> void:
	"""Directional pieces: click an empty cell to place one facing the chosen direction,
	click an existing one with the same tool to turn it a quarter clockwise."""
	for entry in document.get(key, []):
		if typeof(entry) == TYPE_DICTIONARY and _position_matches(entry.get("pos", []), pos):
			var order := ["right", "down", "left", "up"]
			var index := order.find(str(entry.get("direction", "right")).to_lower())
			entry["direction"] = order[(index + 1) % 4]
			return
	_add_entity(key, {"pos": [pos.x, pos.y], "direction": _selected_direction()})

func _link_id() -> String:
	var id := link_edit.text.strip_edges()
	return id if not id.is_empty() else "A"

func _place_mirror(pos: Vector2i) -> void:
	"""Click an empty cell to place a mirror with the chosen look; click an existing one to flip it."""
	for entry in document.get("mirrors", []):
		if _position_matches(entry.get("pos", []), pos):
			entry["orientation"] = "slash" if str(entry.get("orientation", "slash")) == "backslash" else "backslash"
			return
	_add_entity("mirrors", {"pos": [pos.x, pos.y], "orientation": mirror_picker.get_item_text(mirror_picker.selected)})

func _place_door(pos: Vector2i) -> void:
	"""A door sits on the edge between this cell and its neighbour in the chosen direction. Click it again to turn it a
	quarter clockwise; a door pointing outside the grid is skipped to the next direction."""
	var order := ["right", "down", "left", "up"]
	var offsets := {"right": Vector2i.RIGHT, "down": Vector2i.DOWN, "left": Vector2i.LEFT, "up": Vector2i.UP}
	for entry in document.get("doors", []):
		if _position_matches(entry.get("pos", []), pos):
			var index := order.find(str(entry.get("direction", "right")).to_lower())
			for step in range(1, 5):
				var candidate: String = order[(index + step) % 4]
				var other: Vector2i = pos + offsets[candidate]
				if other.x >= 0 and other.x < Constants.GRID_COLS and other.y >= 0 and other.y < Constants.GRID_ROWS:
					entry["direction"] = candidate
					entry["id"] = _link_id()
					return
			return
	var direction := _selected_direction()
	var neighbour: Vector2i = pos + offsets[direction]
	if neighbour.x < 0 or neighbour.x >= Constants.GRID_COLS or neighbour.y < 0 or neighbour.y >= Constants.GRID_ROWS:
		_show_notice("Une porte doit séparer deux cases de la grille : choisissez une autre direction.")
		return
	_add_entity("doors", {"pos": [pos.x, pos.y], "direction": direction, "id": _link_id()})

func _add_entity(key: String, entry: Dictionary) -> void:
	_remove_position_entries(key, Vector2i(entry["pos"][0], entry["pos"][1]))
	document[key].append(entry)

func _remove_position_entries(key: String, pos: Vector2i) -> void:
	var entries: Array = document.get(key, [])
	for index in range(entries.size() - 1, -1, -1):
		var entry: Variant = entries[index]
		var value: Variant = entry.get("pos", []) if typeof(entry) == TYPE_DICTIONARY else entry
		if _position_matches(value, pos):
			entries.remove_at(index)
	document[key] = entries

func _erase_at(pos: Vector2i) -> void:
	var row: String = document["grid"][pos.y]
	document["grid"][pos.y] = row.substr(0, pos.x) + "." + row.substr(pos.x + 1)
	for key in ["soul_urns", "enemies", "spawners", "springs", "rotators", "warps", "slippery_tiles", "one_way_gates", "conveyors", "push_blocks", "bonus_items", "mirrors", "switches", "doors"]:
		_remove_position_entries(key, pos)
	var boss: Dictionary = document.get("boss", {})
	if not boss.is_empty() and _position_matches(boss.get("pos", []), pos):
		document.erase("boss")

func _boss_document(pos: Vector2i) -> Dictionary:
	var arena_pos := _parse_pair(boss_arena_pos_edit.text, [4, 3])
	var arena_size := _parse_pair(boss_arena_size_edit.text, [9, 9])
	return {
		"type": boss_type_picker.get_item_text(boss_type_picker.selected),
		"name": boss_name_edit.text.strip_edges(),
		"health": int(boss_health_spin.value),
		"pos": [pos.x, pos.y],
		"minion_type": boss_minion_picker.get_item_text(boss_minion_picker.selected),
		"spawn_interval": boss_interval_spin.value,
		"arena_pos": arena_pos,
		"arena_size": arena_size
	}

func _selected_direction() -> String:
	return direction_picker.get_item_text(direction_picker.selected)

func _pattern_names() -> Array[String]:
	var result: Array[String] = []
	for name in pattern_edit.text.split(",", false):
		var direction := name.strip_edges().to_lower()
		if direction in ["right", "down", "left", "up"]:
			result.append(direction)
	return result

func _position_matches(value: Variant, pos: Vector2i) -> bool:
	return typeof(value) == TYPE_ARRAY and value.size() == 2 and int(value[0]) == pos.x and int(value[1]) == pos.y

func _array_to_text(value: Variant) -> String:
	if typeof(value) != TYPE_ARRAY or value.size() != 2:
		return "0,0"
	return "%s,%s" % [value[0], value[1]]

func _parse_pair(value: String, fallback: Array) -> Array:
	var parts := value.split(",", false)
	if parts.size() != 2 or not parts[0].strip_edges().is_valid_int() or not parts[1].strip_edges().is_valid_int():
		return fallback.duplicate()
	return [int(parts[0]), int(parts[1])]

func _request_new() -> void:
	_request_action(_new_document)

func _request_action(action: Callable) -> void:
	if dirty:
		pending_action = action
		confirm_dialog.dialog_text = "Les modifications non enregistrées seront perdues. Continuer ?"
		confirm_dialog.popup_centered()
	else:
		action.call()

func _confirm_pending_action() -> void:
	if pending_action.is_valid():
		pending_action.call()
	pending_action = Callable()

func _open_dialog() -> void:
	pending_action = _show_open_dialog
	if dirty:
		confirm_dialog.dialog_text = "Les modifications non enregistrées seront perdues. Continuer ?"
		confirm_dialog.popup_centered()
	else:
		_show_open_dialog()

func _show_open_dialog() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_dir = ProjectSettings.globalize_path("res://Data/Levels")
	file_dialog.popup_centered_ratio(0.8)

func _on_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_save_to(path)
	else:
		_load_file(path)

func _save_as_dialog() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.current_dir = ProjectSettings.globalize_path("res://Data/Levels")
	file_dialog.current_file = "world_%d_level_%d.json" % [int(world_spin.value), int(level_spin.value)]
	file_dialog.popup_centered_ratio(0.8)

func _load_file(path: String) -> void:
	var loader = preload("res://Scripts/level_json_loader.gd").new()
	var result: Dictionary = loader.load_file(path)
	if not result.get("ok", false):
		_show_notice("Impossible de charger ce niveau :\n%s" % result.get("error", "Erreur inconnue"))
		return
	var parsed := _read_document(path)  # the loader already validated the file, so this only needs the raw document
	if parsed.is_empty():
		_show_notice("Impossible d’ouvrir le fichier :\n%s" % FileAccess.get_open_error())
		return
	document = parsed
	current_path = path
	dirty = false
	_sync_controls()

func _save() -> void:
	if current_path.is_empty():
		_save_as_dialog()
		return
	_save_to(current_path)

func _apply_metadata() -> void:
	"""Copy the side-panel fields into the document before validating, saving or testing."""
	document["name"] = name_edit.text.strip_edges()
	document["world"] = int(world_spin.value)
	document["level"] = int(level_spin.value)
	document["time_limit"] = int(time_spin.value)
	if boss_enabled.button_pressed:
		var boss: Dictionary = document.get("boss", {})
		if boss.is_empty():
			boss = _boss_document(Vector2i(8, 7))
		else:
			var boss_pos: Array = boss.get("pos", [8, 7])
			boss = _boss_document(Vector2i(int(boss_pos[0]), int(boss_pos[1])))
		document["boss"] = boss
	else:
		document.erase("boss")

func _check_level() -> void:
	_apply_metadata()
	var loader = preload("res://Scripts/level_json_loader.gd").new()
	var validation_error: String = loader.validate_document(document)
	if not validation_error.is_empty():
		_show_notice("Le niveau n’est pas valide :\n%s" % validation_error)
		return
	var warnings: Array[String] = LEVEL_CHECKER.check(document)
	if warnings.is_empty():
		_show_notice("Le niveau est valide. Aucun problème détecté.")
	else:
		_show_notice("Le niveau est valide, mais :\n- %s" % "\n- ".join(PackedStringArray(warnings)))

func _test_level() -> void:
	_apply_metadata()
	var loader = preload("res://Scripts/level_json_loader.gd").new()
	var validation_error: String = loader.validate_document(document)
	if not validation_error.is_empty():
		_show_notice("Le niveau n’est pas valide :\n%s" % validation_error)
		return
	var file := FileAccess.open(TEST_LEVEL_PATH, FileAccess.WRITE)
	if file == null:
		_show_notice("Impossible de préparer le niveau de test :\n%s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(document, "\t") + "\n")
	file.close()
	var session = get_node_or_null("/root/GameSession")
	if session == null:
		_show_notice("Le test nécessite l’autoload GameSession.")
		return
	session.custom_level_path = TEST_LEVEL_PATH
	session.editor_source_path = current_path
	session.selected_world = int(document["world"])
	session.selected_level = int(document["level"])
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _save_to(path: String) -> void:
	_apply_metadata()
	var loader = preload("res://Scripts/level_json_loader.gd").new()
	var validation_error: String = loader.validate_document(document)
	if not validation_error.is_empty():
		_show_notice("Le niveau n’est pas valide :\n%s" % validation_error)
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_show_notice("Impossible d’enregistrer le niveau :\n%s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(document, "\t") + "\n")
	file.close()
	current_path = path
	dirty = false
	_sync_controls()
	_show_notice("Niveau enregistré.")

func _show_notice(message: String) -> void:
	notice_dialog.dialog_text = message
	if notice_dialog.is_inside_tree():
		notice_dialog.popup_centered()
