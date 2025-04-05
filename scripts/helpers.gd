extends Control

@export var help_id: int:
	set(value): help_id = value

@onready var helpers = [$Help1, $Help2, $Help3, $Help4]

@onready var animations_player = $AnimationPlayer

func _ready() -> void:
	for helper in helpers:
		helper.hide()

	if help_id > 0 and help_id <= helpers.size():
		self.show()
		helpers[help_id - 1].show()
		
	animations_player.play("popup")

func _on_back_button_pressed() -> void:
	animations_player.play_backwards("popup")
	await animations_player.animation_finished
	self.hide()
	self.queue_free()
