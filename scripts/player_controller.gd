extends Node

var players = []
var current_player_index = -1
var selection_indicators = {}

func _ready():
	add_to_group("player_controller")
	await get_tree().process_frame
	players = get_tree().get_nodes_in_group("players")
	for p in players:
		var ind = create_selection_indicator()
		p.add_child(ind)
		selection_indicators[p] = ind
		ind.hide()
	if players.size() > 0: select_player(players[0])
	
	var stone_button = get_tree().get_first_node_in_group("stone_button")
	if stone_button:
		stone_button.pressed.connect(turn_selected_player_to_stone)

func create_selection_indicator() -> Node2D:
	var ind = Node2D.new()
	var rect = ColorRect.new()
	rect.offset_left = -18
	rect.offset_top = -18
	rect.offset_right = 18
	rect.offset_bottom = 18
	rect.color = Color(1, 1, 1, 0.2)
	ind.add_child(rect)
	var border = Line2D.new()
	border.points = PackedVector2Array([-18, -18, 18, -18, 18, 18, -18, 18, -18, -18])
	border.width = 2.0
	border.default_color = Color(1, 1, 1, 0.8)
	ind.add_child(border)
	return ind

func _input(event):
	if event.is_action_pressed("ui_focus_next"): cycle_player_selection()
	if event.is_action_pressed("ui_e"): turn_selected_player_to_stone()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_player_at_position(get_viewport().get_mouse_position())

func cycle_player_selection():
	if players.size() == 0: return
	
	players = players.filter(func(p): return is_instance_valid(p))
	
	var available_players = players.filter(func(p):
		return is_instance_valid(p) and p.visible
	)
	if available_players.is_empty(): return
	
	if current_player_index >= 0 and current_player_index < players.size():
		players[current_player_index].selected = false
		selection_indicators[players[current_player_index]].hide()
	
	var current_player = players[current_player_index] if current_player_index >= 0 else null
	var current_idx = available_players.find(current_player)
	var next_idx = (current_idx + 1) % available_players.size()
	select_player(available_players[next_idx])

func select_player_at_position(pos):
	if players.size() == 0: return
	
	players = players.filter(func(p): return is_instance_valid(p))
	if players.is_empty(): return
	
	var space = players[0].get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 3
	
	var results = space.intersect_point(query)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("players") and collider.visible:
			if collider.selected: deselect_all_players()
			else: select_player(collider)
			break

func select_player(player):
	deselect_all_players()
	player.selected = true
	selection_indicators[player].show()
	current_player_index = players.find(player)

func deselect_all_players():
	for p in players:
		if not p or not p.visible: return
		p.selected = false
		selection_indicators[p].hide()
	current_player_index = -1

func turn_selected_player_to_stone():
	if current_player_index >= 0 and current_player_index < players.size():
		var player = players[current_player_index]
		if player and get_players_at_same_position(player) == 1 and not player.is_in_any_portal() and not player.is_in_portal() and player.has_floor_below():
			var index_to_remove = current_player_index
			deselect_all_players()
			players.remove_at(index_to_remove)
			player.queue_free()
			
			var root = get_tree().root
			var current_scene = root.get_child(root.get_child_count() - 1)
			var tilemap = current_scene.get_node("TileMap")
			if tilemap:
				var tile_pos = tilemap.local_to_map(tilemap.to_local(player.global_position))
				tilemap.set_cell(0, tile_pos, 0, Vector2i(0, 0))

func get_players_at_same_position(target_player) -> int:
	if not is_instance_valid(target_player) or players.is_empty():
		return 0
		
	return players.filter(func(p):
		return is_instance_valid(p) and p.visible and p.global_position.distance_to(target_player.global_position) <= 5.0
	).size()
