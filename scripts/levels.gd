extends Control

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level_button_pressed(level_number: int) -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % level_number)
