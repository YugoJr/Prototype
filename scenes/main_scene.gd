extends Node2D

var tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($canvasNodes/canvasPause/pause, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
		get_tree().paused = true
