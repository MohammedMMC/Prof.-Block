extends StaticBody2D

var has_player_inside = false
var overlapping_players = []
@export var portal_texture: Texture2D:
	set(value):
		portal_texture = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value

func _ready():
	if portal_texture:
		$Sprite2D.texture = portal_texture
	add_to_group("portals")
	var area = Area2D.new()
	area.name = "CollisionArea"
	var collision = CollisionShape2D.new()
	collision.shape = $CollisionShape2D.shape.duplicate()
	area.add_child(collision)
	
	area.collision_layer = 0
	area.collision_mask = 3
	
	area.connect("body_entered", _on_body_entered)
	area.connect("body_exited", _on_body_exited)
	add_child(area)

func _on_body_exited(body):
	if not body.is_in_group("players"): return
	overlapping_players.erase(body)
	if overlapping_players.size() == 1:
		_on_body_entered(overlapping_players[0], true)

func _on_body_entered(body, called_from_exit = false):
	if not body.is_in_group("players") or not self.has_floor_below(): return
	if not overlapping_players.has(body): overlapping_players.append(body)
	
	if overlapping_players.size() > 1: return
	if has_player_inside: return
	
	var portal_color = extract_color_from_path(portal_texture.resource_path)
	var player_color = extract_color_from_path(body.player_texture.resource_path)
	
	if portal_color != player_color: return
	
	has_player_inside = true
	$Sprite2D.visible = false
	
	var root = get_tree().root
	var current_scene = root.get_child(root.get_child_count() - 1)
	var tilemap = current_scene.get_node("TileMap")
	if tilemap:
		var tile_pos = tilemap.local_to_map(tilemap.to_local(global_position))
		tilemap.set_cell(0, tile_pos, 0, Vector2i(0, 0))
	
	var player_controller = get_tree().get_first_node_in_group("player_controller")
	if player_controller and not called_from_exit: player_controller.deselect_all_players()
	
	body.queue_free()
	
	get_tree().call_group("game_manager", "_on_player_entered_portal")

func extract_color_from_path(path: String) -> String:
	var filename = path.get_file()
	if filename.begins_with("portal-"):
		return filename.split(".")[0].split("-")[1]
	else:
		return filename.split(".")[0]

func is_player_inside(): return has_player_inside

func has_floor_below() -> bool:
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = global_position + Vector2(0, $Sprite2D.texture.get_height() * $Sprite2D.scale.y)
	query.exclude = [self]
	query.collision_mask = 1
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if not result.is_empty():
		var collider = result["collider"]
		return not collider.is_in_group("players") and not collider.is_in_group("portals")
	return false
