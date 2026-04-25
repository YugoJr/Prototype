extends Node2D

var tween: Tween
var levelData = []
var noteScene = preload("res://scenes/note.tscn")
var judgeTextScene = preload("res://scenes/judge_text.tscn")

const PERFECT_FRAME_WINDOW    = 0.003 # 5ms (Hardcore frame-perfect)
const CRITICAL_PERFECT_WINDOW = 0.025 # 25ms (The "Elite" zone)
const PERFECT_WINDOW          = 0.050 # 50ms (The "Standard" zone)
const GREAT_WINDOW            = 0.100 # 100ms
const GOOD_WINDOW             = 0.150 # 150ms
const MISS_WINDOW    = 0.3

const NOTE_TRAVEL_TIME = 1.5

func _ready():
	print(str(DisplayServer.screen_get_size()))
	levelData = loadChart("res://levels/level1.txt")
	for note in levelData:
		note["resolved"] = false
		var travel_time = NOTE_TRAVEL_TIME / global.noteSpeed
		var spawn_delay = note["time"] - travel_time

		spawn_actual_note(note)

func schedule_note(delay, data):
	await get_tree().create_timer(delay).timeout
	spawn_actual_note(data)

func spawn_actual_note(data):
	var clone = noteScene.instantiate()
	add_child(clone)
	clone.position.x = global.convertLaneToPos(data["pos"])  # Adjusted for pos 1-4
	clone.setup(data)
	clone.add_to_group("active_notes") # Faster searching

var speed_scroll_timer = 0.0
var is_holding_speed = 0 # -1 for down, 1 for up, 0 for none

func _input(event: InputEvent) -> void:
	# --- 1. HANDLE SPEED INPUT (Independent of lanes) ---
	if event.is_action_pressed("speedUp"):
		changeSpeed(-0.1)
		is_holding_speed = -1
	elif event.is_action_released("speedUp"):
		is_holding_speed = 0
		speed_scroll_timer = 0.0

	if event.is_action_pressed("speedDown"):
		changeSpeed(0.1)
		is_holding_speed = 1
	elif event.is_action_released("speedDown"):
		is_holding_speed = 0
		speed_scroll_timer = 0.0

	# --- 2. HANDLE ESCAPE ---
	if event.is_action_pressed("escape"):
		handle_pause()

	# --- 3. HANDLE NOTE LANES (The loop) ---
	var lane_counter = 0
	for key_index in global.currentKeys:
		lane_counter += 1
		var action = global.convertToInput(key_index)
		
		if event.is_action_pressed(action):
			$canvasNodes/canvasMain/mainUI.register(lane_counter)
			check_timing(lane_counter)

func _process(delta: float) -> void:
	if is_holding_speed != 0:
		speed_scroll_timer += delta
		# Wait 0.3s (initial delay) before rapid-firing every 0.05s
		if speed_scroll_timer > 0.3:
			changeSpeed(0.1 * is_holding_speed)
			# Reset timer slightly so it triggers again quickly
			speed_scroll_timer = 0.25
		

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
		judge_hit(smallest_diff, lane_pressed)
		closest_note["resolved"] = true
		
		# Search the group instead of all children
		for note_node in get_tree().get_nodes_in_group("active_notes"):
			if int(note_node.id) == int(closest_note["id"]):
				#print("Destroying Note ID: ", closest_note["id"])
				note_node.queue_free()
				break

func judge_hit(diff: float, pos):
	var judgement: String = ""
	var base_points: int = 0
	
	# 1. Determine Judgement and Base Points
	if diff <= PERFECT_FRAME_WINDOW:
		judgement = "[rainbow freq=1.5 sat=.8 val=1]FRAME PERFECT[/rainbow]"
		base_points = 5000
		global.accuracyScore += 1.0
		global.combo += 1
		global.damageCombo = 0.8
	elif diff <= CRITICAL_PERFECT_WINDOW:
		judgement = "[rainbow freq=1.5 sat=.8 val=1]CRITICAL PERFECT[/rainbow]"
		base_points = 2000
		global.accuracyScore += 1.0
		global.combo += 1
		global.damageCombo -= 0.6
	elif diff <= PERFECT_WINDOW:
		judgement = "PERFECT"
		base_points = 1000
		global.accuracyScore += 1.0
		global.combo += 1
		global.damageCombo -= 0.1
	elif diff <= GREAT_WINDOW:
		judgement = "GREAT"
		base_points = 500
		global.accuracyScore += 0.8
		global.combo += 1
		global.damageCombo -= 0.03
	elif diff <= GOOD_WINDOW:
		judgement = "GOOD"
		base_points = 200
		global.accuracyScore += 0.5
		global.combo += 1
	else:
		judgement = "BAD"
		base_points = 50
		global.combo = 0 # Break combo on BAD
		global.damagePlayer()
	
	# 2. Calculate Score with Multiplier
	# (Combo bonus: every 10 combo adds 10% to score, capped at 2x)
	$mainCamera.play_note_bop()
	var multiplier = clamp(1.0 + (global.combo / 50.0), 1.0, 2.5)
	global.score += int(base_points * multiplier)
	global.playerHP += base_points / 750
 

	# 4. Spawn Visuals
	var textClone = judgeTextScene.instantiate()
	add_child(textClone)
	textClone.position.x = global.convertLaneToPos(pos)
	textClone.position.y = 500
	textClone.get_node("Label").text = judgement
	
	# Optional: Color the text
	if judgement == "PERFECT": textClone.modulate = Color.GOLD
	elif judgement == "GREAT": textClone.modulate = Color.CYAN
	elif judgement == "BAD": textClone.modulate = Color.RED

func get_song_time() -> float:
	return $music.get_playback_position() + AudioServer.get_time_since_last_mix()

func _physics_process(_delta: float) -> void:
	global.playerHP = clamp(global.playerHP, 0.0, 100.0)
	global.damageCombo = clamp(global.damageCombo, 0.8, 5.5)
	var current_song_time = get_song_time()
	global.levelProgress = current_song_time
	
	for note in levelData:
		if not note["resolved"] and (current_song_time - note["time"]) > MISS_WINDOW:
			note["resolved"] = true
			global.resolvedNotes += 1 # Counts toward accuracy denominator
			global.combo = 0           # Combo breaks on miss
			
			# Recalculate accuracy because resolvedNotes changed
			var textClone = judgeTextScene.instantiate()
			add_child(textClone)
			textClone.position.x = global.convertLaneToPos(note["pos"])
			textClone.position.y = 500
			textClone.get_node("Label").text = "MISS"
			textClone.modulate = Color.RED
			global.damagePlayer()

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
	#if global.levelProgress > 5: return
	global.noteSpeed = clamp(global.noteSpeed + speed, 0.1, 3.5)
	var label = $canvasNodes/canvasMain/mainUI/speedChange
	label.text = "Speed: x" + str(global.noteSpeed)
	if tween and tween.is_valid(): tween.kill()
	tween = create_tween()
	label.self_modulate.a = 1.0
	tween.tween_interval(1.0)
	tween.tween_property(label, "self_modulate:a", 0.0, 0.3)
