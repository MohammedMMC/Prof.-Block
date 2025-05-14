extends Control

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("intro")
	await animation_player.animation_finished
	TransitionScenes.start()
	await TransitionScenes.transition_scene_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
