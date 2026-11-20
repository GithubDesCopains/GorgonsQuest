extends CanvasLayer

## HUD - Displays game information (lives, souls, level, score)

@onready var lives_label: Label
@onready var souls_label: Label
@onready var level_label: Label
@onready var score_label: Label
@onready var time_label: Label

var game_manager: Node

func _ready():
	# Add to group for easy finding
	add_to_group("hud")
	
	# Create UI elements
	create_ui()
	
	# Wait for game manager
	await get_tree().process_frame
	game_manager = get_node("/root/Main/GameManager")
	
	if game_manager:
		# Connect to signals
		game_manager.lives_changed.connect(_on_lives_changed)
		if game_manager.has_signal("score_changed"):
			game_manager.score_changed.connect(_on_score_changed)
		if game_manager.has_signal("time_changed"):
			game_manager.time_changed.connect(_on_time_changed)
		
		# Initial update
		update_lives(game_manager.current_lives)
		update_souls(game_manager.souls_collected, game_manager.souls_required)
		update_level(game_manager.current_world, game_manager.current_level)
		if "score" in game_manager:
			update_score(game_manager.score)
		if "time_remaining" in game_manager:
			update_time(int(ceil(game_manager.time_remaining)))

func create_ui():
	# Top bar container
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	# HBox container across top
	var top_hbox = HBoxContainer.new()
	top_hbox.name = "TopHBox"
	top_hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	margin.add_child(top_hbox)
	
	# Left VBox (Lives & Souls & Level)
	var left_vbox = VBoxContainer.new()
	left_vbox.name = "LeftVBox"
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_theme_constant_override("separation", 8)
	top_hbox.add_child(left_vbox)
	
	# Lives display
	var lives_hbox = HBoxContainer.new()
	lives_hbox.name = "LivesHBox"
	left_vbox.add_child(lives_hbox)
	
	var lives_icon = create_label("❤️", 30)
	lives_hbox.add_child(lives_icon)
	
	lives_label = create_label("5", 30)
	lives_label.name = "LivesLabel"
	lives_hbox.add_child(lives_label)
	
	# Souls display
	var souls_hbox = HBoxContainer.new()
	souls_hbox.name = "SoulsHBox"
	left_vbox.add_child(souls_hbox)
	
	var souls_icon = create_label("✨", 26)
	souls_hbox.add_child(souls_icon)
	
	souls_label = create_label("0/5", 26)
	souls_label.name = "SoulsLabel"
	souls_hbox.add_child(souls_label)
	
	# Level display
	level_label = create_label("World 1 - Level 1", 22)
	level_label.name = "LevelLabel"
	left_vbox.add_child(level_label)
	
	# Center VBox (Time display)
	var center_vbox = VBoxContainer.new()
	center_vbox.name = "CenterVBox"
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_hbox.add_child(center_vbox)
	
	var time_title = create_label("TIME", 20)
	time_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_vbox.add_child(time_title)
	
	time_label = create_label("090", 30)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	center_vbox.add_child(time_label)
	
	# Right VBox (Score display)
	var right_vbox = VBoxContainer.new()
	right_vbox.name = "RightVBox"
	right_vbox.size_flags_horizontal = Control.SIZE_SHRINK_END
	top_hbox.add_child(right_vbox)
	
	var score_title = create_label("SCORE", 20)
	score_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_vbox.add_child(score_title)
	
	score_label = create_label("000000", 30)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	right_vbox.add_child(score_label)

func create_label(text: String, font_size: int) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	return label

func _on_lives_changed(lives: int):
	update_lives(lives)

func _on_score_changed(new_score: int):
	update_score(new_score)

func _on_time_changed(time_left: int):
	update_time(time_left)

func update_lives(lives: int):
	if lives_label:
		lives_label.text = str(lives)
		if lives < 5:
			var tween = create_tween()
			tween.tween_property(lives_label, "modulate", Color.RED, 0.2)
			tween.tween_property(lives_label, "modulate", Color.WHITE, 0.2)

func update_souls(collected: int, total: int):
	if souls_label:
		souls_label.text = str(collected) + "/" + str(total)
		var tween = create_tween()
		tween.tween_property(souls_label, "scale", Vector2(1.3, 1.3), 0.15)
		tween.tween_property(souls_label, "scale", Vector2.ONE, 0.15)

func update_level(world: int, level: int):
	if level_label:
		level_label.text = "World " + str(world) + " - Level " + str(level)

func update_score(new_score: int):
	if score_label:
		score_label.text = "%06d" % new_score
		var tween = create_tween()
		tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(score_label, "scale", Vector2.ONE, 0.1)


func update_time(time_left: int):
	if time_label:
		time_label.text = "%03d" % max(0, time_left)
		if time_left <= 15 and time_left > 0:
			time_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
		else:
			time_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
