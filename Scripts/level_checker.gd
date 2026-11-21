extends RefCounted

## Semantic checks for level documents (parsed JSON dictionaries).
## Structural errors are reported by LevelJsonLoader.validate_document(); this script only
## returns readable warnings about levels that load fine but are unlikely to play well.

const ENEMY_TYPES := ["noggle", "birdie", "zapper", "pusher", "wall_hugger", "jumper", "hades_shadow", "flame_beast"]
const WATER_ENEMIES := ["zapper", "pusher"]
const FLYING_ENEMIES := ["birdie"]
const BLOCKING_TILES := ["#", "~", "b", "o"]
const HERO_ONLY_TILE := "v"
const SPECIAL_LABELS := {
	"springs": "Le ressort",
	"rotators": "Le rotateur",
	"warps": "Le téléporteur",
	"one_way_gates": "La porte unidirectionnelle",
	"conveyors": "Le tapis roulant",
	"slippery_tiles": "Le sol glissant",
	"push_blocks": "Le bloc poussable",
	"bonus_items": "Le bonus",
	"mirrors": "Le miroir",
	"switches": "L'interrupteur"
}

static func check(doc: Dictionary) -> Array[String]:
	var warnings: Array[String] = []
	var grid: Array = doc.get("grid", [])
	if grid.size() != Constants.GRID_ROWS:
		warnings.append("La grille doit contenir %d lignes." % Constants.GRID_ROWS)
		return warnings

	var occupied: Dictionary = {}
	var start := _to_pos(doc.get("player_start", []))
	if _is_blocking(grid, start):
		warnings.append("Le départ du joueur %s est sur une case infranchissable." % _label(start))
	_occupy(occupied, start, "le départ du joueur")

	var urns: Array = doc.get("soul_urns", [])
	for urn in urns:
		var urn_pos := _to_pos(urn)
		if _is_blocking(grid, urn_pos):
			warnings.append("L'urne %s est sur une case infranchissable." % _label(urn_pos))
		_occupy(occupied, urn_pos, "une urne")
	if urns.is_empty() and not doc.has("boss"):
		warnings.append("Aucune urne : le niveau ne peut pas être terminé.")

	for key in ["enemies", "spawners"]:
		for entry in doc.get(key, []):
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var enemy_type := str(entry.get("type", "noggle"))
			var enemy_pos := _to_pos(entry)
			var kind := "L'ennemi" if key == "enemies" else "Le générateur"
			if key == "spawners":
				_occupy(occupied, enemy_pos, "un générateur (solide comme un mur)")
			if not ENEMY_TYPES.has(enemy_type):
				warnings.append("%s %s a un type inconnu : %s." % [kind, _label(enemy_pos), enemy_type])
				continue
			var tile := _tile_at(grid, enemy_pos)
			if WATER_ENEMIES.has(enemy_type):
				if tile != "~":
					warnings.append("%s %s (%s) doit être placé dans l'eau." % [kind, _label(enemy_pos), enemy_type])
			elif tile == "~" and FLYING_ENEMIES.has(enemy_type):
				continue
			elif _is_blocking(grid, enemy_pos):
				warnings.append("%s %s (%s) est sur une case infranchissable." % [kind, _label(enemy_pos), enemy_type])
			elif tile == HERO_ONLY_TILE:
				warnings.append("%s %s (%s) est sur une case violette réservée au héros." % [kind, _label(enemy_pos), enemy_type])

	for key in SPECIAL_LABELS:
		for entry in doc.get(key, []):
			var special_pos := _to_pos(entry)
			if _is_blocking(grid, special_pos):
				warnings.append("%s %s est sur une case infranchissable." % [SPECIAL_LABELS[key], _label(special_pos)])
			_occupy(occupied, special_pos, String(SPECIAL_LABELS[key]).to_lower())

	_check_hammers(doc, grid, occupied, warnings)

	for cell in occupied:
		if occupied[cell].size() > 1:
			warnings.append("Plusieurs éléments se superposent %s : %s." % [_label(cell), ", ".join(PackedStringArray(occupied[cell]))])

	# Doors sit on the edge between two cells and are paired with switches by id.
	var switch_ids: Dictionary = {}
	for entry in doc.get("switches", []):
		switch_ids[str(entry.get("id", ""))] = true
	var door_ids: Dictionary = {}
	for entry in doc.get("doors", []):
		door_ids[str(entry.get("id", ""))] = true
		var door_from := _to_pos(entry)
		var door_dir := str(entry.get("direction", "right")).to_lower()
		var door_to: Vector2i = door_from + {"right": Vector2i.RIGHT, "down": Vector2i.DOWN, "left": Vector2i.LEFT, "up": Vector2i.UP}.get(door_dir, Vector2i.ZERO)
		if _is_blocking(grid, door_from) and _is_blocking(grid, door_to):
			warnings.append("La porte %s ne sépare que des cases infranchissables." % _label(door_from))
	for id in door_ids:
		if not switch_ids.has(id):
			warnings.append("La porte « %s » n'a aucun interrupteur du même identifiant : elle restera fermée." % id)
	for id in switch_ids:
		if not door_ids.has(id):
			warnings.append("L'interrupteur « %s » n'ouvre aucune porte." % id)

	var boss = doc.get("boss", null)
	if typeof(boss) == TYPE_DICTIONARY:
		var boss_pos := _to_pos(boss)
		if _is_blocking(grid, boss_pos):
			warnings.append("Le boss %s est sur une case infranchissable." % _label(boss_pos))
		var arena := Rect2i(_to_pos(boss.get("arena_pos", [4, 3])), _to_pos(boss.get("arena_size", [9, 9])))
		if not arena.has_point(boss_pos):
			warnings.append("Le boss %s est en dehors de son arène." % _label(boss_pos))
		if not arena.has_point(start):
			warnings.append("Le départ du joueur %s est en dehors de l'arène du boss." % _label(start))

	if int(doc.get("time_limit", 90)) < 10:
		warnings.append("Le temps limite est très court (moins de 10 secondes).")
	return warnings

static func _check_hammers(doc: Dictionary, grid: Array, occupied: Dictionary, warnings: Array[String]) -> void:
	"""A hammer occupies its pivot and its head, and its head sweeps the whole 3x3 area around the pivot."""
	var dirs := {"right": Vector2i.RIGHT, "down": Vector2i.DOWN, "left": Vector2i.LEFT, "up": Vector2i.UP}
	var pivots: Array[Vector2i] = []
	for entry in doc.get("hammers", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pivot := _to_pos(entry)
		var head: Vector2i = pivot + dirs.get(str(entry.get("direction", "up")).to_lower(), Vector2i.UP)
		if _is_blocking(grid, pivot):
			warnings.append("Le pivot du marteau %s est sur une case infranchissable." % _label(pivot))
		_occupy(occupied, pivot, "le pivot du marteau")
		_occupy(occupied, head, "la tête du marteau")
		pivots.append(pivot)
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var cell := pivot + Vector2i(dx, dy)
				if (dx != 0 or dy != 0) and _tile_at(grid, cell) in ["#", "b"]:
					warnings.append("Le marteau %s est gêné par un mur en %s : sa tête ne pourra pas tourner." % [_label(pivot), _label(cell)])
	for index in range(pivots.size()):
		for other in range(index + 1, pivots.size()):
			if absi(pivots[index].x - pivots[other].x) <= 2 and absi(pivots[index].y - pivots[other].y) <= 2:
				warnings.append("Les marteaux %s et %s se chevauchent." % [_label(pivots[index]), _label(pivots[other])])

static func _to_pos(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_DICTIONARY:
		value = value.get("pos", [])
	if typeof(value) == TYPE_ARRAY and value.size() == 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i(-1, -1)

static func _tile_at(grid: Array, pos: Vector2i) -> String:
	if pos.y < 0 or pos.y >= grid.size():
		return ""
	var row := str(grid[pos.y])
	if pos.x < 0 or pos.x >= row.length():
		return ""
	return row.substr(pos.x, 1)

static func _is_blocking(grid: Array, pos: Vector2i) -> bool:
	var tile := _tile_at(grid, pos)
	return tile.is_empty() or BLOCKING_TILES.has(tile)

static func _occupy(occupied: Dictionary, pos: Vector2i, label: String) -> void:
	if not occupied.has(pos):
		occupied[pos] = []
	occupied[pos].append(label)

static func _label(pos: Vector2i) -> String:
	return "(%d, %d)" % [pos.x, pos.y]
