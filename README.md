# Gorgon's Quest
## A Greek Mythology Puzzle Game

### 🎮 Project Status: Phase 1 Complete

**Inspired by:** Kickle Cubicle (NES, 1988)  
**Art Style:** Wonder Boy: The Dragon's Trap (pastel, hand-drawn)  
**Theme:** Greek Mythology - Hero with Gorgon's Eye artifact

---

## ✅ Phase 1 - Architecture & Core Systems (COMPLETED)

### What's Been Built:

**1. Project Configuration**
- Resolution: 1920x1080 (16:9)
- Grid: 16x15 tiles @ 72x72px each
- Playfield: 1152x1080px centered
- Forward+ rendering for modern effects
- Pixel-perfect filtering disabled for crisp visuals

**2. Core Systems**
- ✅ **Constants** (autoload): Game-wide settings and enums
- ✅ **Grid Manager**: World ↔ Grid coordinate conversion
- ✅ **Game Manager**: Level state and event coordination
- ✅ **Player Controller**: Smooth grid-based movement
- ✅ **Placeholder Generator**: Procedural temp graphics

**3. Input System**
- Movement: Arrow Keys / WASD
- Petrify Shot: Space Bar
- Create Pillar: Shift Key

**4. Scene Structure**
```
Main Scene (Node2D)
├── GameManager
│   └── GridManager
├── Camera2D (centered 960, 540)
├── TileMapLayer (offset +384px for centering)
└── Player (CharacterBody2D)
    ├── Sprite2D
    ├── CollisionShape2D
    └── AnimationPlayer
```

### Files Structure:
```
kickle-cubicle/
├── Scripts/
│   ├── constants.gd              [Autoload - Game constants]
│   ├── game_manager.gd           [Game state coordinator]
│   ├── grid_manager.gd           [Grid/world conversions]
│   └── placeholder_generator.gd  [Temp visual assets]
├── Scenes/
│   ├── main.tscn                 [Main game scene]
│   ├── main_scene.gd             [Main scene logic]
│   ├── player.tscn               [Player prefab]
│   └── player.gd                 [Player controller]
├── Assets/                       [Original placeholder sprites]
├── DEV_NOTES.md                  [Full development doc]
└── project.godot                 [Project config]
```

---

## 🎯 Next: Phase 2 - Visual System

### Objectives:
1. **TileMap Rendering**
   - Create TileSet with placeholder tiles
   - Render ground, water, walls
   - Visual layering system

2. **Player Visuals**
   - Placeholder sprite with direction indicator
   - Simple walk animation (or state-based)
   - Movement feedback

3. **Interactive Objects**
   - Stone pillar visuals + collision
   - Soul urn collectibles
   - Debug grid overlay (optional)

### Before Starting Phase 2, I Need To Know:

**Visual Complexity:**
- Simple colored shapes (fast prototyping) ?
- More detailed placeholders with shading ?
- Just static sprites or basic 2-4 frame animations ?

**Debug Features:**
- Do you want grid lines visible for testing ?
- On-screen position/state display ?

**Testing Priority:**
- Focus on movement feel first ?
- Or get full visual feedback ASAP ?

---

## 🏛️ Design Direction

### Theme: Greek Mythology
- **Hero**: Young Greek warrior
- **Artifact**: Eye of Medusa (petrifying gaze)
- **Enemies**: Greek mythological creatures
- **Collectibles**: Golden Soul Urns
- **Worlds**: 
  1. Mount Olympus
  2. The Underworld
  3. Aegean Islands
  4. Minotaur's Labyrinth

### Color Palette (Mediterranean Pastels):
- Ocean Blue: `#87CEEB`
- Sand Beige: `#F5DEB3`
- Marble White: `#F8F8FF`
- Gold: `#FFD700`
- Stone Gray: `#A9A9A9`

### Gameplay (from Original):
- Collect all soul urns to complete level
- Petrify enemies → push statues → create bridges over water
- Create stone pillars to block/redirect
- 4 worlds × ~N levels + 30 special levels

---

## 📊 Technical Specs

| Aspect | Value |
|--------|-------|
| **Resolution** | 1920×1080 |
| **Grid** | 16×15 tiles |
| **Tile Size** | 72×72 pixels |
| **Playfield** | 1152×1080 px |
| **UI Margins** | 384px left/right |
| **Engine** | Godot 4.5 |
| **Renderer** | Forward+ |
| **Move Speed** | 300 px/sec |

---

## 🚀 Ready to Continue!

**Phase 1 is complete and functional.** The architecture is solid and ready for:
- Visual rendering
- Game mechanics
- Level loading
- Enemy AI
- And everything else!

**What would you like me to work on next?**
1. Phase 2 visuals (rendering system)
2. Phase 3 petrification mechanic
3. Something else specific?

Let me know your preference and any visual/gameplay details! 🎮

## 🛠️ Éditeur de niveaux

Un éditeur graphique séparé de la scène du jeu est disponible dans `Tools/level_editor.tscn`.
Ouvrez cette scène dans Godot et lancez-la avec **F6** (Exécuter la scène) pour éditer les fichiers JSON de `Data/Levels`.

Fonctions de l'éditeur :

- **Clic gauche** : place l'outil sélectionné (maintenir et glisser pour peindre). **Clic droit** : efface la case.
- **Ctrl+Z / Ctrl+Y** : annuler / rétablir. **Ctrl+S** : enregistrer.
- **Vérifier** : valide le format puis signale les problèmes de jeu (départ ou urne dans un mur, zapper hors de l'eau, éléments superposés, niveau sans urne, boss hors arène).
- **Tester le niveau** : lance le niveau édité dans le vrai jeu, puis revient à l'éditeur. La sauvegarde de campagne n'est pas modifiée.

Éléments de niveau disponibles :

- **Terrain** : sol, mur orange, eau, glace, pilier cassable (gris), trou d'eau (`o`), case violette réservée au héros (`v`).
- **Bloc poussable** (bleu foncé) : glisse jusqu'à un obstacle, coule dans l'eau et forme un pont.
- **Bonus glace** : +500 points. **Boule P** : transforme tous les ennemis vivants en statues.




- Cliquez une case pour peindre le terrain ou placer le départ, les urnes, les ennemis et les tuiles spéciales.
- Les niveaux existants se chargent avec **Ouvrir…**; **Nouveau** crée une grille vierge.
- **Enregistrer** met à jour le niveau chargé; **Enregistrer sous…** crée un nouveau fichier JSON.
- L’outil vérifie le document avec le même `LevelJsonLoader` que le jeu avant l’enregistrement.
- Les coordonnées sont `x,y`, à partir de zéro au coin supérieur gauche. `Effacer` retire les objets et remet le terrain de la case à du sol.

L’éditeur partage le format de niveaux du jeu. Les types de terrain sont `.` sol, `#` mur, `~` eau, `i` glace et `b` bloc; les autres objets sont représentés par des marqueurs dans la grille et leurs propriétés restent dans les champs JSON dédiés.
