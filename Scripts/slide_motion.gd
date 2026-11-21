extends RefCounted
class_name SlideMotion

## Animates a block or statue whose slide has stops on the way (a hammer strikes it mid-course).
## waypoints: [{"cell": Vector2i, "pause": float, "on_arrive": Callable (optional)}, ...]; the slide ends on final_pos.

const SECONDS_PER_TILE := 0.12
const MIN_SEGMENT := 0.02

static func through(node: Node2D, grid: GridManager, start: Vector2i, waypoints: Array, final_pos: Vector2i) -> Tween:
	var tween := node.create_tween()
	var from := start
	for waypoint in waypoints:
		var cell: Vector2i = waypoint["cell"]
		tween.tween_property(node, "position", grid.grid_to_world(cell), maxf(MIN_SEGMENT, SECONDS_PER_TILE * Vector2(from).distance_to(Vector2(cell))))
		var on_arrive = waypoint.get("on_arrive", null)
		if on_arrive is Callable and (on_arrive as Callable).is_valid():
			tween.tween_callback(on_arrive)
		if float(waypoint.get("pause", 0.0)) > 0.0:
			tween.tween_interval(float(waypoint["pause"]))
		from = cell
	tween.tween_property(node, "position", grid.grid_to_world(final_pos), maxf(MIN_SEGMENT, SECONDS_PER_TILE * Vector2(from).distance_to(Vector2(final_pos)))).set_ease(Tween.EASE_OUT)
	return tween
