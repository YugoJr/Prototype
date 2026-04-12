extends ColorRect


func _physics_process(delta: float) -> void:
	position.x = clamp(lerp(position.x, get_global_mouse_position().x, 0.1),400, 800)
