extends Node2D

var tween: Tween
var levelData = []
var noteScene = preload("res://scenes/note.tscn")
var judgeTextScene = preload("res://scenes/judge_text.tscn")

const PERFECT_WINDOW = 0.05
const GREAT_WINDOW   = 0.10
const GOOD_WINDOW    = 0.18
const MISS_WINDOW    = 0.3 # Tightened from 0.9 for better feel

const NOTE_TRAVEL_TIME = 1.5

func _ready():
	levelData = loadChart("res://levels/level1.txt")
	for note in levelData:
		note["resolved"] = false
		var travel_time = NOTE_TRAVEL_TIME / global.noteSpeed
		var spawn_delay = note["time"] - travel_time
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
	clone.position.x = 377 + (data["pos"] * 80)  # Adjusted for pos 1-4
	clone.setup(data)
	clone.add_to_group("active_notes") # Faster searching

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		handle_pause()
		
	if event.is_action_pressed("speedUp"): changeSpeed(-0.1)
	if event.is_action_pressed("speedDown"): changeSpeed(0.1)
		
	var lane_counter = 0
	for key_index in global.currentKeys:
		lane_counter += 1 # This corresponds to "pos" 1, 2, 3, 4
		var action = global.convertToInput(key_index)
		
		if event.is_action_pressed(action):
			$canvasNodes/canvasMain/mainUI.register(lane_counter)
			check_timing(lane_counter)

func check_timing(lane_pressed: int):
	var current_song_time = get_song_time()
	var closest_note = null
	var smallest_diff = INF

	# 1. Find the closest unresolved note in THIS specific lane
	for note in levelData:
		if not note["resolved"] and note["pos"] == lane_pressed:
			var diff = abs(current_song_time - note["time"])
			if diff < smallest_diff:
				smallest_diff = diff
				closest_note = note

	# 2. If found within window, judge and destroy visual
	if closest_note and smallest_diff <= MISS_WINDOW:
		global.resolvedNotes += 1
		judge_hit(smallest_diff)
		closest_note["resolved"] = true
		
		# Search the group instead of all children
		for note_node in get_tree().get_nodes_in_group("active_notes"):
			if int(note_node.id) == int(closest_note["id"]):
				print("Destroying Note ID: ", closest_note["id"])
				note_node.queue_free()
				break
	else:
		print("Ghost press in lane: ", lane_pressed)

func judge_hit(diff: float):
	var judgement: String = ""
	if diff <= PERFECT_WINDOW:
		judgement = "PERFECT"
		global.accuracyScore += 1.0
	elif diff <= GREAT_WINDOW:
		judgement = "GREAT"
		global.accuracyScore += 0.8
	elif diff <= GOOD_WINDOW:
		judgement = "GOOD"
		global.accuracyScore += 0.5
	else:
		judgement = "BAD"
	var textClone = judgeTextScene.instantiate()
	add_child(textClone)
	textClone.position = global.centerViewport
	textClone.get_node("Label").text = judgement

func get_song_time() -> float:
	return $music.get_playback_position() + AudioServer.get_time_since_last_mix()

func _physics_process(_delta: float) -> void:
	var current_song_time = get_song_time()
	global.levelProgress = current_song_time
	
	for note in levelData:
		if not note["resolved"] and (current_song_time - note["time"]) > MISS_WINDOW:
			note["resolved"] = true
			global.resolvedNotes += 1
			print("AUTO MISS (ID: ", note["id"], ")")

func handle_pause():
	if tween: tween.kill()
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	$canvasNodes/canvasPause/pause.visible = true
	tween.tween_property($canvasNodes/canvasPause/pause, "modulate:a", 1.0, 0.3)
	get_tree().paused = true

func loadChart(path: String):
	if not FileAccess.file_exists(path): return []
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data if json.data else []

func changeSpeed(speed):
	if global.levelProgress > 5: return
	global.noteSpeed = clamp(global.noteSpeed + speed, 0.1, 2.5)
	var label = $canvasNodes/canvasMain/mainUI/speedChange
	label.text = "Speed: x" + str(global.noteSpeed)
	if tween and tween.is_valid(): tween.kill()
	tween = create_tween()
	label.self_modulate.a = 1.0
	tween.tween_interval(1.0)
	tween.tween_property(label, "self_modulate:a", 0.0, 0.3)
