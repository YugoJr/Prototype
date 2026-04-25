extends Control

var tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if get_tree().paused:
			get_tree().current_scene.get_node("canvasNodes/canvasOption/option").visible = false
			unpause_sequence()
	if event.is_action_pressed("options"):
			openOptions()
	if event.is_action_pressed("restart"):
			restartLevel()

func unpause_sequence() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func():
		self.visible = false
		get_tree().paused = false
		get_tree().current_scene.get_node("canvasNodes/canvasOption/option").visible = false
		tween = null
	)
	
func restartLevel():
	get_tree().current_scene.get_node("canvasNodes/canvasOption/option").visible = false
	$"../fade".restart()


func _on_continue_pressed() -> void:
	if get_tree().paused and not tween:
		unpause_sequence()


func openOptions():
	if not get_tree().paused:
		return
	get_tree().current_scene.get_node("canvasNodes/canvasOption/option").visible = true

func _on_restart_pressed() -> void:
	restartLevel()


func _on_option_pressed() -> void:
	openOptions()
