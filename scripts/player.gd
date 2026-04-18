extends Area2D

func _physics_process(delta: float) -> void:
	var viewport_width = global.viewportSize.x
	var mouse_x = get_viewport().get_mouse_position().x
	var screen_margin = 300.0 
	var mouse_ratio = (mouse_x - screen_margin) / (viewport_width - (screen_margin * 2.0))
	mouse_ratio = clamp(mouse_ratio, 0.0, 1.0)
	var box_left = global.centerViewport.x - 120
	var box_right = global.centerViewport.x + 120
	var target_x = lerp(box_left, box_right, mouse_ratio)
	position.x = lerp(position.x, target_x, 15.0 * delta)
