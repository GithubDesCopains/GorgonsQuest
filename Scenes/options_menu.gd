extends CanvasLayer

## Options screen: audio, display and control reference.

const GOLD := Color("D4A96A")
const MARBLE := Color("E8DCC4")
var save_manager: Node
var save_path: String = "user://savegame.json"
var _music_slider: HSlider
var _sfx_slider: HSlider
var _fullscreen_check: CheckButton
var _vsync_check: CheckButton
var _previous_scene: String = "title"

signal closed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	save_manager = load("res://Scripts/save_manager.gd").new()
	save_manager.save_path = save_path
	save_manager.name = "OptionsSaveManager"
	add_child(save_manager)
	_build_ui()

func open_from(source: String) -> void:
	_previous_scene = source
	visible = true

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.02, 0.02, 0.05, 0.94)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 820)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)

	var title := Label.new()
	title.text = "OPTIONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_font_size_override("font_size", 42)
	column.add_child(title)

	_add_section_label(column, "AUDIO")
	_music_slider = _add_slider(column, "Musique", save_manager.get_music_volume())
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider = _add_slider(column, "Effets sonores", save_manager.get_sfx_volume())
	_sfx_slider.value_changed.connect(_on_sfx_changed)

	_add_section_label(column, "AFFICHAGE")
	_fullscreen_check = CheckButton.new()
	_fullscreen_check.text = "Plein écran"
	_fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_fullscreen_check.add_theme_color_override("font_color", MARBLE)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	column.add_child(_fullscreen_check)

	_vsync_check = CheckButton.new()
	_vsync_check.text = "Synchronisation verticale (VSync)"
	_vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	_vsync_check.add_theme_color_override("font_color", MARBLE)
	_vsync_check.toggled.connect(_on_vsync_toggled)
	column.add_child(_vsync_check)

	_add_section_label(column, "COMMANDES")
	_add_control_help(column, "Déplacement", "Flèches / WASD / D-pad")
	_add_control_help(column, "Regard pétrifiant", "Espace / Manette A")
	_add_control_help(column, "Pilier de pierre", "Maj / Manette B")
	_add_control_help(column, "Briser statue proche", "Q / Épaule droite")
	_add_control_help(column, "Tourner le miroir en face", "E / Épaule gauche")
	_add_control_help(column, "Pause / Retour", "Échap / Start")

	var back := Button.new()
	back.text = "Retour"
	back.custom_minimum_size = Vector2(0, 58)
	back.add_theme_font_size_override("font_size", 24)
	back.pressed.connect(close_menu)
	column.add_child(back)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202033")
	style.border_color = GOLD
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	return style

func _add_section_label(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", GOLD)
	label.add_theme_font_size_override("font_size", 22)
	parent.add_child(label)

func _add_slider(parent: VBoxContainer, label_text: String, initial_value: float) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(220, 0)
	label.add_theme_color_override("font_color", MARBLE)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value = initial_value
	row.add_child(slider)
	return slider

func _add_control_help(parent: VBoxContainer, action: String, keys: String) -> void:
	var row := HBoxContainer.new()
	var left := Label.new()
	left.text = action
	left.custom_minimum_size = Vector2(250, 0)
	left.add_theme_color_override("font_color", MARBLE)
	var right := Label.new()
	right.text = keys
	right.add_theme_color_override("font_color", MARBLE.darkened(0.25))
	row.add_child(left)
	row.add_child(right)
	parent.add_child(row)

func _on_music_changed(value: float) -> void:
	save_manager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	save_manager.set_sfx_volume(value)

func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED)

func close_menu() -> void:
	visible = false
	closed.emit()
	if _previous_scene == "pause":
		queue_free()
	elif is_inside_tree():
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")

func get_music_slider_value() -> float:
	return _music_slider.value if _music_slider else save_manager.get_music_volume()

func get_sfx_slider_value() -> float:
	return _sfx_slider.value if _sfx_slider else save_manager.get_sfx_volume()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()
