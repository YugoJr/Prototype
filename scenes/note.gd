extends Node2D

func _ready() -> void:
	position.y = -100.0
	var tween = create_tween()
	tween.tween_property(self, "position:y", 584.0, global.noteSpeed).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(queue_free)
