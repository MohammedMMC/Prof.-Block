extends StaticBody2D

var has_player_inside = false
@export var fire_texture: Texture2D:
	set(value):
		fire_texture = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value

func _ready():
	if fire_texture:
		$Sprite2D.texture = fire_texture
	add_to_group("fires")
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
	if has_player_inside: return

	var fire_color = extract_color_from_path(fire_texture.resource_path)
	body.change_texture("res://images/players/%s.png" % fire_color)
	
	has_player_inside = true
		
	self.queue_free()
	
func extract_color_from_path(path: String) -> String:
	var filename = path.get_file()
	if filename.begins_with("fire-"):
		return filename.split(".")[0].split("-")[1]
	else:
		return filename.split(".")[0]

func is_player_inside(): return has_player_inside
