extends Control

@onready var flow_container = $Panel/PanelContainer/MarginContainer/FlowContainer
@onready var back_button = $"Panel/PanelContainer/MarginContainer/Panel/back levels button"
@onready var next_button = $"Panel/PanelContainer/MarginContainer/Panel/next levels button"
@onready var template_button = $Panel/PanelContainer/MarginContainer/FlowContainer/Button2
	
@onready var total_levels = get_file_count("res://scenes/levels")
var current_page = 0
var levels_per_page = 15
var level_buttons = []

func _ready():
	if template_button: template_button.visible = false
	
	for child in flow_container.get_children():
		if child != template_button:
			flow_container.remove_child(child)
			child.queue_free()
	
	for i in range(1, total_levels + 1):
		var button = Button.new()
		button.custom_minimum_size = template_button.custom_minimum_size
		button.size_flags_horizontal = template_button.size_flags_horizontal
		button.size_flags_vertical = template_button.size_flags_vertical
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		button.add_theme_font_override("font", template_button.get_theme_font("font"))
		button.add_theme_font_size_override("font_size", template_button.get_theme_font_size("font_size"))
		
		for style_type in ["normal", "hover", "pressed", "focus", "disabled"]:
			var style = template_button.get_theme_stylebox(style_type)
			if style:
				button.add_theme_stylebox_override(style_type, style.duplicate())
		
		for color_type in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
			if template_button.has_theme_color(color_type):
				button.add_theme_color_override(color_type, template_button.get_theme_color(color_type))
		
		button.text = str(i)
		button.name = "LevelButton" + str(i)
		level_buttons.append(button)
		button.pressed.connect(_on_level_button_pressed.bind(i))
	
	update_visible_levels()

func update_visible_levels():
	for child in flow_container.get_children():
		if child != template_button: flow_container.remove_child(child)
	
	var start_index = current_page * levels_per_page
	var end_index = min(start_index + levels_per_page, total_levels)
	
	for i in range(start_index, end_index):
		flow_container.add_child(level_buttons[i])
	
	if back_button:
		var is_first_page = (current_page == 0)
		back_button.disabled = is_first_page
		back_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_first_page else Control.CURSOR_POINTING_HAND
	
	if next_button:
		var is_last_page = (end_index >= total_levels)
		next_button.disabled = is_last_page
		next_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_last_page else Control.CURSOR_POINTING_HAND

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_levels_button_pressed():
	if current_page > 0:
		current_page -= 1
		update_visible_levels()

func _on_next_levels_button_pressed():
	if (current_page + 1) * levels_per_page < total_levels:
		current_page += 1
		update_visible_levels()

func _on_level_button_pressed(level_number):
		get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % level_number)

func get_file_count(path: String) -> int:
	var dir = DirAccess.open(path)
	if dir == null: return 0

	var count = 0
	dir.list_dir_begin()
	while dir.get_next() != "":
		if !dir.current_is_dir(): count += 1
	dir.list_dir_end()
	return count
