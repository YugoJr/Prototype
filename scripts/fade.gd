extends Control

var tween: Tween

func _ready() -> void:
	# 1. Start invisible so there is no flash
	# If you want it to fade OUT on start, keep these, 
	# but ensure the Inspector value for alpha is also 0.
	if self.modulate.a > 0: 
		start_fade_out()

func start_fade_out() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): self.visible = false)

func restart():
	self.visible = true
	# Ensure it's transparent before we start the "fade to white"
	self.modulate.a = 0 
	
	if tween: tween.kill()
	tween = create_tween()
	
	# Fade TO white
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	
	# Reload after the fade is done
	tween.finished.connect(func():
		get_tree().reload_current_scene()
	)
