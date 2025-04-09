extends Node

func _ready():
	await get_tree().process_frame
	if GlobalSettings.get_fullscreen_enabled():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	TranslationServer.set_locale(GlobalSettings.get_language())
