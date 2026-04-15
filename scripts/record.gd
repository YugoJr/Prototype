extends Node2D

var start_time: float
var toRecord = "level1.txt"

var leftShift = false
var rightShift = false

var recording = []
var note_map = {
		"noteE": [0, "left"],
		"noteR": [1, "left"],
		"noteD": [2, "left"],
		"noteF": [3, "left"],
		"noteC": [4, "left"],
		"noteV": [5, "left"],
		"noteU": [6, "right"],
		"noteI": [7, "right"],
		"noteJ": [8, "right"],
		"noteK": [9, "right"],
		"noteM": [10, "right"],
		"note,": [11, "right"],
	}

func _ready() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	$music.play()
	$CanvasLayer/recordUI/Label3.text = "Currently recording for file: " + toRecord
	print(">>> STARTING RECORDING")

var totalNotes = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.alt_pressed:
		match event.keycode:
			KEY_1:
				print(">>> RESTARTING RECORDING")
				get_tree().reload_current_scene()
			KEY_2:
				saveRecording()
			KEY_3:
				print(">>> TERMINATING RECORDING")
				get_tree().quit()

	var time := float(getSub($music.get_playback_position()))

	for action in note_map.keys():
		if event.is_action_pressed(action):
			var data = note_map[action]
			saveNote(global.convertToKeyStr(data[0]), time, data[1])
			break

	if event.is_action("shiftLEFT"):
		leftShift = event.is_pressed()
	if event.is_action("shiftRIGHT"):
		rightShift = event.is_pressed()

func _process(_delta: float) -> void:
	$CanvasLayer/recordUI/time.text = "Time Elapsed: " +  getSub($music.get_playback_position()) + "s\nTotal Notes: " + str(totalNotes)
	updateShift()


func saveNote(keyStr, time, section):
	totalNotes += 1
	if (leftShift and section == "left") or (rightShift and section == "right"):
		recording.append({"key": keyStr + "shift", "time": time})
	else:
		recording.append({"key": keyStr, "time": time})
	get_node("CanvasLayer/recordUI/noteGroup/" + section + "/" + keyStr + "/count").text = str(int(get_node("CanvasLayer/recordUI/noteGroup/" + section + "/" + keyStr + "/count").text) + 1)
	#print(keyStr + ": " + str(time) + "s")

func getSub(timeMs):
	var sub = 4
	if timeMs > 10.0:
		sub = 5
	if timeMs > 100.0:
		sub = 6
		
	return str(timeMs).substr(0, sub)
	
func saveRecording():
	print(">>> SAVING RECORDING...")
	
	var file = FileAccess.open("res://levels/" + toRecord, FileAccess.WRITE)
	
	var json = JSON.stringify(recording, "\t")
	file.store_string(json)
	
	file.close()
	print(">>> RECORDING SAVED SUCCESSFULLY TO: " + toRecord)
	get_tree().quit()
	
	
	
func updateShift():
	var leftPanel = $CanvasLayer/recordUI/shiftL
	var leftNotesPanel = $CanvasLayer/recordUI/noteGroup/left.get_children()
	if leftShift:
		leftPanel.self_modulate.g = 0.5
		for note in leftNotesPanel:
			note.self_modulate.g = 0.5
	else:
		leftPanel.self_modulate.g = 1
		for note in leftNotesPanel:
			note.self_modulate.g = 1
			
	var rightPanel = $CanvasLayer/recordUI/shiftR
	var rightNotesPanel = $CanvasLayer/recordUI/noteGroup/right.get_children()
	if rightShift:
		rightPanel.self_modulate.g = 0.5
		for note in rightNotesPanel:
			note.self_modulate.g = 0.5
	else:
		rightPanel.self_modulate.g = 1
		for note in rightNotesPanel:
			note.self_modulate.g = 1
