extends Control

const SETTINGS_FILE = "user://settings.dat"

var game_data = {}

@onready var display_options_button = $Panel/Panel/HBoxContainer/DisplayOptionButton

func _ready():
	load_data()
	display_options_button.select(1 if game_data.fullscreen else 0)

func load_data():
	if not FileAccess.file_exists(SETTINGS_FILE):
		game_data = {
			"fullscreen": false,
		}
		save_data()
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	game_data = file.get_var()
	file.close()

func save_data():
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_var(game_data)
	file.close()
	

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_display_option_button_item_selected(index: int) -> void:
	if index == 0: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		game_data.fullscreen = false
		save_data()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		game_data.fullscreen = true
		save_data()
