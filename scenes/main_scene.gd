extends Node2D

var tween: Tween

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
