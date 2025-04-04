extends Control

@export var help_id: int:
	set(value): help_id = value

@onready var helpers = [$Help1, $Help2, $Help3, $Help4]

func _ready() -> void:
	for helper in helpers:
		helper.hide()

	if help_id > 0 and help_id <= helpers.size():
		self.show()
		helpers[help_id - 1].show()
	

func _on_back_button_pressed() -> void:
	self.hide()
	self.queue_free()
