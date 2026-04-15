extends Control

var tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if get_tree().paused:
			unpause_sequence()

func unpause_sequence() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func():
		self.visible = false
		get_tree().paused = false
		tween = null
	)
	
func restartLevel():
	$"../fade".restart()


func _on_continue_pressed() -> void:
	if get_tree().paused and not tween:
		unpause_sequence()


func _on_restart_pressed() -> void:
	restartLevel()
