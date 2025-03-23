extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

	move_and_slide() 
