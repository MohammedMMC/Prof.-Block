extends Control

func _on_play_button_pressed() -> void:
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/levels.tscn")


func _on_settings_button_pressed() -> void:
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
