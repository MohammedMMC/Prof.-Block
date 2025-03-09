extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game1.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
