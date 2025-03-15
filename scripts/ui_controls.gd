extends Control

func _ready():
	$WinMessage.hide()
	$PauseGame.hide()

func display_win():
	$WinMessage.display_win()

func _on_pause_button_pressed():
	get_tree().paused = !get_tree().paused
	$PauseGame.visible = get_tree().paused
