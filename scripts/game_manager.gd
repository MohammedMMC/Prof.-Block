extends Node

signal game_won

func _ready():
	add_to_group("game_manager")
	await get_tree().process_frame
	check_game_state()

func check_game_state():
	var portals = get_tree().get_nodes_in_group("portals")
	if portals.size() == 0:
		return
		
	for portal in portals:
		if not portal.is_player_inside():
			return
			
	game_won.emit()

func _on_player_entered_portal():
	check_game_state()
