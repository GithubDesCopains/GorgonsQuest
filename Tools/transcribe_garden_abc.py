"""Create playable, deliberately modified Garden Land A-C maps from supplied screenshot silhouettes."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEVEL_DIR = ROOT / "Data" / "Levels"
WIDTH, HEIGHT = 16, 15


def render(ice_ranges, blocks=()):
    rows = []
    block_cells = set(blocks)
    for y in range(HEIGHT):
        chars = ["~"] * WIDTH
        for x in range(WIDTH):
            if (x, y) in block_cells:
                chars[x] = "b"
            elif x in ice_ranges.get(y, ()):
                chars[x] = "i"
        rows.append("".join(chars))
    return rows


def save(level, name, note, start, ice_ranges, blocks, urns, enemies, time_limit):
    doc = {
        "world": 1,
        "level": level,
        "name": name,
        "source_note": note,
        "time_limit": time_limit,
        "player_start": start,
        "grid": render(ice_ranges, blocks),
        "soul_urns": urns,
        "enemies": enemies,
    }
    for label, pos in [("player_start", start)] + [("soul_urn", p) for p in urns] + [("enemy", e["pos"]) for e in enemies]:
        x, y = pos
        if doc["grid"][y][x] != "i":
            raise ValueError(f"{name}: {label} {pos} must stand on walkable ice, got {doc['grid'][y][x]}")
    if any(len(row) != WIDTH for row in doc["grid"]):
        raise ValueError(f"{name}: malformed grid width")
    (LEVEL_DIR / f"world_1_level_{level}.json").write_text(json.dumps(doc, indent=2), encoding="utf-8")

save(1, "Garden Land A - Heartberg",
     "Original level layout modified for this project. Inspired by the heart-shaped iceberg silhouette in the user's screenshot; collectibles/enemies relocated and simplified.",
     [7, 12],
     {1: range(7,9), 2: range(6,10), 3: range(5,11), 4: range(3,13), 5: range(2,14), 6: range(2,14), 7: range(2,14), 8: range(3,13), 9: range(4,12), 10: range(5,11), 11: range(6,10), 12: range(7,9)},
     [(3,7),(12,7)],
     [[5,7],[7,8],[10,7],[7,11]],
     [
         {"type":"noggle","pos":[4,7],"pattern":["right","left"]},
         {"type":"noggle","pos":[11,7],"pattern":["left","right"]},
     ], 90)

save(2, "Garden Land B - Twin Reefs",
     "Original level layout modified for this project. Inspired by the broad island and paired side branches in the user's screenshot; routes and object placements simplified.",
     [7,12],
     {1: range(7,9), 2: range(6,10), 3: range(5,11), 4: range(4,12), 5: range(3,13), 6: range(3,13), 7: range(3,13), 8: range(3,13), 9: range(4,12), 10: range(5,11), 11: range(6,10), 12: range(7,9)},
     [(1,6),(2,6),(13,6),(14,6),(1,7),(14,7),(1,8),(14,8),(2,9),(13,9),(4,10),(11,10)],
     [[7,2],[5,5],[9,5],[6,9],[9,9]],
     [
         {"type":"noggle","pos":[3,6],"pattern":["down","down","up","up"]},
         {"type":"noggle","pos":[12,6],"pattern":["down","down","up","up"]},
         {"type":"birdie","pos":[4,9],"pattern":["right","up","left","down"]},
         {"type":"noggle","pos":[11,9],"pattern":["left","down","right","up"]},
     ], 105)

save(3, "Garden Land C - Frozen Blossom",
     "Original level layout modified for this project. Inspired by the stepped flower/pyramid island in the user's screenshot; block pattern and puzzle routes adjusted.",
     [7,12],
     {1: range(7,9), 2: range(6,10), 3: range(5,11), 4: range(4,12), 5: range(3,13), 6: range(2,14), 7: range(2,14), 8: range(2,14), 9: range(3,13), 10: range(5,11), 11: range(6,10), 12: range(7,9)},
     [(7,3),(8,3),(6,4),(9,4),(5,5),(10,5),(4,6),(11,6),(6,11),(9,11)],
     [[3,7],[5,6],[7,4],[8,4],[10,6],[12,7]],
     [
         {"type":"noggle","pos":[4,7],"pattern":["right","left"]},
         {"type":"birdie","pos":[11,7],"pattern":["left","right"]},
         {"type":"zapper","pos":[8,12],"pattern":["left","right"]},
     ], 120)

print("Wrote modified Garden Land levels 1-3 as valid 16x15 JSON maps.")
