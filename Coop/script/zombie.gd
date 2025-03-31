extends CharacterBody2D
@onready var animated_sprite_2d =$AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var raycast = $RayCast2D


@export var patrol_point : Node
@export var player : CharacterBody2D

var number_of_Points : int
var health = 3
var is_dead = false
const SPEED = 20000
const Chase_SPEED= 20200
const GRAVITY = 1000

# Variables d'ennemi
enum State { Idle , Walk , Chase }
var direction = Vector2.LEFT
var current_state : State
var point_positions : Array[Vector2] = []  # Assurez-vous que ce tableau est initialisé
var current_point_position : int = 0
var current_point : Vector2

# Fonction pour configurer les patrouilles
func _ready():
	if is_dead:
		return
		
	add_to_group("enemies")
	if patrol_point != null:
		# Vérification si le nœud de patrouille contient des enfants
		number_of_Points = patrol_point.get_children().size()
		if number_of_Points > 0:
			# Ajouter les positions des enfants (points de patrouille) dans le tableau
			for point in patrol_point.get_children():
				point_positions.append(point.global_position)
			current_point = point_positions[current_point_position]
		else:
			print("Pas de points de patrouille définis dans le nœud patrol_point")
	else:
		print("Le nœud 'patrol_point' n'est pas assigné")
		
	current_state = State.Idle

# Fonction pour faire patrouiller l'ennemi
func _process(delta):
	# Vérifier que les points de patrouille existent avant d'essayer de les utiliser
	if point_positions.size() > 0:
		enemy_idle(delta)
		enemy_run(delta)
		enemy_fall(delta)
		
		move_and_slide()
		animated_enemy(delta)
		
func  look_for_player():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == State.Chase:
			pass
			
func chase_player():
	current_state = State.Chase
	


	
func enemy_run(delta : float):
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = direction.x * SPEED * delta
		current_state = State.Walk
	else :
		current_point_position += 1
		
		# Vérification de la taille du tableau avant de tenter d'y accéder
		if current_point_position >= point_positions.size():
			current_point_position = 0  # Réinitialiser à 0 (recommencer depuis le premier point)
		
		current_point = point_positions[current_point_position]
	
	# Déterminer la direction selon la position du point de patrouille
	if current_point.x > position.x : 
		direction = Vector2.RIGHT
		raycast.target_position = Vector2(125,0)
	else:
		direction = Vector2.LEFT
		raycast.target_position = Vector2(-125,0)
		
		
	animated_sprite_2d.flip_h = direction.x > 0
	
func enemy_fall(delta):
	velocity.y += GRAVITY * delta
	
func  enemy_idle(delta):
	velocity.x = move_toward(velocity.x , 0 , SPEED * delta)
	current_state = State.Idle
	

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	collision_shape_2d.set_deferred("disabled", true)
	# Attendre un peu avant de supprimer le node (le temps de jouer l'anim par exemple)
	await animated_sprite_2d.animation_finished
	queue_free()


func animated_enemy(_delta):
	if current_state ==  State.Idle:
		animated_sprite_2d.play("Idle")
	elif current_state == State.Walk:
		animated_sprite_2d.play("Run")
	elif current_state == State.Chase:
		animated_sprite_2d.play("Run")
		
