extends CanvasLayer

## Pause menu, constructed with standard Control nodes for reliable input/rendering.

const MENU_ITEMS := ["Reprendre", "Recommencer le niveau", "Options", "Carte du monde"]
const GOLD := Color("D4A96A")
const MARBLE := Color("E8DCC4")

var selected_item: int = 0
var is_open: bool = false
var _buttons: Array[Button] = []

signal resume_requested
signal restart_requested
signal options_requested
signal overworld_requested

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	visible = false

func _build_ui() -> void:
	var background := ColorRect.new()
	background.name = "DimBackground"
	background.color = Color(0.02, 0.02, 0.05, 0.78)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(background)

	var panel := PanelContainer.new()
	panel.name = "PausePanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-300, -250)
	panel.size = Vector2(600, 500)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	background.add_child(panel)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)

	var title := Label.new()
	title.text = "PAUSE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_font_size_override("font_size", 48)
	column.add_child(title)

	for i in range(MENU_ITEMS.size()):
		var button := Button.new()
		button.text = MENU_ITEMS[i]
		button.custom_minimum_size = Vector2(440, 64)
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_color_override("font_color", MARBLE)
		button.add_theme_color_override("font_hover_color", GOLD)
		button.add_theme_font_size_override("font_size", 26)
		button.pressed.connect(_on_button_pressed.bind(i))
		column.add_child(button)
		_buttons.append(button)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202033")
	style.border_color = GOLD
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	return style

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_open:
			_close()
		else:
			_open()
		get_viewport().set_input_as_handled()
		return
	if not is_open:
		return
	if event.is_action_pressed("ui_down"):
		selected_item = (selected_item + 1) % MENU_ITEMS.size()
		_buttons[selected_item].grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		selected_item = (selected_item - 1 + MENU_ITEMS.size()) % MENU_ITEMS.size()
		_buttons[selected_item].grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_activate_selected()
		get_viewport().set_input_as_handled()

func _open() -> void:
	is_open = true
	visible = true
	selected_item = 0
	if is_inside_tree():
		get_tree().paused = true
	if not _buttons.is_empty() and is_inside_tree():
		_buttons[0].grab_focus()

func _close() -> void:
	is_open = false
	visible = false
	if is_inside_tree():
		get_tree().paused = false
	resume_requested.emit()

func _activate_selected() -> void:
	_on_button_pressed(selected_item)

func _open_options() -> void:
	var options = load("res://Scenes/options_menu.tscn").instantiate()
	options.name = "OptionsMenu"
	options.open_from("pause")
	get_parent().add_child(options)
	visible = false
	is_open = false
	get_tree().paused = false
	options.closed.connect(_on_options_closed)

func _on_options_closed() -> void:
	if not is_inside_tree():
		return
	visible = true
	is_open = true
	selected_item = 0
	get_tree().paused = true
	if not _buttons.is_empty():
		_buttons[0].grab_focus()

func _on_button_pressed(index: int) -> void:
	match index:
		0:
			_close()
		1:
			get_tree().paused = false
			is_open = false
			visible = false
			restart_requested.emit()
		2:
			options_requested.emit()
			_open_options()
		3:
			if is_inside_tree():
				get_tree().paused = false
			is_open = false
			visible = false
			overworld_requested.emit()
			# A listener (main scene) already changed scene and freed this menu: nothing left to do.
			if not is_inside_tree():
				return
			var session = get_node_or_null("/root/GameSession")
			get_tree().change_scene_to_file(session.scene_after_level() if session else "res://Scenes/overworld_map.tscn")
