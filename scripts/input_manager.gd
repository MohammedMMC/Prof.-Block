extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func find_node_with_method(node, method, max_depth=5, current_depth=0):
	if current_depth > max_depth: return null
	if node.has_method(method): return node
	
	for child in node.get_children():
		var result = find_node_with_method(child, method, max_depth, current_depth + 1)
		if result: return result
	
	return null

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		var current_scene = get_tree().current_scene
		
		if current_scene.scene_file_path and current_scene.scene_file_path.begins_with("res://scenes/levels/"):
			var ui = find_node_with_method(current_scene, "_on_pause_button_pressed")
			if ui: ui._on_pause_button_pressed()
			
		elif current_scene.has_method("_on_back_button_pressed"):
			current_scene._on_back_button_pressed()
