extends Node2D

var start_time: float

func _ready() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	$music.play()

var sub = 4
var totalNotes = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 and event.alt_pressed:
			get_tree().reload_current_scene()
			
	if event.is_action_pressed("e"):
		saveNote(global.key.E, $music.get_playback_position())

func _process(delta: float) -> void:
	if $music.get_playback_position() > 10.0:
		sub = 5
	elif $music.get_playback_position() > 100.0:
		sub = 6
	$CanvasLayer/recordUI/time.text = "Time Elapsed: " + str($music.get_playback_position()).substr(0, sub) + "s\nTotal Notes: " + str(totalNotes)


func saveNote(keyEnum, time):
	totalNotes += 1
