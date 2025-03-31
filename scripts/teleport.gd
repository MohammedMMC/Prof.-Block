extends StaticBody2D

@export var teleport_texture: Texture2D:
	set(value):
		teleport_texture = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value

@export var port_id: int:
	set(value): port_id = value

func _ready():
	if teleport_texture and has_node("Sprite2D"):
		$Sprite2D.texture = teleport_texture
	add_to_group("teleports")
	
	var area = Area2D.new()
	area.name = "CollisionArea"
	var collision = CollisionShape2D.new()
	collision.shape = $CollisionShape2D.shape.duplicate()
	area.add_child(collision)
	
	area.collision_layer = 0
	area.collision_mask = 3
	
	area.connect("body_entered", _on_body_entered)
	add_child(area)

func _on_body_entered(body):
	if not body.is_in_group("players"): return
	teleport_player(body)

func teleport_player(player):
	var target_port = find_matching_port()
	if not target_port: return
	
	$Sprite2D.visible = false
	player.set_movement_enabled(false)
	player.target_position = null
	player.velocity = Vector2.ZERO
	player.reset_rotation()
	# player.get_node("Sprite2D").rotation = 0
	player.global_position = target_port.global_position
	player.global_transform.origin = target_port.global_position
	player.call_deferred("set_movement_enabled", true)
	
	target_port.queue_free()
	queue_free()

func find_matching_port():
	var ports = get_tree().get_nodes_in_group("ports")
	for port in ports:
		if port.port_id == port_id:
			return port
	return null
