# Kickle Cubicle - Complete Features Analysis
# Based on the NES/Arcade original game mechanics

## CORE GAMEPLAY MECHANICS

### 1. PLAYER ABILITIES
- **Freeze Breath**: Turn enemies into ice blocks
- **Ice Pillar Creation**: Create obstacles in front of player
- **Grid-based Movement**: Move one tile at a time (4 directions)
- **Push Ice Blocks**: Push frozen enemies
- **Die on Contact**: Touching unfrozen enemies = death

### 2. ICE BLOCK MECHANICS
- **Push on Ground**: Blocks slide one tile when pushed
- **Float on Water**: Blocks continue sliding until hitting obstacle
- **Create Bridges**: Blocks stop in water, making it walkable
- **Chain Sliding**: Multiple blocks can slide together
- **Stop on Obstacles**: Blocks stop when hitting walls/pillars

### 3. ENEMIES

#### Enemy Types:
1. **Noggles** (Red spheres)
   - Simple patrol patterns
   - Walk back and forth

2. **Bizys** (Jumping enemies)
   - Jump over obstacles
   - Can cross water

3. **Drops** (Water droplets)
   - Move in water only
   - Die when water freezes under them

4. **Mights** (Spring enemies)
   - Bounce in patterns
   - Can jump over ice pillars

5. **Whales** (Boss-like)
   - Spray water
   - Create obstacles

#### Enemy Behaviors:
- Patrol patterns (horizontal, vertical, circular)
- Some respawn after time
- Different speeds
- Some can't be frozen
- Death on contact with player

### 4. LEVEL OBJECTIVES
- **Primary Goal**: Collect all Dream Bags in level
- **Dream Bags**: Red collectibles scattered in level
- **Level Complete**: All bags collected → Exit appears
- **Lives System**: 3-5 lives, Game Over when depleted
- **Score System**: Points for enemies frozen, bags collected, time

### 5. TERRAIN TYPES
- **Ground**: Normal walkable tiles
- **Water**: Non-walkable, requires ice bridge
- **Walls**: Solid obstacles
- **Ice**: Slippery surface (in some levels)
- **Springs**: Bounce player/enemies
- **Warp Tiles**: Teleport to other location

### 6. SPECIAL TILES & OBJECTS
- **Red Dream Bags**: Main collectibles (3-8 per level)
- **Springs**: Launch player/blocks in direction
- **Warp Gates**: Teleport to matching gate
- **Crumbling Tiles**: Disappear after stepping on them
- **One-Way Paths**: Can only traverse in one direction

### 7. LEVEL PROGRESSION
- **4 Worlds (Lands)**: Each with unique theme
  1. Fantasy Land (Grass theme)
  2. Fruit Land (Fruit theme)
  3. Cake Land (Dessert theme)  
  4. Toy Land (Toy theme)

- **17 Levels per Land**: Progressive difficulty
- **Boss at End**: Special enemy at land end
- **Special Game**: 30 extra hard levels after completing all 4 lands

### 8. POWER-UPS / ITEMS
*Note: Kickle Cubicle has limited power-ups compared to other games*
- Time sometimes matters (bonus points)
- Extra lives at certain scores

### 9. PUZZLE ELEMENTS
- **Block Positioning**: Must place ice blocks strategically
- **Path Creation**: Build bridges to reach Dream Bags
- **Enemy Management**: Freeze enemies in right spots
- **Timing Puzzles**: Moving enemies create windows
- **Chain Reactions**: Push blocks into specific patterns

### 10. ADVANCED MECHANICS
- **Ice Block Sliding**: 
  - Push block → slides until obstacle
  - On water → stops and creates bridge
  - Multiple blocks → push line of blocks
  
- **Pillar Strategy**:
  - Block enemy paths
  - Stop sliding blocks
  - Create safe zones
  
- **Water Flooding**:
  - Some enemies spray water
  - Refills dried water tiles
  
- **Enemy Respawning**:
  - Some enemies regenerate
  - Creates continuous threat

### 11. LOSE CONDITIONS
- Touch unfrozen enemy → Lose life
- Fall in water (in some versions) → Lose life
- Run out of lives → Game Over
- Time limit (in some levels) → Lose life

### 12. SCORE SYSTEM
- Freeze enemy: 100-500 points
- Collect Dream Bag: 1000 points
- Complete level: Bonus based on time
- Chain freezing: Multiplier bonus
- High score tracking

### 13. UI ELEMENTS
- Lives remaining (top)
- Current score (top)
- Dream Bags remaining (counter)
- Current world/level (display)
- Timer (if applicable)
- High score

### 14. ANIMATIONS & FEEDBACK
- Enemy freeze animation (flash → ice)
- Block sliding motion
- Water splash when block enters
- Dream Bag collection sparkle
- Death animation
- Level complete fanfare

---

## MISSING FROM CURRENT PROTOTYPE

### High Priority:
- [ ] **Enemy Types**: Only basic patrol, need jumpers, water enemies
- [ ] **Ice Block Sliding**: Blocks should slide on water until obstacle
- [ ] **Death System**: Player dies on enemy contact
- [ ] **Lives & Game Over**
- [ ] **Level Complete Screen & Transition**
- [ ] **Multiple Dream Bag locations** (currently 5, originals have 3-8)
- [ ] **Springs & Warps**
- [ ] **Boss Enemies**

### Medium Priority:
- [ ] **Score System**
- [ ] **UI/HUD** (lives, score, bags counter)
- [ ] **Sound Effects & Music**
- [ ] **Better Animations**
- [ ] **Multiple Worlds/Themes**
- [ ] **Level Selection/Progression**

### Low Priority (Polish):
- [ ] **Title Screen & Menu**
- [ ] **Particle Effects**
- [ ] **Screen Transitions**
- [ ] **Save System**
- [ ] **Settings Menu**

---

## RECOMMENDED IMPLEMENTATION ORDER

1. **Ice Block Sliding** (Core mechanic)
2. **Death System** (Core gameplay)
3. **UI/HUD** (User feedback)
4. **More Enemy Types** (Variety)
5. **Level Complete Flow** (Progression)
6. **Additional Levels** (Content)
7. **Sound/Music** (Polish)
8. **Menus & UI** (Complete experience)

