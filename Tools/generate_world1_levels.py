"""Generate provisional Garden Land JSON maps from supplied low-resolution map reference.
Terrain masks approximate visible island silhouettes; gameplay object positions remain hand-authored.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Data" / "Levels"
W, H = 16, 15
# Each row lists inclusive walkable x-ranges. Empty rows remain ocean.
LEVELS = {
4: ("Garden D", [[], [4,11], [3,12], [3,12], [2,13], [2,13], [3,12], [3,12], [4,11], [5,10], [6,9], [7,8], []]),
5: ("Garden E", [[], [6,9], [5,10], [4,11], [4,11], [4,11], [0,5,10,15], [0,5,10,15], [0,5,10,15], [0,5,10,15], [0,5,10,15], [6,9], [7,8], []]),
6: ("Garden F", [[], [6,9], [5,10], [4,11], [3,12], [2,13], [2,13], [2,13], [2,13], [3,12], [4,11], [5,10], [6,9], []]),
7: ("Garden G", [[], [2,4,11,13], [2,4,10,13], [2,13], [2,13], [2,13], [2,13], [2,13], [2,13], [3,12], [3,12], [4,11], [5,10], []]),
8: ("Garden H", [[], [1,2,5,6,11,12,14], [1,2,5,6,11,12,14], [2,6,9,13], [3,12], [3,12], [3,12], [2,13], [1,14], [2,13], [3,12], [4,11], [5,10], []]),
9: ("Garden I", [[], [5,10], [4,11], [3,12], [2,13], [2,13], [2,13], [2,13], [2,13], [3,12], [4,11], [5,10], [6,9], []]),
10: ("Garden J", [[], [2,4,7,8,11,13], [2,4,7,8,11,13], [3,4,7,8,11,12], [4,11], [2,13], [2,13], [2,13], [3,12], [4,11], [5,10], [6,9], []]),
11: ("Garden K", [[], [5,10], [4,11], [2,13], [2,13], [2,13], [2,13], [2,13], [2,13], [3,12], [4,11], [5,10], [6,9], []]),
12: ("Garden L", [[], [7,8], [7,8], [7,8], [1,14], [1,14], [1,14], [1,14], [4,11], [5,10], [6,9], [7,8], []]),
13: ("Garden M", [[], [5,10], [4,11], [4,11], [3,12], [2,13], [2,13], [2,13], [2,13], [3,12], [4,11], [5,10], [6,9], []]),
14: ("Garden N", [[], [6,9], [4,11], [3,12], [2,13], [2,13], [3,12], [4,11], [2,13], [2,13], [3,12], [4,11], [1,6,9,14], [1,6,9,14], []]),
15: ("Garden O", [[], [6,9], [5,10], [4,11], [4,11], [4,11], [4,11], [4,11], [4,11], [4,11], [4,11], [5,10], [6,9], []]),
}

URN_LAYOUTS = {
4: [[6,3],[9,3],[7,10],[8,10]], 5: [[7,3],[8,3],[7,6]], 6: [[7,2],[8,2],[6,4],[9,4],[5,6],[10,6]],
7: [[2,8],[13,8],[5,10],[10,10]], 8: [[4,6],[11,6],[7,10],[8,10]], 9: [[5,4],[10,4],[7,8],[8,8]],
10:[[3,4],[7,4],[11,4],[6,9],[9,9]], 11:[[6,3],[9,3],[7,11],[8,11]], 12:[[7,3],[8,3],[4,7],[11,7]],
13:[[5,3],[10,3],[4,7],[11,7],[7,11],[8,11]],14:[[7,2],[8,2],[4,5],[11,5],[7,10],[8,10]],15:[[7,4],[8,4],[7,10],[8,10]]}


def intervals(row):
    if not row:
        return []
    if len(row) % 2:
        return [(row[0], row[-1])]
    return list(zip(row[::2], row[1::2]))


def make_level(level, spec):
    name, rows = spec
    terrain = []
    for y in range(H):
        chars = []
        for x in range(W):
            if x in (0, W-1) or y in (0, H-1):
                chars.append("#")
            elif any(a <= x <= b for a, b in intervals(rows[y-1] if 0 < y < H-1 else [])):
                chars.append(".")
            else:
                chars.append("~")
        terrain.append("".join(chars))
    urns = [p for p in URN_LAYOUTS[level] if terrain[p[1]][p[0]] == "."]
    walkable = [(x,y) for y in range(1,H-1) for x in range(1,W-1) if terrain[y][x] == "."]
    starts = [p for p in ([2, 13], [8, 13], [7, 13], [8, 12]) if terrain[p[1]][p[0]] == "."]
    player_start = starts[0] if starts else list(walkable[-1])
    occupied = {tuple(player_start), *(tuple(p) for p in urns)}
    enemy_cells = []
    for p in walkable:
        if p not in occupied and len(enemy_cells) < (2 + level // 4):
            enemy_cells.append(p)
            occupied.add(p)
    enemies = []
    patterns = [["right","right","left","left"],["down","down","up","up"],["right","down","left","up"]]
    for i, p in enumerate(enemy_cells):
        enemies.append({"type":"noggle" if i % 2 == 0 else "birdie", "pos":list(p), "pattern":patterns[i % len(patterns)]})
    return {
        "world":1, "level":level, "name":name, "time_limit":90,
        "player_start":player_start, "grid":terrain,
        "soul_urns":urns, "enemies":enemies,
        "source_note":"Provisional terrain transcription from supplied Garden Land reference image; verify tile/object coordinates against original game capture.",
    }

for number, spec in LEVELS.items():
    path = OUT / f"world_1_level_{number}.json"
    path.write_text(json.dumps(make_level(number, spec), indent=2), encoding="utf-8")
    print(path)
