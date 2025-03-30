extends Node

signal transition_scene_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	color_rect.z_index = 1000
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func start() -> void:
	color_rect.visible = true
	animation_player.play("fade_in")

func _on_animation_finished(animtaion_name) -> void:
	if animtaion_name == "fade_in":
		transition_scene_finished.emit()
		animation_player.play("fade_out")
	elif animtaion_name == "fade_out":
		color_rect.visible = false
