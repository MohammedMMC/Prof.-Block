extends Control

func _ready():
	$WinMessage.hide()
	$PauseGame.hide()
	if $HBoxContainer/timer:
		$HBoxContainer/timer.running = true

func display_win():
	$WinMessage.display_win()
	$HBoxContainer/timer.pause()

func _on_pause_button_pressed():
	get_tree().paused = !get_tree().paused
	$PauseGame.visible = get_tree().paused
	if get_tree().paused:
		$HBoxContainer/timer.pause()
	else:
		$HBoxContainer/timer.resume()
