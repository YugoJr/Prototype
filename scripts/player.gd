extends Area2D

func _physics_process(_delta: float) -> void:
	var mouseX = get_global_mouse_position().x
	var mouseRatio = clamp(mouseX / global.viewportSize.x, 0.0, 1.0)
	var boxLeft = global.centerViewport.x - 80
	var boxRight = global.centerViewport.x + 80
	var targetX = lerp(boxLeft, boxRight, mouseRatio)
	position.x = lerp(position.x, targetX, 0.9)
	#rotation = (position.x - global.centerViewport.x) / 360
