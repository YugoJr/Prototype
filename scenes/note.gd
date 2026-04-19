extends Node2D

var note_time = 0.0
var id = 0

const START_Y = -100.0
const HIT_Y   = 600.0
const BASE_TRAVEL_TIME = 1.5

func setup(data):
	note_time = data["time"]
	id = int(data["id"]) # Ensure ID is an integer

func _physics_process(_delta):
	var song_time = get_parent().get_song_time()
	var travel_time = BASE_TRAVEL_TIME / global.noteSpeed
	var time_until_hit = note_time - song_time

	var progress = 1.0 - (time_until_hit / travel_time)

	if progress <= 0.0:
		position.y = START_Y
		return

	progress = clamp(progress, 0.0, 1.1) # Allow slightly past 1.0
	position.y = lerp(START_Y, HIT_Y, progress)

	# Cleanup if missed and off-screen
	if time_until_hit < -0.5:
		queue_free()
