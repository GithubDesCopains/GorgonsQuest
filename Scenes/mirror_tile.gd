extends Node2D
class_name MirrorTile

## 45-degree mirror on a marble pedestal. Solid like a wall; the laser bends by 90 degrees on it.
## "slash" is drawn "/" (right -> up), "backslash" is drawn "\" (right -> down).

const INK := Color("1A1418")
const MARBLE := Color("E3D6B4")
const MARBLE_SHADE := Color("BFAE86")
const GLASS := Color("BFE8F2")
const GLASS_SHINE := Color("F5FDFF")

var grid_pos: Vector2i
var orientation: String = "slash"
var grid_manager: GridManager

func initialize(pos: Vector2i, new_orientation: String, grid: GridManager) -> void:
	grid_manager = grid
	grid_pos = pos
	orientation = new_orientation
	position = grid.grid_to_world(pos)
	z_index = Constants.LAYER_OBJECTS
	add_to_group("mirrors")
	grid.set_mirror(pos, new_orientation)
	queue_redraw()

func set_orientation(new_orientation: String) -> void:
	orientation = new_orientation
	queue_redraw()
	if is_inside_tree():
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.06)
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func pane_ends() -> Array[Vector2]:
	"""The two ends of the glass pane, in local coordinates."""
	var h := Constants.TILE_SIZE * 0.5 - 14.0
	if orientation == "backslash":
		return [Vector2(-h, -h), Vector2(h, h)]
	return [Vector2(-h, h), Vector2(h, -h)]

func _draw() -> void:
	var half := Constants.TILE_SIZE * 0.5 - 6.0
	var rect := Rect2(Vector2(-half, -half), Vector2(half * 2.0, half * 2.0))
	draw_rect(rect, MARBLE)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y * 0.72), Vector2(rect.size.x, rect.size.y * 0.28)), MARBLE_SHADE)
	draw_rect(rect, INK, false, 3.5)
	var ends := pane_ends()
	draw_line(ends[0], ends[1], INK, 15.0, true)       # black outline
	draw_line(ends[0], ends[1], GLASS, 9.0, true)      # glass
	draw_line(ends[0] + (ends[1] - ends[0]) * 0.18, ends[0] + (ends[1] - ends[0]) * 0.55, GLASS_SHINE, 3.0, true)
