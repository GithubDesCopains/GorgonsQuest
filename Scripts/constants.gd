extends Node

## Game Constants - Gorgon's Quest
## Grid-based puzzle game inspired by Kickle Cubicle

# Display & Resolution
const VIEWPORT_WIDTH = 1920
const VIEWPORT_HEIGHT = 1080

# Grid System (matching original NES layout)
const GRID_COLS = 16
const GRID_ROWS = 15
const TILE_SIZE = 72  # 72x72 pixels per tile

# Playfield dimensions
const PLAYFIELD_WIDTH = GRID_COLS * TILE_SIZE  # 1152px
const PLAYFIELD_HEIGHT = GRID_ROWS * TILE_SIZE  # 1080px
const PLAYFIELD_OFFSET_X = (VIEWPORT_WIDTH - PLAYFIELD_WIDTH) / 2  # 384px
const PLAYFIELD_OFFSET_Y = 0

# Movement
const MOVE_SPEED = 300.0  # Pixels per second for smooth movement
const MOVE_DURATION = 0.25  # Seconds to move one tile

# Tile Types
enum TileType {
	EMPTY = -1,
	GROUND = 0,
	WATER = 1,
	WALL = 2,
	ICE = 3,
	STONE_BLOCK = 4,
	SPRING = 5,
	ROTATOR = 6,
	WARP = 7,
	SLIPPERY = 8,
	ONE_WAY = 9,
	CONVEYOR = 10,
	HOLE = 11,         # Water hole: nobody walks on it, sliding blocks pass over it
	PLAYER_ONLY = 12,  # Violet tile: the hero may walk on it, enemies may not
}

# Directions
enum Direction {
	NONE = -1,
	RIGHT = 0,
	DOWN = 1,
	LEFT = 2,
	UP = 3
}

const DIR_VECTORS = {
	Direction.RIGHT: Vector2.RIGHT,
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.UP: Vector2.UP,
}

# Game Objects
enum ObjectType {
	PLAYER,
	ENEMY,
	SOUL_URN,  # Collectible (was Dream Bag)
	STONE_STATUE,  # Petrified enemy
	STONE_PILLAR,  # Created obstacle
	SPRING,        # Bouncer
	ROTATOR,       # 90-degree flipper
	WARP,          # Vortex teleport
}

# Layer ordering (z-index)
const LAYER_GROUND = 0
const LAYER_OBJECTS = 1
const LAYER_ENEMIES = 2
const LAYER_PLAYER = 3
const LAYER_EFFECTS = 4
const LAYER_UI = 5

# Colors (Pastel Mediterranean palette)
const COLOR_OCEAN_BLUE = Color("87CEEB")
const COLOR_SAND_BEIGE = Color("F5DEB3")
const COLOR_MARBLE_WHITE = Color("F8F8FF")
const COLOR_GOLD = Color("FFD700")
const COLOR_STONE_GRAY = Color("A9A9A9")
const COLOR_WALL = Color("EBA878")  # Pastel orange wall block
const COLOR_WATER = Color("8CC8E8")
const COLOR_GROUND = Color("F3E6C0")
