extends Control

@onready var display_options_button = $Panel/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DisplayOptionButton
@onready var touchbuttons_checkbox = $Panel/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control/TouchbuttonsCheckbox

func _ready():
	display_options_button.select(1 if GlobalSettings.get_fullscreen_enabled() else 0)
	touchbuttons_checkbox.button_pressed = GlobalSettings.get_touch_buttons_enabled()

func _on_display_option_button_item_selected(index: int) -> void:
	if index == 0: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		GlobalSettings.game_data.fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		GlobalSettings.game_data.fullscreen = true
	GlobalSettings.save_data()

func _on_touchbuttons_checkbox_toggled(toggled_on: bool) -> void:
	GlobalSettings.game_data.touchbuttons = toggled_on
	GlobalSettings.save_data()

func _on_back_button_pressed() -> void:
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
