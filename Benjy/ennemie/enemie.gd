extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast : RayCast2D = $AnimatedSprite2D/RayCast2D
@export var player = CharacterBody2D

const GRAVITY = 1000
const SPEED = 100

enum State { Idle , Walk , Chase}

var current_state : State
var direction


func _ready() -> void:
	current_state = State.Idle;
	

func _physics_process(delta: float) -> void:
	
	enemy_gravity(delta)
	enemy_Idle(delta)
	enemy_run(delta)
	
	move_and_slide()
	
	enemey_animtion(delta)
	
func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta
	
func enemy_Idle(delta):
	velocity.x = move_toward(velocity.x, 0 , SPEED * delta)
	current_state = State.Idle
	
func enemy_run(delta : float):
	velocity = velocity.move_toward(direction * SPEED, 300 * delta)
	
	if direction != 0:
		current_state = State.Walk
		animated_sprite_2d.flip_h = false if direction > 0 else true


func look_player():
	if ray_cast.is_colliding():
		var colider = ray_cast.get_collider()
		if colider == player:
			chase_player()
		elif current_state == State.Chase:
			stop_chase()
	elif current_state == State.Chase:
		stop_chase()
		
func  chase_player():
	current_state = State.Chase
	
func stop_chase():
	pass
	
	


func enemey_animtion(delta):
	if current_state == State.Idle :
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk: 
		animated_sprite_2d.play("Run")
