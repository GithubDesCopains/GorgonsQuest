extends Node2D
class_name BonusItem

## Level bonus picked up by walking on it.
## ambrosia   : pale ice crystal worth points.
## gorgon_orb : violet "P" orb that turns every living enemy into stone.

const KINDS := ["ambrosia", "gorgon_orb"]
const AMBROSIA_POINTS := 500

var grid_pos: Vector2i
var kind: String = "ambrosia"
var collected: bool = false
var _time: float = 0.0

signal collected_signal(item)

func initialize(pos: Vector2i, item_kind: String, grid: GridManager) -> void:
	grid_pos = pos
	kind = item_kind if KINDS.has(item_kind) else "ambrosia"
	position = grid.grid_to_world(pos)
	z_index = Constants.LAYER_OBJECTS
	add_to_group("bonus_items")
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func collect() -> void:
	if collected:
		return
	collected = true
	collected_signal.emit(self)
	if not is_inside_tree():
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)

func _draw() -> void:
	var pulse := 1.0 + sin(_time * 4.0) * 0.07
	if kind == "gorgon_orb":
		draw_circle(Vector2.ZERO, 27.0 * pulse, Color("4B2A7A"))
		draw_circle(Vector2.ZERO, 21.0 * pulse, Color("8F5FD0"))
		draw_circle(Vector2(-7, -8), 6.0, Color(1, 1, 1, 0.45))
		var font := ThemeDB.fallback_font
		var text_size := font.get_string_size("P", HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
		draw_string(font, Vector2(-text_size.x * 0.5, text_size.y * 0.3), "P", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
	else:
		var r := 27.0 * pulse
		var crystal := PackedVector2Array([Vector2(0, -r), Vector2(r * 0.7, 0), Vector2(0, r), Vector2(-r * 0.7, 0)])
		draw_colored_polygon(crystal, Color("BDE8F2"))
		draw_polyline(PackedVector2Array([crystal[0], crystal[1], crystal[2], crystal[3], crystal[0]]), Color("5FA3BA"), 2.5)
		draw_line(Vector2(0, -r), Vector2(0, r), Color("E8F8FC"), 1.5)
		draw_line(Vector2(-r * 0.7, 0), Vector2(r * 0.7, 0), Color("E8F8FC"), 1.5)
