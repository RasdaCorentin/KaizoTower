extends CharacterBody2D


const SPEED = 350.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity.x = GameData.horde * SPEED
	move_and_slide()
