extends Control

const SETTINGS_FILE = "user://settings.dat"
var game_data = {}

func _ready():
	$WinMessage.hide()
	$PauseGame.hide()
	if $HBoxContainer/timer:
		$HBoxContainer/timer.running = true
	
	if not GlobalSettings.get_touch_buttons_enabled():
		$LeftButton.hide()
		$RightButton.hide()
		$StoneButton.hide()

func load_settings():
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		game_data = file.get_var()
		file.close()
	else:
		game_data = {
			"fullscreen": false,
			"touchbuttons": false,
		}

func display_win():
	$WinMessage.display_win()
	$HBoxContainer/timer.pause()

func _on_pause_button_pressed():
	get_tree().set("paused", not get_tree().paused)
	$PauseGame.visible = get_tree().paused
	if get_tree().paused:
		$HBoxContainer/timer.pause()
	else:
		$HBoxContainer/timer.resume()
