extends Control

@onready var flow_container = $Panel/PanelContainer/MarginContainer/FlowContainer
@onready var back_button = $"Panel/PanelContainer/MarginContainer/Panel/back levels button"
@onready var next_button = $"Panel/PanelContainer/MarginContainer/Panel/next levels button"
@onready var template_button = $Panel/PanelContainer/MarginContainer/FlowContainer/Button2
@onready var total_levels = get_file_count("res://scenes/levels")
@onready var disabled_star_texture = preload("res://images/menus/star-disabled.png")
@onready var active_star_texture = preload("res://images/menus/star.png")

var current_page = 0
var levels_per_page = 15
var level_buttons = []
var star_positions = [Vector2(0, -17), Vector2(17, -13), Vector2(33, -17)]

func _ready():
	if template_button: template_button.visible = false
	clear_container()
	create_level_buttons()
	update_visible_levels()

func clear_container():
	for child in flow_container.get_children():
		if child != template_button:
			flow_container.remove_child(child)

func create_level_buttons():
	for i in range(1, total_levels + 1):
		var button = create_level_button(i)
		level_buttons.append(button)
		button.pressed.connect(_on_level_button_pressed.bind(i))

func create_level_button(level_number):
	var button = Button.new()
	button.custom_minimum_size = template_button.custom_minimum_size
	button.size_flags_horizontal = template_button.size_flags_horizontal
	button.size_flags_vertical = template_button.size_flags_vertical
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.text = str(level_number)
	button.name = "LevelButton" + str(level_number)
	
	button.add_theme_font_override("font", template_button.get_theme_font("font"))
	button.add_theme_font_size_override("font_size", template_button.get_theme_font_size("font_size"))
	
	for style_type in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style = template_button.get_theme_stylebox(style_type)
		if style: button.add_theme_stylebox_override(style_type, style.duplicate())
	
	for color_type in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		if template_button.has_theme_color(color_type):
			button.add_theme_color_override(color_type, template_button.get_theme_color(color_type))
	
	for i in range(3):
		var star = TextureRect.new()
		star.name = "CStar" + str(i+1)
		star.texture = template_button.get_node("CStar" + str(i+1)).texture
		star.layout_mode = 1
		star.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		star.position.y = button.size.y + star_positions[i].y
		star.position.x = star_positions[i].x
		button.add_child(star)
	
	update_level_stars(button, level_number)
	return button

func update_level_stars(button, level_number):
	var is_accessible = is_level_accessible(level_number)
	button.disabled = !is_accessible
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if is_accessible else Control.CURSOR_ARROW
	
	var stars_earned = 0
	if has_node("/root/GameState") and is_accessible:
		stars_earned = GameState.get_level_stars(level_number)
	
	for i in range(3):
		var star = button.get_node("CStar" + str(i+1))
		star.visible = is_accessible
		if is_accessible:
			star.texture = active_star_texture if stars_earned > i else disabled_star_texture
			star.position.y = button.size.y + star_positions[i].y
			star.position.x = star_positions[i].x

func is_level_accessible(level_number):
	if level_number == 1: return true
	return has_node("/root/GameState") and GameState.is_level_completed(level_number - 1)

func update_visible_levels():
	clear_container()
	var start_index = current_page * levels_per_page
	var end_index = min(start_index + levels_per_page, total_levels)
	
	for i in range(start_index, end_index):
		flow_container.add_child(level_buttons[i])
		update_level_stars(level_buttons[i], i + 1)
	
	if back_button:
		var is_first_page = (current_page == 0)
		back_button.disabled = is_first_page
		back_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_first_page else Control.CURSOR_POINTING_HAND
	
	if next_button:
		var is_last_page = (end_index >= total_levels)
		next_button.disabled = is_last_page
		next_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_last_page else Control.CURSOR_POINTING_HAND

func _on_back_button_pressed():
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
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
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % level_number)

func get_file_count(path: String) -> int:
	var dir = DirAccess.open(path)
	if dir == null: return 0
	
	var count = 0
	dir.list_dir_begin()
	while dir.get_next() != "": if !dir.current_is_dir(): count += 1
	dir.list_dir_end()
	return count
