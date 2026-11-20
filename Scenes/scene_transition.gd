extends CanvasLayer

## Transition manager : overworld ↔ niveau de puzzle
## Gère le fondu et le chargement de scènes

signal transition_done

var _target_world: int = 1
var _target_level: int = 1

@onready var _overlay := ColorRect.new()

func _ready() -> void:
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

func go_to_level(world: int, level: int) -> void:
	"""Fondu → charge le niveau → fondu retour"""
	_target_world = world
	_target_level = level
	var t := create_tween()
	t.tween_property(_overlay, "color:a", 1.0, 0.4)
	t.tween_callback(_load_level)

func go_to_overworld() -> void:
	"""Fondu → charge l'overworld → fondu retour"""
	var t := create_tween()
	t.tween_property(_overlay, "color:a", 1.0, 0.4)
	t.tween_callback(_load_overworld)

func _load_level() -> void:
	# Informe le GameManager du monde/niveau choisi
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.current_world = _target_world
		gm.current_level = _target_level
		if gm.level_manager and gm.level_manager.has_method("load_level"):
			gm.level_manager.load_level(_target_world, _target_level)
	# Charge la scène de jeu
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	await get_tree().process_frame
	_fade_in()

func _load_overworld() -> void:
	get_tree().change_scene_to_file("res://Scenes/overworld_map.tscn")
	await get_tree().process_frame
	_fade_in()

func _fade_in() -> void:
	var t := create_tween()
	t.tween_property(_overlay, "color:a", 0.0, 0.4)
	t.tween_callback(func(): transition_done.emit())
