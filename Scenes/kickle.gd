extends CharacterBody2D

const TILE_SIZE = 16  # Taille d'une case NES
const WALK_SPEED = 100.0 # Vitesse de déplacement (plus c'est haut, plus il va vite)

var is_moving = false
var target_pos = Vector2.ZERO
var input_dir = Vector2.ZERO

@onready var ray = $RayCast2D # Pour détecter les murs/obstacles

func _ready():
	# On aligne Kickle sur la grille au départ
	position = position.snapped(Vector2.ONE * TILE_SIZE) + Vector2(TILE_SIZE/2, TILE_SIZE/2)
	target_pos = position

func _physics_process(_delta):
	if is_moving:
		move_towards_target()
	else:
		get_input()

func get_input():
	input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"): input_dir = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"): input_dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_up"): input_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"): input_dir = Vector2.DOWN

	if input_dir != Vector2.ZERO:
		check_and_move(input_dir)

func check_and_move(dir):
	# On configure le RayCast pour regarder la case suivante
	ray.target_position = dir * TILE_SIZE
	ray.force_raycast_update()

	# Si le RayCast ne touche rien (ou pas un mur), on avance
	if !ray.is_colliding():
		target_pos = position + (dir * TILE_SIZE)
		is_moving = true
	else:
		# Optionnel : Ici on pourra déclencher l'animation "pousse le mur"
		pass

func move_towards_target():
	# Déplacement fluide vers la cible
	position = position.move_toward(target_pos, WALK_SPEED)
	
	# Si on est arrivé à destination
	if position == target_pos:
		is_moving = false
