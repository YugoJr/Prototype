extends Node2D

var tween: Tween

var levelData = []

var noteScene = preload("res://scenes/note.tscn")

func _ready():
	levelData = loadChart("res://levels/level1.txt")
	
	for note in levelData:
		# Calculate when to spawn (Note time minus the 3-second travel time)
		var spawn_delay = note["time"] - global.noteSpeed
		
		# If the delay is positive, schedule the spawn
		if spawn_delay > 0:
			schedule_note(spawn_delay, note)
		else:
			# If the note happens instantly, spawn it now
			spawn_actual_note(note)

func schedule_note(delay, data):
	await get_tree().create_timer(delay).timeout
	spawn_actual_note(data)

func spawn_actual_note(data):
	var clone = noteScene.instantiate()
	add_child(clone)
	clone.position.x = 377 + (data["pos"] * 80)
	# Set position/lane here
		

func _input(event: InputEvent) -> void:
	var line = 0
	if event.is_action_pressed("escape"):
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		$canvasNodes/canvasPause/pause.visible = true
		tween.tween_property($canvasNodes/canvasPause/pause, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
		get_tree().paused = true
		
	for keys in global.currentKeys:
		line += 1
		var action = global.convertToInput(keys)
		if event.is_action_pressed(action):
			$canvasNodes/canvasMain/mainUI.register(line)

func _physics_process(delta: float) -> void:
	global.levelProgress = $music.get_playback_position() + AudioServer.get_time_since_last_mix()
	
	global.playerHP += 0.05


func loadChart(path: String):
	if not FileAccess.file_exists(path):
		print("Error: File not found!")
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.data
		return data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return null
