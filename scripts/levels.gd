extends Control

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game1.tscn")


func _on_button2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game2.tscn")


func _on_button3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game3.tscn")


func _on_button4_pressed() -> void:
	pass # Replace with function body.


func _on_button5_pressed() -> void:
	pass # Replace with function body.
