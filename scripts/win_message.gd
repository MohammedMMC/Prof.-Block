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
	var moves = 0
	var min_moves = 20;
	
	if moves_counter and moves_counter.has_method("get_moves"):
		moves = moves_counter.get_moves()
	
	if moves <= min_moves:
		golden_star_1.show()
		golden_star_2.show()
		golden_star_3.show()
	elif moves <= (min_moves + 10):
		golden_star_1.show()
		golden_star_2.show()
	elif moves <= (min_moves + 20):
		golden_star_1.show()
	
	visible = true

func _on_levels_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels.tscn")


func _on_next_button_pressed() -> void:
	var current_scene_path = get_tree().get_current_scene().scene_file_path
	
	var regex = RegEx.new()
	regex.compile("level(\\d+)\\.tscn$")
	var result = regex.search(current_scene_path)
	
	if result:
		var next_level = int(result.get_string(1)) + 1
		var next_level_path = "res://scenes/levels/level%d.tscn" % next_level
		
		var file = FileAccess.open(next_level_path, FileAccess.READ)
		if file:
			file.close()
			get_tree().change_scene_to_file(next_level_path)
		else:
			next_button.hide()
	else:
		next_button.hide()
