extends CanvasLayer

## Game Over Screen - Displayed when player runs out of lives

signal retry_pressed()
signal menu_pressed()

@onready var panel: Panel
@onready var title_label: Label
@onready var message_label: Label
@onready var retry_button: Button
@onready var menu_button: Button

func _ready():
	create_ui()
	hide()

func create_ui():
	# Semi-transparent background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	add_child(bg)
	
	# Center panel
	panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(600, 400)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_top = -200
	panel.offset_right = 300
	panel.offset_bottom = 200
	add_child(panel)
	
	# VBox for layout
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 30)
	panel.add_child(vbox)
	
	# Add spacing at top
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(top_spacer)
	
	# Title
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "☠️ GAME OVER ☠️"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.add_theme_constant_override("outline_size", 4)
	vbox.add_child(title_label)
	
	# Message
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = "You ran out of lives!"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(message_label)
	
	# Button container
	var button_hbox = HBoxContainer.new()
	button_hbox.name = "ButtonHBox"
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(button_hbox)
	
	# Retry button
	retry_button = Button.new()
	retry_button.name = "RetryButton"
	retry_button.text = "Retry"
	retry_button.custom_minimum_size = Vector2(180, 60)
	retry_button.add_theme_font_size_override("font_size", 24)
	retry_button.pressed.connect(_on_retry_pressed)
	button_hbox.add_child(retry_button)
	
	# Add bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(bottom_spacer)

func show_game_over():
	show()
	# Animate entrance
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_retry_pressed():
	retry_pressed.emit()

func _on_menu_pressed():
	menu_pressed.emit()
