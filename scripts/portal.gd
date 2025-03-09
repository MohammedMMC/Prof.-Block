extends StaticBody2D

var has_player_inside = false
var overlapping_players = []
@export var original_player_texture = "res://images/players/blue.png"

func _ready():
	add_to_group("portals")
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	collision.shape = $CollisionShape2D.shape.duplicate()
	area.add_child(collision)
	area.connect("body_entered", _on_body_entered)
	add_child(area)

func _on_body_entered(body):
	if not body.is_in_group("players") or overlapping_players.has(body): return
	overlapping_players.append(body)
	has_player_inside = true
	$Sprite2D.visible = false
	if body.has_method("change_sprite_texture"):
		var tilemap = get_node("/root/Node2D/TileMap")
		if tilemap: body.queue_tileset_sprite_change(tilemap)
		body.reset_rotation()
		body.set_movement_enabled(false)

func is_player_inside(): return has_player_inside
