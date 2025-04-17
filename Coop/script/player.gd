extends CharacterBody2D

@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var mur_gauche: TileMap = $"../Murs/Mur1"
@onready var mur_droit: TileMap = $"../Murs/Mur2"
@onready var trophy : Node2D = $"../Trphy"
@onready var boost = $"../boost1"
@onready var boost_img = $"../boost1/StaticBody2D/LivreFerme"
@onready var logo_img : Sprite2D = $"../boost1/Trophée1"
@onready var livre_ouvert = preload("res://assets/livre/Livreouvert.png")

var dans_zone_boost = false
var start_scene = true
var energy = 100
var max_energy = 100
const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const ATTACK_SPEED = 800.0
const ATTACK_DURATION = 0.3 # en secondes

var attacking = false
var attack_timer = 0.0
var livreferme : CompressedTexture2D
var taille : Vector2
var pos : Vector2
func _ready():
	livreferme = boost_img.get_texture()
	taille = boost_img.get_scale()
	pos = boost_img.get_position()

	$AttackArea.monitoring = false
	set_energy_bar()

func _physics_process(delta: float) -> void:
	
	if position.x <= (boost.position.x +500)  and position.x >= (boost.position.x - 100) :
		if not dans_zone_boost:
			dans_zone_boost = true
			boost_img.set_scale(Vector2(0.8,0.8))
			boost_img.set_position(Vector2(boost_img.position.x + 370,boost_img.position.y + 150))
			boost_img.set_texture(livre_ouvert)
			
	else:
		if dans_zone_boost:
			dans_zone_boost = false
			boost_img.set_texture(livreferme)
			boost_img.set_scale(taille)
			boost_img.set_position(pos)
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
	
	if Input.is_action_just_pressed("attack") and start_scene:
		#créer l'événement pour commencer la partie
		if (trophy.position.x + 400) >= position.x :
			start_scene = false 
			mur_droit.VISIBILITY_MODE_FORCE_HIDE
			mur_gauche.queue_free()
			trophy.queue_free()
		
	if Input.is_action_just_pressed("attack") and energy >= 10 and direction != 0:
		$AttackArea.monitoring = true
	
		attacking = true
		attack_timer = ATTACK_DURATION
		animated_sprite_2d.play("coup")
		velocity.x += direction * ATTACK_SPEED
		energy -= 10
		set_energy_bar()
		await animated_sprite_2d.animation_finished
		$AttackArea.monitoring = false
		return
	set_energy_bar()
	move_and_slide() 

func _on_attack_area_body_entered(body: Node2D) -> void:
	if attacking and body.has_method("take_damage"):
		body.take_damage()

func set_energy_bar() -> void:
	$EnergyBar.value = energy
