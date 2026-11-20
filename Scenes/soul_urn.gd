extends Node2D
class_name SoulUrn

## Collectible soul urn (replaces Dream Bag from original)

var grid_pos: Vector2i
var collected: bool = false
var initial_y: float = 0.0

signal collected_signal(urn)

func _ready():
	# Create visual (golden vase)
	var visual = ColorRect.new()
	visual.size = Vector2(40, 40)
	visual.position = Vector2(-20, -20)
	visual.color = Constants.COLOR_GOLD
	add_child(visual)
	
	# Add shine effect
	var shine = ColorRect.new()
	shine.size = Vector2(20, 20)
	shine.position = Vector2(-10, -10)
	shine.color = Color(1, 1, 0.8, 0.6)
	add_child(shine)
	
	z_index = Constants.LAYER_OBJECTS

func initialize(pos: Vector2i):
	"""Initialize urn at grid position"""
	grid_pos = pos
	var grid_manager = get_node("/root/Main/GameManager/GridManager")
	position = grid_manager.grid_to_world(grid_pos)
	initial_y = position.y
	
	# Start bobbing animation after position is set
	await get_tree().process_frame
	start_bobbing_animation()

func start_bobbing_animation():
	"""Gentle bobbing animation"""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", initial_y - 5, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", initial_y + 5, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func collect():
	"""Collect this urn"""
	if collected:
		return
	
	collected = true
	collected_signal.emit(self)
	
	# Stop any tweens
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
	
	print("✨ Soul Urn collected!")

