extends CharacterBody2D

@onready var level : Label = $Camera2D/LVL
@onready var label : Label = $Camera2D/Points
@onready var endzone : Node2D = $"../EndZone"
@onready var timer : Timer = $"../EndZone/End/Timer"
@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var mur_gauche: TileMap = $"../Murs/Mur1"
@onready var mur_droit: TileMap = $"../Murs/Mur2"
@onready var trophy : Node2D = $"../Trphy"
@onready var boost = $"../boost1"
@onready var boost_img = $"../boost1/StaticBody2D/LivreFerme"
@onready var boost2 = $"../boost2"
@onready var boost_img2 = $"../boost2/StaticBody2D/LivreFerme"
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
var which_book = 0
var attacking = false
var attack_timer = 0.0
var livreferme : CompressedTexture2D
var taille : Vector2
var pos : Vector2
var pos2 : Vector2

func _ready():
	livreferme = boost_img.get_texture()
	taille = boost_img.get_scale()
	pos = boost_img.get_position()
	pos2 = boost_img2.get_position()

	$AttackArea.monitoring = false
	set_energy_bar()

func _physics_process(delta: float) -> void:
	label.text = "Points : {money}".format({"money" : GameData.money})
	level.text = "Level : {level}".format({"level" : GameData.level})
	endzone_management()
	boost_setup()
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
		velocity.x = direction * SPEED * GameData.speed_boost
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("attack") and start_scene:
		#créer l'événement pour commencer la partie
		if (trophy.position.x + 400) >= position.x :
			start_scene = false 
			mur_droit.queue_free()
			mur_gauche.queue_free()
			trophy.queue_free()
			boost2.queue_free()
			boost.queue_free()
	
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
		body.take_damage(GameData.dmg)

func set_energy_bar() -> void:
	$EnergyBar.value = energy

func boost_setup() -> void:
	if start_scene and position.x <= (boost2.position.x +500)  and position.x >= (boost2.position.x - 100) :
		if not dans_zone_boost:
			which_book = 2
			dans_zone_boost = true
			boost_img2.set_scale(Vector2(0.8,0.8))
			boost_img2.set_position(Vector2(pos2.x + 370,pos2.y + 150))
			boost_img2.set_texture(livre_ouvert)
			
	elif start_scene and position.x <= (boost.position.x +500)  and position.x >= (boost.position.x - 100) :
		if not dans_zone_boost:
			which_book = 1
			dans_zone_boost = true
			boost_img.set_scale(Vector2(0.8,0.8))
			boost_img.set_position(Vector2(pos.x + 370,pos.y + 150))
			boost_img.set_texture(livre_ouvert)
			
	else:
		if dans_zone_boost:
			dans_zone_boost = false
			which_book = 0
			boost_img.set_texture(livreferme)
			boost_img.set_scale(taille)
			boost_img.set_position(pos)
			boost_img2.set_texture(livreferme)
			boost_img2.set_scale(taille)
			boost_img2.set_position(pos2)
			
	if Input.is_action_just_pressed("attack") and dans_zone_boost:
		if which_book == 1:
			if GameData.money > 0:
				GameData.dmg += 1
				GameData.money -= 3
		else :
			if GameData.money > 0: 
				GameData.speed_boost += 0.05
				GameData.money -= 1
func endzone_management():
	if endzone.position.x > position.x:
		timer.start()
	
func _on_timer_timeout() -> void:
	#DIFFICULTES
	GameData.level += 1
	GameData.horde += 0.07
	GameData.toucher += 0.04
	GameData.health += 2
	get_tree().reload_current_scene()
