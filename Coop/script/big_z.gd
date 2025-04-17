extends CharacterBody2D
@onready var animated_sprite_2d =$AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var health = 11
var is_dead = false
const SPEED = 20000
const Chase_SPEED= 20200
const BUMP_TIMER = 0.2
const GRAVITY = 1000
#Ajout Corentin : But: Bump
var attacked = false
var toucher = 1.0
var bump_timer = 0.0
# Variables d'ennemi
enum State { Idle , Walk , Chase }
var direction = Vector2.LEFT
var current_state : State


# Fonction pour configurer les patrouilles
func _ready():
	if is_dead:
		return
		
	add_to_group("enemies")
		# Vérification si le nœud de patrouille contient des enfant
		
	current_state = State.Idle

# Fonction pour faire patrouiller l'ennemi
func _process(delta):
	# Vérifier que les points de patrouille existent avant d'essayer de les utiliser
		enemy_run(delta)
		enemy_fall(delta)
		
		if attacked : 
			bump_timer -= delta
			enemy_idle(delta)
			toucher += 0.01
			position.x -= -1500 * delta
			position.y -= 10
			if bump_timer <= 0:
				attacked = false
			move_and_slide()	
		move_and_slide()
		animated_enemy(delta)
			
func chase_player():
	current_state = State.Chase
	


	
func enemy_run(delta : float):
		velocity.x = direction.x * SPEED * delta * toucher
			
		current_state = State.Walk
		direction = Vector2.LEFT
	
func enemy_fall(delta):
	velocity.y += GRAVITY * delta
	
func  enemy_idle(delta):
	velocity.x = move_toward(velocity.x , 0 , SPEED * delta)
	current_state = State.Idle
	

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	health -= amount
	bump_timer = BUMP_TIMER
	attacked = true
	#Le joueur n'est pas le collisionneur (WTF???) 
	#Move and slide est lié à la vélocité 
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
		
