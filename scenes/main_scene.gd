extends Node2D

var tween: Tween
var levelData = []
var noteScene = preload("res://scenes/note.tscn")

func _ready():
	levelData = loadChart("res://levels/level1.txt")
	
	for note in levelData:
		note["resolved"] = false
		# Calculate when to spawn (Note time minus the travel time)
		var spawn_delay = note["time"] - global.noteSpeed
		
		if spawn_delay > 0:
			schedule_note(spawn_delay, note)
		else:
			spawn_actual_note(note)

func schedule_note(delay, data):
	await get_tree().create_timer(delay).timeout
	spawn_actual_note(data)

func spawn_actual_note(data):
	var clone = noteScene.instantiate()
	add_child(clone)
	clone.position.x = 377 + (data["pos"] * 80)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		$canvasNodes/canvasPause/pause.visible = true
		tween.tween_property($canvasNodes/canvasPause/pause, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
		get_tree().paused = true
		
	if event.is_action_pressed("speedUp"):
		changeSpeed(-0.1)
		
	if event.is_action_pressed("speedDown"):
		changeSpeed(0.1)
		
	var line = 0
	for keys in global.currentKeys:
		line += 1
		var action = global.convertToInput(keys)
		
		if event.is_action_pressed(action):
			$canvasNodes/canvasMain/mainUI.register(line)
			check_timing(line - 1)

func check_timing(lane_index: int):
	var current_song_time = $music.get_playback_position() + AudioServer.get_time_since_last_mix()
	var closest_node_data = null
	var smallest_diff = INF
	
	# 1. Look for the closest unresolved note in this lane
	for note in levelData:
		if note["resolved"] == false and note["pos"] == lane_index:
			var diff = abs(current_song_time - note["time"])
			
			if diff < smallest_diff and diff < 0.7:
				smallest_diff = diff
				closest_node_data = note

	# 2. Check result AFTER the loop finishes
	if closest_node_data:
		judge_hit(smallest_diff)
		closest_node_data["resolved"] = true 
	else:
		print("Ghost press - No note nearby!")

func judge_hit(diff: float):
	if diff < 0.2:
		print("PERFECT! (", diff, "s)")
	elif diff < 0.5:
		print("GREAT! (", diff, "s)")
	else:
		print("GOOD (", diff, "s)")

func _physics_process(_delta: float) -> void:
	global.levelProgress = $music.get_playback_position() + AudioServer.get_time_since_last_mix()
	global.playerHP += 0.05

func loadChart(path: String):
	if not FileAccess.file_exists(path):
		print("Error: File not found!")
		return []

	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
		return []

func changeSpeed(speed):
	if global.levelProgress > 3:
		return
		
	global.noteSpeed = clamp(global.noteSpeed + speed, 0.1, 2)
	var label = $canvasNodes/canvasMain/mainUI/speedChange
	label.text = "Changed speed to x" + str(global.noteSpeed)
	
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	label.self_modulate.a = 1.0
	
	tween.tween_interval(1.0)
	tween.tween_property(label, "self_modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
