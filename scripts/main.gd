extends Control

func _ready() -> void:
	var timer = Timer.new()
	timer.timeout.connect(func(): _roll_sprite($RollingSprite))
	timer.wait_time = 60.0
	timer.autostart = true
	add_child(timer)

func _roll_sprite(sprite: Sprite2D) -> void:
	var width = get_viewport_rect().size.x
	var sprite_size = sprite.texture.get_width() * sprite.scale.x
	
	sprite.position.x = -sprite_size
	sprite.rotation = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "position:x", width + sprite_size, 8.0)
	tween.tween_property(sprite, "rotation", ((width + 2*sprite_size) / (sprite_size * PI)) * 2 * PI, 8.0)

func _on_play_button_pressed() -> void:
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/levels.tscn")

func _on_settings_button_pressed() -> void:
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
