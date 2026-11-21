extends Node
class_name GridManager

## Manages the game grid and coordinate conversions
## Handles world position <-> grid position conversions

var grid_data: Array = []
var spring_directions: Dictionary = {} # Vector2i tile position -> Vector2i direction
var rotator_turns: Dictionary = {} # Vector2i tile position -> int (+1 clockwise, -1 counter-clockwise)
var warp_pairs: Dictionary = {} # String pair ID -> Array[Vector2i] endpoints
var warp_pair_by_position: Dictionary = {} # Vector2i endpoint -> String pair ID
var one_way_directions: Dictionary = {} # Vector2i tile position -> permitted movement direction
var conveyor_directions: Dictionary = {} # Vector2i tile position -> automatic movement direction
var push_block_cells: Dictionary = {} # Vector2i cell currently occupied by a pushable block

var spawner_cells: Dictionary = {} # Vector2i cell holding an enemy spawner: solid like a wall

func set_spawner(grid_pos: Vector2i) -> void:
	spawner_cells[grid_pos] = true

func has_spawner(grid_pos: Vector2i) -> bool:
	return spawner_cells.has(grid_pos)

func clear_spawners() -> void:
	spawner_cells.clear()

# --- Mirrors: solid like a wall, they bend the laser by 90 degrees --------------------------
const MIRROR_SLASH := "slash"          # "/" : right -> up, up -> right, left -> down, down -> left
const MIRROR_BACKSLASH := "backslash"  # "\" : right -> down, down -> right, left -> up, up -> left
var mirror_cells: Dictionary = {}      # Vector2i cell -> orientation

static func reflect(direction: Vector2i, orientation: String) -> Vector2i:
	"""Direction of a laser after hitting a mirror of the given orientation."""
	if orientation == MIRROR_BACKSLASH:
		return Vector2i(direction.y, direction.x)
	return Vector2i(-direction.y, -direction.x)

func set_mirror(grid_pos: Vector2i, orientation: String) -> void:
	mirror_cells[grid_pos] = orientation if orientation == MIRROR_BACKSLASH else MIRROR_SLASH

func has_mirror(grid_pos: Vector2i) -> bool:
	return mirror_cells.has(grid_pos)

func get_mirror(grid_pos: Vector2i) -> String:
	return mirror_cells.get(grid_pos, "")

func rotate_mirror(grid_pos: Vector2i) -> String:
	"""Turn a mirror by 90 degrees (a 45-degree mirror has two looks). Returns the new orientation, or "" if none."""
	if not mirror_cells.has(grid_pos):
		return ""
	mirror_cells[grid_pos] = MIRROR_SLASH if mirror_cells[grid_pos] == MIRROR_BACKSLASH else MIRROR_BACKSLASH
	return mirror_cells[grid_pos]

func clear_mirrors() -> void:
	mirror_cells.clear()

# --- Switches and doors ---------------------------------------------------------------------
# A switch is a pressure plate on a cell. A door is a barrier on the EDGE between two orthogonally
# adjacent cells: closed, nothing crosses it (hero, enemies, laser, sliding blocks); open, it is gone.
var switch_cells: Dictionary = {}   # Vector2i cell -> String id
var door_edges: Dictionary = {}     # Vector3i edge key -> {"id": String, "open": bool}

static func edge_key(a: Vector2i, b: Vector2i) -> Vector3i:
	"""Same key whichever side the edge is seen from; (-1,-1,-1) if the cells are not neighbours."""
	var d := b - a
	if d == Vector2i.RIGHT:
		return Vector3i(a.x, a.y, 0)
	if d == Vector2i.LEFT:
		return Vector3i(b.x, b.y, 0)
	if d == Vector2i.DOWN:
		return Vector3i(a.x, a.y, 1)
	if d == Vector2i.UP:
		return Vector3i(b.x, b.y, 1)
	return Vector3i(-1, -1, -1)

func set_switch(grid_pos: Vector2i, id: String) -> void:
	switch_cells[grid_pos] = id

func get_switch_id(grid_pos: Vector2i) -> String:
	return switch_cells.get(grid_pos, "")

func add_door(grid_pos: Vector2i, direction: Vector2i, id: String) -> bool:
	var other := grid_pos + direction
	if edge_key(grid_pos, other).z < 0 or not is_valid_grid_pos(grid_pos) or not is_valid_grid_pos(other):
		return false
	door_edges[edge_key(grid_pos, other)] = {"id": id, "open": false}
	return true

func edge_blocked(a: Vector2i, b: Vector2i) -> bool:
	"""True if a closed door sits on the edge between the two neighbouring cells."""
	if door_edges.is_empty():
		return false
	var door: Variant = door_edges.get(edge_key(a, b))
	return door != null and not door["open"]

func door_ids() -> Array:
	var ids: Array = []
	for door in door_edges.values():
		if not ids.has(door["id"]):
			ids.append(door["id"])
	return ids

func is_door_open(id: String) -> bool:
	var found := false
	for door in door_edges.values():
		if door["id"] == id:
			if not door["open"]:
				return false
			found = true
	return found

func set_door_open(id: String, open: bool) -> bool:
	"""Open or close every door with this id. Returns true if anything changed."""
	var changed := false
	for door in door_edges.values():
		if door["id"] == id and door["open"] != open:
			door["open"] = open
			changed = true
	return changed

func clear_doors_and_switches() -> void:
	door_edges.clear()
	switch_cells.clear()

# --- Hammers --------------------------------------------------------------------------------
# A hammer is a pivot cell plus a head on one of its four neighbours; both are solid like a wall.
# A block or statue reaching the SIDE of the head stops against it, the hammer swings three quarters of a
# turn and strikes it away in the direction the head pointed. Any other contact (top of the head, pivot)
# simply stops the slider, as a wall would.
var hammer_dirs: Dictionary = {}   # pivot cell -> head direction (Vector2i)

static func rotate_cw(direction: Vector2i) -> Vector2i:
	return Vector2i(-direction.y, direction.x)

static func rotate_ccw(direction: Vector2i) -> Vector2i:
	return Vector2i(direction.y, -direction.x)

static func hammer_deflection(head_dir: Vector2i, slide_dir: Vector2i) -> Dictionary:
	"""What a slider travelling in slide_dir does to a hammer whose head points to head_dir.
	Empty unless it reaches the side of the head. Otherwise: 'launch' is the direction it is struck in (where the head
	pointed), 'new_head' where the head ends up (on the side the slider came from) and 'quarter_turns' the swing
	(+3 clockwise, -3 counter-clockwise, the head always goes the long way round)."""
	if head_dir == Vector2i.ZERO or slide_dir == Vector2i.ZERO or head_dir.x * slide_dir.x + head_dir.y * slide_dir.y != 0:
		return {}
	var new_head := -slide_dir
	return {"launch": head_dir, "new_head": new_head, "quarter_turns": 3 if rotate_ccw(head_dir) == new_head else -3}

func set_hammer(pivot: Vector2i, head_dir: Vector2i) -> bool:
	if not [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].has(head_dir):
		return false
	# The head sweeps the whole 3x3 area around the pivot, so the pivot cannot touch the border.
	if pivot.x < 1 or pivot.x > Constants.GRID_COLS - 2 or pivot.y < 1 or pivot.y > Constants.GRID_ROWS - 2:
		return false
	hammer_dirs[pivot] = head_dir
	return true

func get_hammer_dir(pivot: Vector2i) -> Vector2i:
	return hammer_dirs.get(pivot, Vector2i.ZERO)

func has_hammer(cell: Vector2i) -> bool:
	"""True on a pivot, on the cell holding a head, and on both cells of a head that is mid-swing."""
	if hammer_dirs.is_empty():
		return false
	for key in hammer_dirs:
		var pivot: Vector2i = key
		if cell == pivot or cell == pivot + hammer_dirs[key]:
			return true
	for key in hammer_swing_cells:
		if hammer_swing_cells[key].has(cell):
			return true
	return false

var hammer_swing_cells: Dictionary = {}   # pivot -> [old head cell, new head cell] while the head is swinging

func turn_hammer(pivot: Vector2i, new_head: Vector2i) -> bool:
	"""Point the head to new_head at once (the rules never wait for the animation). Until finish_hammer_swing(), both the
	old and the new head cell stay solid so nothing walks into the sweeping head. False if there is no such hammer."""
	if not hammer_dirs.has(pivot) or not [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].has(new_head):
		return false
	hammer_swing_cells[pivot] = [pivot + hammer_dirs[pivot], pivot + new_head]
	hammer_dirs[pivot] = new_head
	return true

func hammer_pivot_for_head(cell: Vector2i) -> Vector2i:
	"""Pivot of the hammer whose head sits on 'cell' right now; (-1,-1) when no head is there (pivots do not count)."""
	for key in hammer_dirs:
		var pivot: Vector2i = key
		if cell == pivot + hammer_dirs[key]:
			return pivot
	return Vector2i(-1, -1)

func hammer_sweep_cells(pivot: Vector2i, head_dir: Vector2i, quarter_turns: int) -> Array[Vector2i]:
	"""Cells the head passes through (start excluded) when it turns quarter_turns (+ clockwise, - counter-clockwise)."""
	var cells: Array[Vector2i] = []
	var dir := head_dir
	for i in range(absi(quarter_turns)):
		dir = rotate_cw(dir) if quarter_turns > 0 else rotate_ccw(dir)
		cells.append(pivot + dir)
	return cells

func can_hammer_turn(pivot: Vector2i, quarter_turns: int) -> bool:
	"""A head cannot swing through a wall, a spawner, a mirror or another hammer, and not while it is already swinging."""
	if not hammer_dirs.has(pivot) or hammer_swing_cells.has(pivot):
		return false
	for cell in hammer_sweep_cells(pivot, hammer_dirs[pivot], quarter_turns):
		if not is_valid_grid_pos(cell) or spawner_cells.has(cell) or mirror_cells.has(cell) or push_block_cells.has(cell) or has_hammer(cell):
			return false
		var tile := get_tile(cell)
		if tile == Constants.TileType.WALL or tile == Constants.TileType.STONE_BLOCK or tile == Constants.TileType.EMPTY:
			return false
	return true

func finish_hammer_swing(pivot: Vector2i) -> void:
	hammer_swing_cells.erase(pivot)

func is_hammer_swinging(pivot: Vector2i) -> bool:
	return hammer_swing_cells.has(pivot)

func hammer_hit(cell: Vector2i, slide_dir: Vector2i) -> Dictionary:
	"""{'pivot', 'stop'} when a slider entering 'cell' in slide_dir hits the side of a hammer head ('stop' is the cell it
	rests on, beside the head); empty for anything else, which then behaves like a wall."""
	for key in hammer_dirs:
		var pivot: Vector2i = key
		var head_dir: Vector2i = hammer_dirs[key]
		if cell == pivot + head_dir and not hammer_deflection(head_dir, slide_dir).is_empty():
			return {"pivot": pivot, "stop": cell - slide_dir}
	return {}

func clear_hammers() -> void:
	hammer_dirs.clear()
	hammer_swing_cells.clear()

func set_push_block(grid_pos: Vector2i) -> void:
	push_block_cells[grid_pos] = true

func clear_push_block(grid_pos: Vector2i) -> void:
	push_block_cells.erase(grid_pos)

func has_push_block(grid_pos: Vector2i) -> bool:
	return push_block_cells.has(grid_pos)

func clear_push_blocks() -> void:
	push_block_cells.clear()

func set_conveyor_direction(grid_pos: Vector2i, direction: Vector2i) -> bool:
	if not is_valid_grid_pos(grid_pos):
		return false
	if direction != Vector2i.UP and direction != Vector2i.DOWN and direction != Vector2i.LEFT and direction != Vector2i.RIGHT:
		return false
	conveyor_directions[grid_pos] = direction
	return true

func get_conveyor_direction(grid_pos: Vector2i) -> Vector2i:
	return conveyor_directions.get(grid_pos, Vector2i.ZERO)

func clear_conveyor_directions():
	conveyor_directions.clear()

func set_one_way_direction(grid_pos: Vector2i, permitted_direction: Vector2i) -> bool:
	if not is_valid_grid_pos(grid_pos):
		return false
	if permitted_direction != Vector2i.UP and permitted_direction != Vector2i.DOWN and permitted_direction != Vector2i.LEFT and permitted_direction != Vector2i.RIGHT:
		return false
	one_way_directions[grid_pos] = permitted_direction
	return true

func get_one_way_direction(grid_pos: Vector2i) -> Vector2i:
	return one_way_directions.get(grid_pos, Vector2i.ZERO)

func can_enter_one_way(grid_pos: Vector2i, move_direction: Vector2i) -> bool:
	if get_tile(grid_pos) != Constants.TileType.ONE_WAY:
		return true
	return get_one_way_direction(grid_pos) == move_direction

func clear_one_way_directions():
	one_way_directions.clear()

func register_warp_endpoint(pair_id: String, grid_pos: Vector2i) -> bool:
	if pair_id.is_empty() or not is_valid_grid_pos(grid_pos):
		return false
	var endpoints: Array = warp_pairs.get(pair_id, [])
	if endpoints.has(grid_pos):
		return true
	if endpoints.size() >= 2:
		return false
	if warp_pair_by_position.has(grid_pos):
		return false
	endpoints.append(grid_pos)
	warp_pairs[pair_id] = endpoints
	warp_pair_by_position[grid_pos] = pair_id
	return true

func get_warp_destination(grid_pos: Vector2i) -> Vector2i:
	if not warp_pair_by_position.has(grid_pos):
		return Vector2i(-1, -1)
	var pair_id: String = warp_pair_by_position[grid_pos]
	var endpoints: Array = warp_pairs.get(pair_id, [])
	if endpoints.size() != 2:
		return Vector2i(-1, -1)
	return endpoints[1] if endpoints[0] == grid_pos else endpoints[0]

func clear_warp_pairs():
	warp_pairs.clear()
	warp_pair_by_position.clear()

func set_rotator_turn(grid_pos: Vector2i, quarter_turns: int):
	if is_valid_grid_pos(grid_pos) and (quarter_turns == 1 or quarter_turns == -1):
		rotator_turns[grid_pos] = quarter_turns

func get_rotator_turn(grid_pos: Vector2i) -> int:
	return int(rotator_turns.get(grid_pos, 0))

func set_spring_direction(grid_pos: Vector2i, direction: Vector2i):
	if is_valid_grid_pos(grid_pos) and (direction == Vector2i.UP or direction == Vector2i.DOWN or direction == Vector2i.LEFT or direction == Vector2i.RIGHT):
		spring_directions[grid_pos] = direction

func get_spring_direction(grid_pos: Vector2i) -> Vector2i:
	return spring_directions.get(grid_pos, Vector2i.ZERO)

func _ready():
	initialize_grid()

func initialize_grid():
	"""Initialize empty grid"""
	grid_data.clear()
	spring_directions.clear()
	rotator_turns.clear()
	clear_warp_pairs()
	clear_one_way_directions()
	clear_conveyor_directions()
	clear_push_blocks()
	clear_spawners()
	clear_mirrors()
	clear_doors_and_switches()
	clear_hammers()
	for y in range(Constants.GRID_ROWS):
		var row = []
		for x in range(Constants.GRID_COLS):
			row.append(Constants.TileType.EMPTY)
		grid_data.append(row)

## Convert world position to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var adjusted_x = world_pos.x - Constants.PLAYFIELD_OFFSET_X
	var adjusted_y = world_pos.y - Constants.PLAYFIELD_OFFSET_Y
	
	var grid_x = int(floor(adjusted_x / float(Constants.TILE_SIZE)))
	var grid_y = int(floor(adjusted_y / float(Constants.TILE_SIZE)))
	
	return Vector2i(grid_x, grid_y)

## Convert grid coordinates to world position (center of tile)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var world_x = Constants.PLAYFIELD_OFFSET_X + (grid_pos.x * Constants.TILE_SIZE) + (Constants.TILE_SIZE / 2)
	var world_y = Constants.PLAYFIELD_OFFSET_Y + (grid_pos.y * Constants.TILE_SIZE) + (Constants.TILE_SIZE / 2)
	
	return Vector2(world_x, world_y)

## Check if grid position is valid
func is_valid_grid_pos(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < Constants.GRID_COLS and \
		   grid_pos.y >= 0 and grid_pos.y < Constants.GRID_ROWS

## Check if grid position is walkable
func is_walkable(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_pos(grid_pos):
		return false
	
	if push_block_cells.has(grid_pos) or spawner_cells.has(grid_pos) or mirror_cells.has(grid_pos) or has_hammer(grid_pos):
		return false

	var tile = grid_data[grid_pos.y][grid_pos.x]
	# Water and solid obstacles are not traversable; ICE represents a walkable bridge.
	return tile != Constants.TileType.WALL and \
		   tile != Constants.TileType.EMPTY and \
		   tile != Constants.TileType.WATER and \
		   tile != Constants.TileType.HOLE and \
		   tile != Constants.TileType.STONE_BLOCK

## Enemies walk on everything the hero can, except the violet hero-only tiles
func is_enemy_walkable(grid_pos: Vector2i) -> bool:
	return is_walkable(grid_pos) and get_tile(grid_pos) != Constants.TileType.PLAYER_ONLY

## Get tile type at grid position
func get_tile(grid_pos: Vector2i) -> int:
	if not is_valid_grid_pos(grid_pos):
		return Constants.TileType.EMPTY
	return grid_data[grid_pos.y][grid_pos.x]

## Set tile type at grid position
func set_tile(grid_pos: Vector2i, tile_type: int):
	if is_valid_grid_pos(grid_pos):
		grid_data[grid_pos.y][grid_pos.x] = tile_type

## Snap world position to grid
func snap_to_grid(world_pos: Vector2) -> Vector2:
	var grid_pos = world_to_grid(world_pos)
	return grid_to_world(grid_pos)
