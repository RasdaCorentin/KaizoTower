extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D


const GRAVITY = 100 
const  SPEED = 300

enum State {Idle,run}

var curente_state 

func _ready() -> void:
	curente_state = State.Idle
	
	
func _process(delta: float) -> void:
	player_falling(delta)
	player_jump(delta)
	player_Idle(delta)
	player_run(delta)
	
	move_and_slide()
	
	player_animation()

func player_falling(delta):
	if !is_on_floor():
		velocity.y = GRAVITY + delta
		
		
func player_Idle(_delta):
	if (is_on_floor()):
		curente_state = State.Idle
		
		
func player_jump(_delta):
	if (is_on_floor() && Input.is_action_just_pressed("jump")):
		velocity.y = -20000
		
		
func player_run(_delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if (direction) :
		velocity.x = direction * SPEED
	else :
		velocity.x = move_toward(velocity.x,0,SPEED)
		
	if direction != 0:
		curente_state = State.run
		animated_sprite_2d.flip_h = false if direction > 0 else true
		
func player_animation():
	if curente_state == State.Idle :
		animated_sprite_2d.play("idle")
	elif curente_state == State.run: 
		animated_sprite_2d.play("run")
