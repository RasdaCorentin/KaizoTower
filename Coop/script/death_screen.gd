extends Control



func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/Game.tscn")


func _on_give_up_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/credit.tscn")
