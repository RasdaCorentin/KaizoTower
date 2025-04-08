extends Area2D
@onready var player : CharacterBody2D = $".."
@onready var collider : CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	if player.attacking:
		collider.set_disabled(false)
	else : 
		collider.set_disabled(true)
