extends Node2D
class_name PushBlock

## Dark-blue pushable block. It slides like a petrified statue and,
## when it enters water, sinks and leaves a bridge behind.

const SLIDE_SECONDS_PER_TILE := 0.12

var grid_pos: Vector2i
var grid_manager: GridManager
var is_removed: bool = false

func initialize(pos: Vector2i, grid: GridManager) -> void:
	grid_manager = grid
	grid_pos = pos
	position = grid.grid_to_world(pos)
	grid.set_push_block(pos)
	z_index = Constants.LAYER_OBJECTS
	add_to_group("push_blocks")
	queue_redraw()

func release_cell() -> void:
	if grid_manager:
		grid_manager.clear_push_block(grid_pos)

func slide_to(final_pos: Vector2i) -> void:
	"""Slide to final_pos. If that cell is water the block sinks there and becomes a bridge."""
	release_cell()
	var start := grid_pos
	var into_water := grid_manager.get_tile(final_pos) == Constants.TileType.WATER
	grid_pos = final_pos
	var target := grid_manager.grid_to_world(final_pos)
	if not into_water:
		grid_manager.set_push_block(final_pos)
	if not is_inside_tree():
		position = target
		if into_water:
			_become_bridge()
		return
	var distance := Vector2(start).distance_to(Vector2(final_pos))
	var tween := create_tween()
	tween.tween_property(self, "position", target, SLIDE_SECONDS_PER_TILE * maxf(distance, 1.0)).set_ease(Tween.EASE_OUT)
	if into_water:
		await tween.finished
		_become_bridge()

func _become_bridge() -> void:
	if is_removed:
		return
	is_removed = true
	remove_from_group("push_blocks")
	grid_manager.set_tile(grid_pos, Constants.TileType.ICE)
	if not is_inside_tree():
		return
	var main_scene := get_tree().root.get_node_or_null("Main")
	if main_scene and main_scene.has_method("add_bridge_visual"):
		main_scene.add_bridge_visual(grid_pos)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.3)
	await tween.finished
	queue_free()

func _draw() -> void:
	var half := Constants.TILE_SIZE * 0.5 - 7.0
	var rect := Rect2(Vector2(-half, -half), Vector2(half * 2.0, half * 2.0))
	draw_rect(rect, Color("2F4B73"))
	draw_rect(rect.grow(-7.0), Color("3F6291"))
	draw_rect(rect, Color("1E3250"), false, 3.0)
	draw_line(rect.position + Vector2(9, 11), rect.position + Vector2(rect.size.x - 9, 11), Color("7FA3D0"), 2.0)
	draw_line(rect.position + Vector2(11, 11), rect.position + Vector2(11, rect.size.y - 11), Color("7FA3D0"), 2.0)
