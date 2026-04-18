extends Node2D

var tween: Tween
var levelData = []
var noteScene = preload("res://scenes/note.tscn")

# 🎯 Timing windows (in seconds)
const PERFECT_WINDOW = 0.05
const GREAT_WINDOW   = 0.10
const GOOD_WINDOW    = 0.18
const MISS_WINDOW    = 0.25

func _ready():
    levelData = loadChart("res://levels/level1.txt")
    
    for note in levelData:
        note["resolved"] = false
        
        # Spawn timing
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

# =========================
# 🎮 INPUT
# =========================
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

# =========================
# 🎯 TIMING CHECK
# =========================
func check_timing(_lane_index: int): # lane no longer matters
    var current_song_time = get_song_time()
    
    var closest_note = null
    var smallest_diff = INF

    # 🔥 Ignore lane, find ANY closest note
    for note in levelData:
        if note["resolved"] == false:
            var diff = abs(current_song_time - note["time"])

            if diff < smallest_diff:
                smallest_diff = diff
                closest_note = note

    if closest_note and smallest_diff <= MISS_WINDOW:
        judge_hit(smallest_diff)
        closest_note["resolved"] = true
    else:
        print("MISS (ghost press)")

# =========================
# 🏆 JUDGEMENT
# =========================
func judge_hit(diff: float):
    if diff <= PERFECT_WINDOW:
        print("PERFECT! (", diff, "s)")
    elif diff <= GREAT_WINDOW:
        print("GREAT! (", diff, "s)")
    elif diff <= GOOD_WINDOW:
        print("GOOD (", diff, "s)")
    else:
        print("BAD (", diff, "s)")

# =========================
# ⏱ SONG TIME HELPER
# =========================
func get_song_time() -> float:
    return $music.get_playback_position() + AudioServer.get_time_since_last_mix()

# =========================
# 🔥 AUTO MISS SYSTEM
# =========================
func _physics_process(_delta: float) -> void:
    var current_song_time = get_song_time()
    global.levelProgress = current_song_time
    global.playerHP += 0.05

    for note in levelData:
        if note["resolved"] == false:
            var diff = current_song_time - note["time"]

            if diff > MISS_WINDOW:
                note["resolved"] = true
                print("MISS (late)")

# =========================
# 📂 LOAD CHART
# =========================
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

# =========================
# ⚡ SPEED CONTROL
# =========================
func changeSpeed(speed):
    if global.levelProgress > 5:
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
    tween.tween_property(label, "self_modulate:a", 0.0, 0.3)\
        .set_trans(Tween.TRANS_SINE)\
        .set_ease(Tween.EASE_IN)
