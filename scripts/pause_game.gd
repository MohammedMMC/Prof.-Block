extends Control

func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:
		_on_resume_button_pressed()

func _on_resume_button_pressed() -> void:
	get_tree().set("paused", false)
	visible = false
	get_parent().get_node("HBoxContainer/timer").resume()

func _on_retry_button_pressed() -> void:
	get_tree().set("paused", false)
	var current_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene)

func _on_levels_button_pressed() -> void:
	get_tree().set("paused", false)
	get_tree().change_scene_to_file("res://scenes/levels.tscn")
