extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	timer.start()

func _on_timer_timeout() -> void:
	GameData.level = 1
	GameData.horde = 1
	GameData.money = 0
	GameData.health = 6
	GameData.toucher = 0.04 
	GameData.dmg = 1
	GameData.speed_boost = 1.0
	get_tree().change_scene_to_file("res://scene/death_screen.tscn") # Replace with function body.
