extends Control

func _ready():
	hide()

func display_win():
	var root = get_tree().get_root()
	var moves_counter = root.find_child("MovesCounter", true, false)
	var moves = 0
	
	if moves_counter and moves_counter.has_method("get_moves"):
		moves = moves_counter.get_moves()
	var label = get_node_or_null("Panel/Label")
	if label:
		label.text = "Level Complete!\nMoves: " + str(moves)
	visible = true

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levels.tscn")
