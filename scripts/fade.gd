extends Control

var tween: Tween

func _ready() -> void:
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): self.visible = false)

func restart():
	self.visible = true
	self.modulate.a = 0 
	
	if tween: tween.kill()
	tween = create_tween()
	
	# Fade TO white
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	# Reload after the fade is done
	tween.finished.connect(func():
		global.resetData()
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
