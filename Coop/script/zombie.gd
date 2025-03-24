extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var health = 3
var is_dead = false
const SPEED = 500.0

func _ready():
	add_to_group("enemies")
	


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Le zombie avance à gauche
	var direction = 0
	velocity.x = direction * SPEED

	move_and_slide()

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
