extends Node2D

var start_time: float

var recording = []

func _ready() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	$music.play()

var totalNotes = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 and event.alt_pressed:
			print(">>> RESTARTING RECORDING")
			get_tree().reload_current_scene()
		elif event.keycode == KEY_2 and event.alt_pressed:
			saveRecording()
		elif event.keycode == KEY_3 and event.alt_pressed:
			print(">>> TERMINATING RECORDING")
			get_tree().quit()
			
	if event.is_action_pressed("noteE"):
		saveNote(global.convertToKeyStr(0), float(getSub($music.get_playback_position())))
	elif event.is_action_pressed("noteR"):
		saveNote(global.convertToKeyStr(1), float(getSub($music.get_playback_position())))
	elif event.is_action_pressed("noteD"):
		saveNote(global.convertToKeyStr(2), float(getSub($music.get_playback_position())))
	elif event.is_action_pressed("noteF"):
		saveNote(global.convertToKeyStr(3), float(getSub($music.get_playback_position())))
	elif event.is_action_pressed("noteC"):
		saveNote(global.convertToKeyStr(4), float(getSub($music.get_playback_position())))
	elif event.is_action_pressed("noteV"):
		saveNote(global.convertToKeyStr(5), float(getSub($music.get_playback_position())))

func _process(_delta: float) -> void:
	$CanvasLayer/recordUI/time.text = "Time Elapsed: " +  getSub($music.get_playback_position()) + "s\nTotal Notes: " + str(totalNotes)


func saveNote(keyStr, time):
	totalNotes += 1
	recording.append({"key": keyStr, "time": time})
	get_node("CanvasLayer/recordUI/noteGroup/" + keyStr + "/count").text = str(int(get_node("CanvasLayer/recordUI/noteGroup/" + keyStr + "/count").text) + 1)
	print(keyStr + ": " + str(time) + "s")

func getSub(timeMs):
	var sub = 4
	if timeMs > 10.0:
		sub = 5
	elif timeMs > 100.0:
		sub = 6
		
	return str(timeMs).substr(0, sub)
	
func saveRecording():
	print(">>> SAVING RECORDING...")
	var file = FileAccess.open("res://levels/level1.txt", FileAccess.WRITE)
	
	file.store_line("}")
	var index = 0
	for note in recording:
		index += 1
		var line = "\"" + note["key"] + "\": " + str(note["time"]) + ","
		file.store_line(str(index) + ". " + line)
		
	file.store_line("}")
	file.close()
	print(">>> RECORDING SAVED SUCCESSFULLY")
	get_tree().quit()
