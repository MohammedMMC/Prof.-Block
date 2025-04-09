extends Label

var moves = 0
static var best_moves = {}

func _ready():
	moves = 0
	text = tr("Moves") + ": 0"

func increment():
	moves += 1
	text = tr("Moves") + ": " + str(moves)

func get_moves():
	return moves
