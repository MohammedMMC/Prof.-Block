extends Node

const SETTINGS_FILE = "user://settings.dat"
var game_data = {}

func _ready():
	if OS.get_name() not in ["macOS", "Windows"]:
		game_data = {
			"fullscreen": true,
			"touchbuttons": true,
			"language": "en",
		}
	else:
		load_data()

func load_data():
	var default_settings = {
		"fullscreen": false,
		"touchbuttons": false,
		"language": "en",
	}
	
	if not FileAccess.file_exists(SETTINGS_FILE):
		game_data = default_settings.duplicate()
		save_data()
	else:
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		game_data = file.get_var()
		file.close()
		for key in default_settings:
			if not game_data.has(key):
				game_data[key] = default_settings[key]
		save_data()

func save_data():
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_var(game_data)
	file.close()

func get_touch_buttons_enabled():
	if game_data.has("touchbuttons"):
		return game_data.touchbuttons
	return false

func get_fullscreen_enabled():
	if game_data.has("fullscreen"):
		return game_data.fullscreen
	return false

func get_language():
	if game_data.has("language"):
		return game_data.language
	return "en"
