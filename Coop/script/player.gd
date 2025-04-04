extends CharacterBody2D

@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var energy = 100
var max_energy = 100
const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const ATTACK_SPEED = 800.0
const ATTACK_DURATION = 0.3 # en secondes

var attacking = false
var attack_timer = 0.0

func _ready():
	$AttackArea.monitoring = false

func _physics_process(delta: float) -> void:
	#Récupération d'énergie 
	if energy < max_energy:
		energy += 5 * delta
		# Si attaque en cours
	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
		move_and_slide()
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.

	
	# On a la direction (0,1 ou -1)
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0 : 
		animated_sprite_2d.flip_h = false
	elif direction < 0 :
		animated_sprite_2d.flip_h = true
	else :
		animated_sprite_2d.play("idle")
	if direction:
		animated_sprite_2d.play("run")
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_pressed("attack") and energy >= 10 and direction != 0:
		$AttackArea.monitoring = true
		attacking = true
		attack_timer = ATTACK_DURATION
		animated_sprite_2d.play("coup")
		velocity.x += direction * ATTACK_SPEED
		energy -= 10
		move_and_slide()
		await animated_sprite_2d.animation_finished
		$AttackArea.monitoring = false
		return
	move_and_slide() 

func _on_attack_area_body_entered(body: Node2D) -> void:
	if attacking and body.has_method("take_damage"):
		print("hit")
		body.take_damage()
