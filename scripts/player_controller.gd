extends Node

var players = []
var current_player_index = -1
var selection_indicators = {}

func _ready():
	await get_tree().process_frame
	players = get_tree().get_nodes_in_group("players")
	for p in players:
		var ind = create_selection_indicator()
		p.add_child(ind)
		selection_indicators[p] = ind
		ind.hide()
	if players.size() > 0: select_player(players[0])

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_player_at_position(get_viewport().get_mouse_position())

func cycle_player_selection():
	if players.size() == 0:
		return
		
	if current_player_index >= 0 and current_player_index < players.size():
		players[current_player_index].selected = false
		selection_indicators[players[current_player_index]].hide()
	
	current_player_index = (current_player_index + 1) % players.size()
	select_player(players[current_player_index])

func select_player_at_position(pos):
	if players.size() == 0:
		return
		
	var space = players[0].get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 3
	
	var results = space.intersect_point(query)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("players"):
			if collider.selected:
				deselect_all_players()
			else:
				select_player(collider)
			break

func select_player(player):
	deselect_all_players()
	player.selected = true
	selection_indicators[player].show()
	current_player_index = players.find(player)

func deselect_all_players():
	for p in players:
		p.selected = false
		selection_indicators[p].hide()
	current_player_index = -1
