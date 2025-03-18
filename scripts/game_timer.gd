extends Label

var time_elapsed: float = 0
var running: bool = true
var game_manager: Node

func _ready():
	game_manager = get_tree().get_first_node_in_group("game_manager")
	update_display()

func _process(delta):
	if running:
		time_elapsed += delta
		update_display()

func update_display():
	var minutes = floor(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	text = "%02d:%02d" % [minutes, seconds]

func pause():
	running = false

func resume():
	running = true
	
func reset():
	time_elapsed = 0
	update_display()
