extends Node2D

func convertToKeyStr(value):
	var strings = ["keyE", "keyR", "keyD", "keyF", "keyC", "keyV", "keyU", "keyI", "keyJ", "keyK", "keyM", "key,"]
	return strings[value]

var viewportSize
var centerViewport


func _ready() -> void:
	viewportSize = get_viewport_rect().size
	centerViewport = viewportSize / 2

var tween: Tween

func fade_and_pause(target_node: CanvasItem, to_alpha: float, duration: float) -> void:
	if tween:
		tween.kill()
		if to_alpha > 0:
			target_node.visible = true
			target_node.process_mode = Node.PROCESS_MODE_ALWAYS

		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

		tween.tween_property(target_node, "modulate:a", to_alpha, duration).set_trans(Tween.TRANS_SINE)
