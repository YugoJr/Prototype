extends Node2D # Or Label/Control

func _ready() -> void:
	await get_tree().process_frame
	var tween = create_tween()
	
	# Move up 50 pixels over 0.5 seconds
	# Changed Tween.TRANS_OUT to TRANS_SINE or TRANS_QUART
	# Changed Tween.EASE_CUBIC to EASE_OUT
	tween.tween_property(self, "position:y", position.y - 50, 0.5).set_trans(3).set_ease(1)
	
	# Fade out at the same time
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	
	# Kill the node when done
	tween.finished.connect(queue_free)
