extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	var music_stream = load("res://audio/bg.wav")
	
	music_player.stream = music_stream
	music_player.volume_db = -2
	music_player.bus = "Music"
	music_player.autoplay = true
	music_player.set_stream_paused(false)
	music_player.finished.connect(music_player.play)
	
	add_child(music_player)
	music_player.play()
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

func stop_music():
	music_player.stop()

func play_music():
	if !music_player.playing:
		music_player.play()

func play_move_sound():
	var move_sound = load("res://audio/plop.wav")
	sfx_player.stream = move_sound
	sfx_player.play()
