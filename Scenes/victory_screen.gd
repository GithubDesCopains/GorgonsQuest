extends CanvasLayer

## Victory Screen - Displayed when level is complete

signal continue_pressed()
signal restart_pressed()

@onready var panel: Panel
@onready var title_label: Label
@onready var message_label: Label
@onready var continue_button: Button
var score_summary_label: Label
var record_label: Label
var _summary: Dictionary = {}
var _displayed_total: int = 0

func _ready():
	create_ui()
	hide()

func create_ui():
	# Semi-transparent background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	add_child(bg)
	
	# Center panel
	panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(760, 650)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -380
	panel.offset_top = -325
	panel.offset_right = 380
	panel.offset_bottom = 325
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
	title_label.text = "🎉 LEVEL COMPLETE! 🎉"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.add_theme_constant_override("outline_size", 4)
	vbox.add_child(title_label)
	
	# Message
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = "All Soul Urns collected!"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(message_label)
	
	# Itemized score breakdown
	score_summary_label = Label.new()
	score_summary_label.name = "ScoreSummaryLabel"
	score_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_summary_label.add_theme_font_size_override("font_size", 24)
	score_summary_label.add_theme_color_override("font_color", Color("E8DCC4"))
	vbox.add_child(score_summary_label)

	record_label = Label.new()
	record_label.name = "RecordLabel"
	record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	record_label.add_theme_font_size_override("font_size", 24)
	record_label.add_theme_color_override("font_color", Color("D4A96A"))
	vbox.add_child(record_label)

	# Button container
	var button_hbox = HBoxContainer.new()
	button_hbox.name = "ButtonHBox"
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(button_hbox)
	
	# Continue button
	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "Continue"
	continue_button.custom_minimum_size = Vector2(200, 60)
	continue_button.add_theme_font_size_override("font_size", 24)
	continue_button.pressed.connect(_on_continue_pressed)
	button_hbox.add_child(continue_button)
	
	# Add bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(bottom_spacer)

func show_victory(summary: Dictionary = {}) -> void:
	_summary = summary.duplicate(true)
	_displayed_total = 0
	if _summary.is_empty():
		_summary = {
			"earned_points": 0, "urn_points": 0, "squash_points": 0,
			"squashed_count": 0, "completion_bonus": 0, "time_remaining": 0,
			"time_bonus": 0, "level_points": 0, "total_score": 0,
			"previous_best": 0, "is_new_record": false
		}
	_update_score_text()
	show()
	if is_inside_tree() and is_instance_valid(panel):
		panel.modulate.a = 0.0
		panel.scale = Vector2(0.5, 0.5)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(panel, "modulate:a", 1.0, 0.3)
		tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		var count_tween := create_tween()
		count_tween.tween_method(_set_displayed_total, 0, int(_summary.get("total_score", 0)), 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		_displayed_total = int(_summary.get("total_score", 0))
		_update_score_text()

func _set_displayed_total(value: int) -> void:
	_displayed_total = value
	_update_score_text()

func _update_score_text() -> void:
	if not is_instance_valid(score_summary_label) or _summary.is_empty():
		return
	var earned: int = int(_summary.get("earned_points", 0))
	var urn_points: int = int(_summary.get("urn_points", 0))
	var squash_points: int = int(_summary.get("squash_points", 0))
	var squashed: int = int(_summary.get("squashed_count", 0))
	var completion: int = int(_summary.get("completion_bonus", 0))
	var time_left: int = int(_summary.get("time_remaining", 0))
	var time_bonus: int = int(_summary.get("time_bonus", 0))
	score_summary_label.text = "Points gagnés : %d\nUrnes : %d    Ennemis écrasés : %d (%d pts)\nBonus de fin : %d    Temps restant : %ds (+%d)\nScore niveau : %d\nScore cumulé : %d" % [earned, urn_points, squashed, squash_points, completion, time_left, time_bonus, int(_summary.get("level_points", 0)), _displayed_total]
	if bool(_summary.get("is_new_record", false)):
		record_label.text = "NOUVEAU RECORD PERSONNEL !"
	else:
		record_label.text = "Meilleur score : %d" % int(_summary.get("previous_best", 0))

func _on_continue_pressed():
	continue_pressed.emit()
	queue_free()
