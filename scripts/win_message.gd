extends Control

@onready var golden_star_1: TextureRect = $Panel2/PanelContainer/VBoxContainer/HBoxContainer/Star1/TextureRect
@onready var golden_star_2: TextureRect = $Panel2/PanelContainer/VBoxContainer/HBoxContainer/Star2/TextureRect
@onready var golden_star_3: TextureRect = $Panel2/PanelContainer/VBoxContainer/HBoxContainer/Star3/TextureRect
@onready var next_button = $"Panel2/PanelContainer/VBoxContainer/HBoxContainer2/next button"

func _ready():
	hide()

func display_win():
	var root = get_tree().get_root()
	var moves_counter = root.find_child("MovesCounter", true, false)

	var game_timer = root.find_child("timer", true, false)
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	var moves: int = 0
	var time_elapsed: int = 0
	var min_moves: int = 0
	var min_time: int = 0
	
	if game_manager and game_manager.has_method("get") and "min_moves" in game_manager:
		min_moves = game_manager.min_moves
		min_time = game_manager.min_time
	
	if game_timer and "time_elapsed" in game_timer:
		time_elapsed = game_timer.time_elapsed
	
	if moves_counter and moves_counter.has_method("get_moves"):
		moves = moves_counter.get_moves()
	
	var score: float = ((float(moves) / float(min_moves)) + (float(time_elapsed) / float(min_time))) / 2.0

	if score <= 1.0:
		golden_star_1.show()
		golden_star_2.show()
		golden_star_3.show()
	elif score <= 1.5:
		golden_star_1.show()
		golden_star_2.show()
	elif score <= 2.0:
		golden_star_1.show()
	
	var regex = RegEx.new()
	regex.compile("level(\\d+)\\.tscn$")
	var result = regex.search(get_tree().get_current_scene().scene_file_path)
	var current_level = int(result.get_string(1))

	if result:
		var next_level = current_level + 1
		var next_level_path = "res://scenes/levels/level%d.tscn" % next_level
		if not ResourceLoader.exists(next_level_path):
			next_button.hide()
	else:
		next_button.hide()
	
	GameState.complete_level(current_level, 3 if score <= 1.0 else 2 if score <= 1.5 else 1)
	visible = true

func _on_levels_button_pressed() -> void:
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/levels.tscn")


func _on_next_button_pressed() -> void:
	var current_scene_path = get_tree().get_current_scene().scene_file_path
	
	var regex = RegEx.new()
	regex.compile("level(\\d+)\\.tscn$")
	var result = regex.search(current_scene_path)
	
	if result:
		var next_level = int(result.get_string(1)) + 1
		var next_level_path = "res://scenes/levels/level%d.tscn" % next_level
		
		if ResourceLoader.exists(next_level_path):
			TransitionScenes.start()
			await TransitionScenes.transition_scene_finished
			get_tree().change_scene_to_file(next_level_path)
		else:
			next_button.hide()
	else:
		next_button.hide()
