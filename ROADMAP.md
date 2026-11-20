# 🏛️ ROADMAP - Gorgon's Debt (Clone Kickle Cubicle)

Ce document répertorie l'ensemble des tâches nécessaires pour réaliser un **clone complet et fidèle de Kickle Cubicle** avec le thème mythologique grec et la direction artistique moderne (façon *Wonder Boy: The Dragon's Trap*).

Les tâches sont ordonnées par priorité et dépendance technique afin d'être **implémentées l'une après l'autre**.

---

## 📌 Légende d'état
- [ ] ⏳ À faire
- [x] ✅ Terminé
- [🔄] En cours

---

## 🧱 PHASE 1 : Mécaniques Fondamentales & Gameplay Core

- [x] **TASK-1.1 : Écrasement d'ennemis par blocs glissants**
  - Lorsqu'un bloc de pierre glisse à grande vitesse, s'il percute un ennemi (pétrifié ou vivant), il doit l'écraser instantanément.
  - Déclenche un son d'écrasement, des particules de pierre et octroie +200 points.
  - Le bloc continue sa course s'il a encore de la distance, ou s'arrête selon les règles d'impact.

- [x] **TASK-1.2 : Destruction de statue pétrifiée par tir direct (Shatter)**
  - Tirer un rayon de pétrification sur une statue déjà pétrifiée doit la briser en morceaux de pierre.
  - Permet d'éviter de se coincer soi-même dans un passage étroit sans perdre de vie.

- [x] **TASK-1.3 : Destruction des piliers créés par un tir**
  - Tirer sur un pilier de pierre créé par le joueur (Shift) doit le détruire instantanément.
  - Permet de créer un arrêt temporaire pour un bloc puis de libérer le passage.

- [x] **TASK-1.4 : Nids d'ennemis / Générateurs (Spawn Holes)**
  - Implémentation des trous de réapparition d'ennemis fixes sur la carte.
  - Fait apparaître un nouvel ennemi à intervalle régulier (ex: toutes les 6 secondes) si l'ennemi précédent a été détruit.
  - Évite les situations de blocage définitif (*soft-lock*) où le joueur gaspille un bloc sans pouvoir créer de pont.

- [x] **TASK-1.5 : Recommencer rapidement le niveau (Quick Retry)**
  - Touche dédiée (ex: touche `R` ou action `restart_level`).
  - Déclenche la mort du joueur avec décompte d'une vie et redémarre le niveau sans passer par le Game Over.

- [x] **TASK-1.6 : Minuteur de niveau (Time Limit) & Pénalité**
  - Ajout d'un chronomètre visible dans le HUD (ex: 60 à 120s selon le niveau).
  - À 0s : déclenchement d'une pénalité (mort immédiate ou apparition d'un ennemi punitif invincible).
  - À la victoire : conversion du temps restant en points bonus.

---

## 🌀 PHASE 2 : Tuiles & Obstacles Spéciaux des Puzzles

- [x] **TASK-2.1 : Ressorts / Rebondisseurs (Springs)**
  - Tuile fixe avec direction (Haut, Bas, Gauche, Droite).
  - Renvoie le joueur ou tout bloc glissant en sens inverse ou vers la direction du ressort avec animation de compression.

- [x] **TASK-2.2 : Tourniquets / Pivots à 90° (Rotators / Flippers)**
  - Tuile qui dévie les blocs glissants à angle droit (ex: bloc allant vers la droite dévié vers le bas).
  - Essentiel pour contourner les murs dans les niveaux avancés.

- [x] **TASK-2.3 : Trous de ver / Téléporteurs (Warp Holes)**
  - Paires de tuiles vortex liées par identifiant (A1 ↔ A2, B1 ↔ B2).
  - Téléporte le joueur ou le bloc glissant à l'autre extrémité de la paire en conservant la direction.

- [x] **TASK-2.4 : Sol glissant (Marbre poli / Glace)**
  - Type de tuile `SLIPPERY_TILE`.
  - Quand le joueur marche dessus, il glisse en ligne droite sans pouvoir changer de direction jusqu'à atteindre un sol normal ou un obstacle.

- [x] **TASK-2.5 : Portes / Barrières à sens unique (One-Way Gates)**
  - Tuile franchissable uniquement dans une direction spécifique (indiquée par une flèche gravée dans la pierre).

- [x] **TASK-2.6 : Tapis roulants antiques (Conveyor Belts)**
  - Bandes automatiques qui déplacent automatiquement le joueur et redirigent les blocs glissants dans une direction donnée.

---

## 👾 PHASE 3 : Bestiaire Mythologique Complété

- [x] **TASK-3.1 : Ennemi raseur de murs (Max / Sparky)**
  - Ennemi qui longe strictement les bords de murs et le contour de la pièce à grande vitesse.
  - Thème : *Scarabée antique / Automate d'Héphaïstos*.
  - Implémentation : Automate d'Héphaïstos rapide, suit les bordures praticables avec règle main-droite; ajouté au niveau 1.

- [x] **TASK-3.2 : Ennemi sauteur / écrasant (Thumper / Puffer)**
  - Saute périodiquement jusqu'à 2 cases pour tenter d'écraser le joueur à l'atterrissage.
  - Peut être pétrifié pendant le saut; l'atterrissage sur le joueur consomme une vie.
  - Thème : *Minotaure bondissant*.

- [x] **TASK-3.3 : Ennemi voleur de ponts / aquatique agressif (Pusher)**
  - Nage dans l'eau vers pont proche et dissout un pont non occupé après une courte attaque; ne détruit jamais pont sous le joueur.
  - Thème : *Créature marine de Poséidon*.

- [x] **TASK-3.4 : Ombre fantomatique d'Hadès (Boo-like)**
  - N'avance vers le joueur que lorsque celui-ci lui tourne le dos.
  - Se fige automatiquement dès que le joueur la regarde en face sur même rangée/colonne.
  - Thème : *Ombre des Enfers*; ajoutée au niveau 1.

- [x] **TASK-3.5 : Créature de braise ignée (Fire Monster)**
  - Ennemi de feu immunisé au regard pétrifiant.
  - Fait fondre les statues de pierre adjacentes au sol; ne détruit ni ennemis vivants ni statues éloignées.
  - Thème : *Élémentaire de lave du Tartare*; ajouté au niveau 1.

---

## 👑 PHASE 4 : Combats de Boss de Fin de Monde

- [x] **TASK-4.1 : Système & Arène de Boss**
  - Architecture commune : boss à PV, insensible au regard, arène fermée jusqu’à victoire, sortie déverrouillée ensuite.
  - Le boss invoque des sbires dans l’arène; un sbire pétrifié qui le percute en glissant inflige un PV.
  - Fixture d’intégration d’arène disponible en Monde 1, niveaux 16–17; boss spécifique et patterns par tâche suivante.

- [x] **TASK-4.2 : Boss Monde 1 - Le Cyclope Polyphème**
  - Patterns alternés et télégraphiés : frappe du pied sur position joueur, lancer de rocher sur case anticipée.
  - 3 PV; arène d’essai accessible aux niveaux 16–17 du Monde 1.
  - Boss instancié via `CyclopsBoss`; rocher parabolique et avertissement visuel par case.

- [x] **TASK-4.3 : Boss Monde 2 - L'Hydre de Lerne**
  - Patterns alternés télégraphiés : crachat acide ciblant case anticipée, balayage horizontal/vertical de l’arène.
  - 4 PV; arène d’essai en Monde 2 niveau 17 avec sbires aquatiques Zapper.

- [x] **TASK-4.4 : Boss Monde 3 - La Chimère**
  - Attaques télégraphiées alternées : souffle de flammes en ligne et charge rapide dans une voie de l’arène.
  - 5 PV; fixture boss accessible en Monde 3 niveau 17 avec sbires élémentaires de feu.

- [x] **TASK-4.5 : Boss Monde 4 - Méduse la Gorgone Originelle**
  - Patterns télégraphiés : regard sur héros, téléportation derrière lui, invocation de serpents au sol.
  - 6 PV; phase deux à mi-vie, avec attaques plus rapides et zone de serpents élargie.
  - Arène finale accessible en Monde 4, niveau 17.

---

## 🗺️ PHASE 5 : Structure des Mondes, Niveaux & Sauvegarde

- [x] **TASK-5.1 : Format de fichier et chargeur de niveaux JSON / Resources**
  - Schéma JSON, validation, conversion `LevelData` et fallback legacy implémentés; tuiles spéciales et boss pris en charge.
  - `res://Data/Levels/world_1_level_1.json` sert de niveau source; les autres niveaux migreront avec TASK-5.2 à TASK-5.6.

- [x] **TASK-5.2 : Reproduction des 17 niveaux du Monde 1 (Jardins / Îles)**
  - 15 niveaux de puzzle (Garden Land A à O) transcrits au format JSON dans `Data/Levels/world_1_level_1.json` à `world_1_level_15.json` avec difficulté croissante.
  - Niveaux 16 et 17 configurés pour l'arène du Cyclope Polyphème.
  - Tous les niveaux validés via tests automatisés et test d'intégration.

### ⏸️ Niveaux mis en attente (contenu pur, reporté après le socle gameplay/systèmes) :
- [⏸️] **TASK-5.3 : Reproduction des 17 niveaux du Monde 2 (Enfers d'Hadès)** *(reporté)*
- [⏸️] **TASK-5.4 : Reproduction des 17 niveaux du Monde 3 (Mont Olympe)** *(reporté)*
- [⏸️] **TASK-5.5 : Reproduction des 17 niveaux du Monde 4 (Labyrinthe du Minotaure)** *(reporté)*
- [⏸️] **TASK-5.6 : Mode "Special Game" (30 niveaux expert)** *(reporté)*

### 🚀 Reprise du développement cœur :
- [x] **TASK-5.7 : Système de sauvegarde persistante (Save System)**
  - `Scripts/save_manager.gd` : lecture/écriture `user://savegame.json`.
  - Données : monde/niveau débloqués par monde, meilleur score par niveau, score total, volumes BGM/SFX.
  - Reset silencieux si fichier absent ou corrompu (version mismatch).
  - Intégré dans `GameManager` : sauvegarde automatique à chaque victoire de niveau.
- [x] **TASK-5.8 : Éditeur de niveaux (`Tools/level_editor.tscn`)**
  - Peinture au glissement (clic gauche), effacement (clic droit), annuler/rétablir (Ctrl+Z / Ctrl+Y, 100 niveaux d'historique), Ctrl+S pour enregistrer.
  - Bouton « Vérifier » : validation structurelle (`LevelJsonLoader`) puis alertes sémantiques (`Scripts/level_checker.gd`) : départ/urne/ennemi sur case infranchissable, zapper/pusher hors de l'eau, éléments superposés, niveau sans urne, boss ou joueur hors arène.
  - Bouton « Tester le niveau » : joue le niveau édité dans le vrai jeu via `GameSession.custom_level_path`; retour automatique à l'éditeur (victoire, pause > carte du monde) avec le document restauré.
  - Un niveau de test ne modifie jamais la sauvegarde de campagne.
  - Tests : alertes du vérificateur, annuler/rétablir/effacer/plafond d'historique, routage de session de test.
  - Validation : 50/50 tests; lancement du jeu et de l'éditeur sans erreur de script.
  - Reste à faire : outil de remplissage et sélection rectangulaire.
- [x] **TASK-5.9 : Éléments de niveau du jeu de référence**
  - Murs orange : `#` reste un mur simple, désormais orange. Pilier cassable : `b`, gris, détruit par un tir.
  - Trou d'eau (`o`) : personne ne marche dessus. Un bloc qui glisse passe par-dessus et ne s'y arrête jamais (il recule d'une case si besoin).
  - Case violette (`v`) : le héros marche dessus, pas les ennemis (`GridManager.is_enemy_walkable`). Les oiseaux la refusent aussi.
  - Bloc poussable bleu foncé (`push_blocks`, `Scenes/push_block.gd`) : glisse comme une statue, s'arrête contre un obstacle, coule dans l'eau et laisse un pont.
  - Bonus (`bonus_items`, `Scenes/bonus_item.gd`) : glace d'ambroisie (+500 points) et boule P violette (pétrifie tous les ennemis vivants, +300 points; le Flame Beast résiste).
  - Format JSON, éditeur (outils, légende K/G/O, vérificateur) et rendu mis à jour.
  - Tests : trous et cases violettes, glisse et noyade du bloc, bonus et boule P, aller-retour JSON.
  - Validation : 54/54 tests; démarrage du jeu et de l'éditeur sans erreur de script.
  - Reste à faire : les 15 niveaux du Monde 1 n'utilisent pas encore ces éléments. Les placer niveau par niveau avec l'éditeur.





---

## 🧭 PHASE 6 : Overworld & Navigation (Carte du Monde)

- [x] **TASK-6.1 : Écran de la Carte du Monde (Overworld Map)**
  - `Scenes/overworld_map.gd` : carte insulaire dessinée via `_draw()`.
  - Chemin de 16 cases (15 niveaux + 1 boss Cyclope) sur fond d'archipel.
  - Navigation clavier (flèches), sélection avec Entrée.
  - Cases colorées : vert=complété, beige=ouvert, violet=verrouillé, rouge=boss.

- [x] **TASK-6.2 : Déblocage progressif & transition animée**
  - `Scenes/scene_transition.gd` : fondu noir entre overworld et niveau de puzzle.
  - `unlock_next_level()` sur l'overworld : déplace le curseur et redessine.
  - `GameManager._on_victory_continue()` notifie l'overworld après chaque victoire.
  - Progression persistée dans `SaveManager`.

---

## 📋 PHASE 7 : Menus, UI/UX & Contrôles

- [x] **TASK-7.1 : Écran Titre complet**
  - `Scenes/title_screen.gd` + `title_screen.tscn` : fond nuit animé, étoiles, colonnes corinthiennes, vagues.
  - Titre animé, boutons Nouvelle Partie / Continuer / Options / Quitter, navigation clavier.
  - Déclaré comme scène de démarrage dans `project.godot`.

- [x] **TASK-7.2 : Menu Pause en jeu (In-Game Pause)**
  - `Scenes/pause_menu.gd` + `pause_menu.tscn` : overlay Control semi-transparent, touche Échap et navigation clavier.
  - Options Reprendre / Recommencer / Options / Carte du monde; pause réelle via `SceneTree.paused`.
  - Intégré dans `main_scene.gd` avec callbacks de restart et retour overworld.

- [x] **Correctif stabilité sauvegarde/tests (lié à TASK-5.7)**
  - `SaveManager` parse JSON avec `JSON.parse`, tolère données corrompues et valide/clamp les valeurs persistées.
  - Chemin de sauvegarde injectable; tests isolés sur fichiers `user://test_save_*.json`, sans écraser sauvegarde réelle.
  - Menu pause et test s'exécutent dans l'arbre Godot; test libère ses nœuds UI.

- [x] **TASK-7.3 : Menu Options & Paramètres**
  - `Scenes/options_menu.gd` + `.tscn` : panneau audio, affichage et référence commandes, accessible depuis titre et pause.
  - Sliders Musique/SFX persistants via SaveManager; bus `Music` et `SFX` séparés, application des valeurs sauvegardées au chargement.
  - Boutons plein écran/fenêtré et VSync appliqués via `DisplayServer`.
  - Aide commandes clavier/manette affichée dans l'interface.
  - Test de non-régression : persistance/lecture sliders, bus distincts, mute à zéro, contrôles affichage et création de l'UI.

- [x] **TASK-7.4 : Support des manettes (Gamepad / XInput)**
  - `Scripts/controller_input.gd` ajoute axes stick gauche et D-pad aux actions clavier existantes (configuration idempotente).
  - A / X : tir pétrifiant; B / Y : création de pilier; A accepte et B/Start ouvre/annule menus.
  - `Scripts/controller_feedback.gd` : vibration légère à tir et plus forte à poussée; no-op sûr sans périphérique.
  - Configuré à l’entrée du jeu, titre et overworld; options affichent rappel des contrôles.
  - Test de non-régression vérifie bindings, axes, idempotence et API vibration sans manette connectée.

- [x] **TASK-7.5 : Écran de score récapitulatif détaillé (Level Clear Screen)**
  - Écran victoire affiche score de niveau, points gagnés, urnes, ennemis écrasés, bonus de fin et bonus temps.
  - Décompte animé du score cumulé; affiche record personnel ou nouveau record.
  - Score du niveau distinct du score global : score de départ mémorisé à chaque chargement; record par niveau mis à jour avec points gagnés durant ce niveau.
  - Protection contre double déclenchement de fin; temps négatif donne bonus nul.
  - Tests couvrent formule des scores, arrondi/borne du chrono, breakdown UI et annonce du record.

---

## 🎨 PHASE 8 : Direction Artistique "Wonder Boy Switch" (Visuels HD)

- [x] **TASK-8.1 : Habillage des marges d'écran (Border Overlays)**
  - `Scenes/level_border_art.gd` dessine deux marges de 384x1080 avec panneaux marins, colonnes cannelées, chapiteaux, méandres grecs et médaillons de laurier/œil.
  - Motifs géométriques originaux générés en code; aucun sprite tiers ou asset protégé.
  - Instancié par `main_scene.gd`, sous HUD et sans chevauchement avec plateau x=384..1535.
  - Test vérifie exactement les rectangles de marge, le script décor et chargement du contrôleur de scène.
  - Validation Godot headless : 38/38 tests réussis, lancement sans erreur de script.

- [x] **TASK-8.2 : Héros grec original & animations procédurales**
  - `Scenes/hero_visual.gd` : personnage original dessiné par primitives Godot, sans sprites externes.
  - Tunique turquoise, sandales, peau/cheveux, couronne de laurier et artefact-tête de Gorgone tenu à la main.
  - Orientation haut/bas/gauche/droite, pas animé avec bob/stride, pose de poussée, lueur de tir, célébration, silhouette de marbre fissurée à la mort.
  - Intégré à `player.gd`; remplace placeholder bleu; sprite teinté restauré au blanc pour respecter palette.
  - Tests couvrent quatre directions, pose mouvement/poussée, tir, victoire, mort et palette du héros.
  - Validation : 39/39 tests; lancement headless sans erreur de script.

- [x] **TASK-8.3 : Bestiaire illustré & transformation commune**
  - `Scenes/enemy_visual.gd` dessine des silhouettes originales différenciées : Noggle, Birdie, Zapper/Pusher, scarabée, Minotaure, Ombre d'Hadès et élémentaire de feu.
  - Animation procédurale pour battement d'ailes, nage, marche, flammes et flottement; IA/type existants conservés.
  - `Scenes/petrification_visual.gd` fournit une transformation unique en statue grecque de marbre fissuré, quel que soit le type pétrifiable.
  - `Enemy.petrify()` masque la couche vivante après transition; yeux désactivés; les visuels `ColorRect` restent présents comme compatibilité avec sous-classes/effets hérités.
  - Flame Beast reste immunisé : ne déclenche pas le rendu statue.
  - Tests couvrent palettes/types, animation vivante, transformation partagée de plusieurs sous-classes et immunité.
  - Remarque : rendus sont des primitives vectorielles animées, pas des spritesheets frame-by-frame dessinés à la main.

- [x] **TASK-8.4 : Tileset procédural (Herbe, Eau, Glace, Marbre)**
  - `Scenes/tile_art_layer.gd` ajoute vagues/reflets animés à l'eau, veines aux dalles, givrage au sol glissant, joints et fissures au marbre/blocs.
  - Couche visuelle reste limitée au plateau de 16x15; logique de grille, collisions et types de tuiles inchangés.
  - Ponts et bordures boss gardent leur ordre d'affichage; décor nettoyé avec les visuels de niveau.
  - Test couvre chaque type de tuile, bounds exacts du plateau et activation/arrêt animation de l'eau.
  - Validation : 42/42 tests; lancement headless sans erreur de script.
  - Note : motifs dessinés en code comme art provisoire original; assets HD dessinés à la main restent une tâche d'art/polish future.

- [x] **TASK-8.5 : Effets visuels procéduraux**
  - `Scenes/game_vfx.gd` fournit effets temporaires dessinés en code : rayon divin vert/or, impacts, aura de pétrification, éclats de marbre, splash et ondes de pont.
  - Relié au tir du héros, collisions projectile/ennemis/boss/murs, pétrification, bris/écrasement et insertion d'une statue dans l'eau.
  - Effets auto-libérés; durées et spawn parent défensivement validés; gameplay/collisions inchangés.
  - Test couvre types/durées, direction, spawn et parent invalide.
  - Validation : 43/43 tests; lancement headless sans erreur de script.
  - Note : VFX produits par primitives 2D, pas shaders GPU ni sprites de particules HD dessinés.

---

## 🎵 PHASE 9 : Audio & Musiques Complètes

- [x] **TASK-9.1 : Musiques d'ambiance procédurales par monde (BGM)**
  - `SoundManager` génère 4 boucles originales en PCM : motifs mélodiques, basses pulsées et timbres différents par biome.
  - Profils distincts îles grecques / Enfers / Olympe / Labyrinthe (tempo, gamme, racine et waveform).
  - `GameManager` sélectionne thème par monde au chargement; changement de niveau dans même monde ne redémarre pas piste.
  - Lecture sur bus Music existant, compatible slider et sauvegarde de volume TASK-7.3.
  - Test vérifie données WAV non vides, fréquence, boucle et distinction des quatre thèmes.
  - Validation : 44/44 tests; démarrage headless sans erreur de script.
  - Note : musique générée par synthèse simple, pas enregistrement d'instruments acoustiques.

- [x] **TASK-9.2 : Musiques d'événements & Boss**
  - `SoundManager.generate_sfx()` synthétise en 16 bits (tons + bruit filtré mixés dans un tampon flottant), déterministe et mis en cache.
  - Thème de boss en boucle (148 BPM, riff phrygien, basse, grosse caisse, caisse claire) : `play_boss_music()` au spawn du boss, `end_boss_music()` rend le thème du monde à sa défaite.
  - Fanfare de fin de niveau; fanfare longue pour la victoire finale (monde 4, niveau 17); jingle de Game Over en ligne mineure descendante.
  - Remarque : la musique reste coupée par `MUSIC_ENABLED := false` (décision antérieure, trop forte); le thème de boss en dépend aussi. Les fanfares et jingles sont des SFX et restent audibles.

- [x] **TASK-9.3 : Bruitages haute fidélité (SFX)**
  - Écrasement de bloc : coup sourd grave, craquement de pierre et grondement.
  - Bris de statue : tintements de marbre sur gravats; plouf : corps d'eau, embruns et bulles; regard pétrifiant : souffle montant avec bourdonnement scintillant.
  - Test : sons non vides, 16 bits, distincts, déterministes; seul le thème de boss boucle; fanfare finale plus longue; nom inconnu retourne null.
  - Validation : 73/73 tests; démarrage du jeu et de l'éditeur sans erreur de script.
  - Note : sons de synthèse, pas des enregistrements.

---

## 🪞 PHASE 10 : Puzzles à Lumière & Mécanismes (ajout hors plan initial)

- [x] **TASK-10.1 : Miroirs, interrupteurs et portes**
  - **Miroirs** (`Scenes/mirror_tile.gd`, `mirrors` en JSON, `orientation` `slash` ou `backslash`) : solides comme un mur, plient le rayon de 90° au centre de la case (`MAX_BOUNCES` coupe les boucles). Le héros tourne le miroir en face de lui avec E / épaule gauche (`rotate_mirror`). Un rayon renvoyé peut tuer le héros.
  - **Interrupteurs** (`switch_tile.gd`, `switches`) : plaque tenue par un bloc poussable ou une statue pétrifiée (20 s, renouvelée par un nouveau tir).
  - **Portes** (`door_tile.gd`, `doors`) : barrière sur l'arête entre deux cases, liée aux interrupteurs de même `id`; ouverte seulement quand TOUS les interrupteurs de cet id sont tenus. Bloque héros, ennemis, statues, blocs et rayon.
  - Format JSON, chargeur (validation), éditeur (outils Miroir/Interrupteur/Porte, rendu des arêtes) et vérificateur (porte sans interrupteur, interrupteur sans porte, porte entre deux murs) mis à jour.
  - Commande `break_statue` (Q / épaule droite) ajoutée.
  - Aide des commandes (Options) : ajout de « Tourner le miroir en face ».
  - Correctif : le test d'éditeur ne lève plus d'erreur `popup_centered` hors arbre.
  - Validation : 73/73 tests; démarrage du jeu et de l'éditeur sans erreur de script.
  - Reste à faire : aucun des 15 niveaux du Monde 1 n'utilise ces éléments; les placer avec l'éditeur.

---

## 🛡️ Durcissement & refactorisation

- [x] **Données non fiables** : `LevelJsonLoader.validate_value_types()` rejette les types erronés (intervalle, motif, durée, identifiants, boss) et borne durée (3600 s), intervalle de génération (0,5 s min), vie du boss (99), nom (100 car.) et taille de fichier (256 Ko). `SaveManager` ramène les valeurs non numériques aux défauts et plafonne les scores. Test : `test_untrusted_level_and_save_data_never_crash`.
- [x] **Licence** : le pack Craftpix (`Assets/Pix/`) n'est plus versionné (sources non redistribuables); il reste en local, hors du jeu.
- [x] **Refactorisation** (sans changement de comportement) :
  - `Scripts/scene_lookup.gd` (`SceneLookup.main_scene`, `effect_parent`) remplace 25 recherches répétées du nœud `Main`; renvoie `null` hors de l'arbre au lieu de planter.
  - `_play_sound()` remplace 17 blocs `if sound_manager and has_method(...)` (`GameManager`, `Player`, `Enemy`).
  - `GameManager.clear_level()` : une boucle sur 15 listes remplace 15 boucles copiées (-65 lignes).
  - `Player.SLIDABLE_TILES` / `PLAIN_FLOOR_TILES` remplacent deux conditions de 9 et 4 `or`.
  - Éditeur : liste d'ennemis partagée avec le vérificateur, et lecture de fichier non dupliquée.
  - Validation : 74/74 tests, 4 runners d'intégration, démarrage du jeu et de l'éditeur sans erreur.

