# Gorgon's Quest - Development Documentation

## Project Overview
A grid-based puzzle game inspired by Kickle Cubicle, reimagined with Greek mythology themes and modern visuals inspired by Wonder Boy: The Dragon's Trap.

## Technical Specifications

### Display
- **Resolution**: 1920x1080 (16:9)
- **Grid**: 16x15 tiles (matching NES original)
- **Tile Size**: 72x72 pixels
- **Playfield**: 1152x1080px (centered with 384px margins on sides)

### Theme
- **Setting**: Greek Mythology
- **Hero**: Young Greek hero wielding the "Eye of Medusa" artifact
- **Power**: Petrifying gaze that transforms enemies into stone statues
- **Collectibles**: Golden Soul Urns (replaces Dream Bags)
- **Worlds**: 4 mythological regions

### Art Style
- Pastel Mediterranean color palette
- Hand-drawn aesthetic (Wonder Boy inspired)
- Soft outlines and watercolor textures
- Warm tones: ochre, azure blue, off-white, gold

## Controls
- **Movement**: Arrow Keys / WASD
- **Petrify Shot**: Space
- **Create Pillar**: Shift

## Phase 1 - COMPLETED ✓

### Architecture
- ✅ Constants system (autoload)
- ✅ Grid Manager (coordinate conversion, tile management)
- ✅ Game Manager (game state, level coordination)
- ✅ Player Controller (grid-based movement with smooth interpolation)
- ✅ Placeholder generator for prototyping
- ✅ Project configuration (1920x1080, input mapping)
- ✅ Scene structure (Main, Player)

### Files Created
```
Scripts/
├── constants.gd           (Autoload - game constants)
├── game_manager.gd        (Main game coordinator)
├── grid_manager.gd        (Grid system)
└── placeholder_generator.gd (Temp visual assets)

Scenes/
├── main.tscn              (Main scene)
├── main_scene.gd          (Main scene script)
├── player.tscn            (Player scene)
└── player.gd              (Player controller)
```

### Features Implemented
- Grid-based movement system (16x15 grid)
- Smooth interpolation between tiles
- Direction tracking
- Input handling (movement, actions)
- Signal system for game events
- Test level generation

## Phase 2 - NEXT (Visual System & Rendering)

### Objectives
1. **TileMap System**
   - Create TileSet with placeholder tiles
   - Implement ground, water, wall rendering
   - Layer management (ground, objects, player, effects, UI)

2. **Visual Feedback**
   - Player sprite with placeholder graphics
   - Direction indicator
   - Movement animations (walk cycle)
   - Idle animations

3. **Basic Objects**
   - Stone pillars (visual + collision)
   - Soul urns (collectibles)
   - Visual grid overlay (debug mode)

### Questions for Phase 2
- Souhaitez-vous que je génère des sprites placeholder plus détaillés ?
- Préférez-vous des animations simples (2-4 frames) ou juste des états statiques pour le prototype ?
- Voulez-vous un mode debug avec affichage de la grille visible ?

## Phase 3 - Planned (Petrification Mechanic)

### Objectives
1. **Projectile System**
   - Petrifying ray/projectile
   - Collision detection with enemies
   - Visual effects (eye beam, stone transformation)

2. **Enemy Base**
   - Base enemy class
   - Simple AI (patrol patterns)
   - Petrification state
   - Stone statue object

3. **Block Physics**
   - Push stone statues
   - Floating on water
   - Collision with walls

## Phase 4 - Planned (Level System)

### Objectives
1. **Level Data Format**
   - JSON/Resource-based level definition
   - Tile layout
   - Enemy placement
   - Collectible positions

2. **Level Loader**
   - Parse level data
   - Instantiate objects
   - Win condition checking

3. **Original Levels**
   - Convert NES level data
   - World 1 levels (first land)

## Future Phases
- Phase 5: Enemy Types & AI
- Phase 6: Boss Battles
- Phase 7: UI/Menus
- Phase 8: Audio & VFX
- Phase 9: Progression System
- Phase 10: Polish & Balancing

## Notes
- Using placeholders until final art assets are created
- Architecture designed to be asset-agnostic
- Original Kickle Cubicle levels will be recreated exactly
- Modern art style to be applied once mechanics are solid
