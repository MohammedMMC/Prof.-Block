extends Label

var moves = 0
static var best_moves = {}

func _ready():
	moves = 0
	text = "Moves: 0"

func increment():
	moves += 1
	text = "Moves: " + str(moves)

func get_moves():
	return moves
