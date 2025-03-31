extends StaticBody2D

@export var port_texture: Texture2D:
	set(value):
		port_texture = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value

@export var port_id: int:
	set(value): port_id = value

func _ready():
	if port_texture and has_node("Sprite2D"):
		$Sprite2D.texture = port_texture
	add_to_group("ports")
