extends Node

var level_progress = {}
const SAVE_FILE_PATH = "user://game_progress.save"

func _ready():
	load_progress()
	unlock_first_level()

func unlock_first_level():
	if not level_progress.has(1):
		level_progress[1] = {"completed": false, "stars": 0, "accessible": true}
		save_progress()

func complete_level(level_number: int, stars: int):
	if not level_progress.has(level_number) or level_progress[level_number].get("stars", 0) < stars:
		level_progress[level_number] = {"completed": true, "stars": stars}
		if not level_progress.has(level_number + 1):
			level_progress[level_number + 1] = {"completed": false, "stars": 0, "accessible": true}
		
		save_progress()

func is_level_completed(level_number: int) -> bool:
	return level_progress.has(level_number) and level_progress[level_number].get("completed", false)

func get_level_stars(level_number: int) -> int:
	return level_progress.get(level_number, {}).get("stars", 0)

func save_progress():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(level_progress)
		file.close()

func load_progress():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			level_progress = file.get_var()
			file.close()