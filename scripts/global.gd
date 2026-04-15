extends Node2D

func convertToKeyStr(value):
	var strings = ["keyE", "keyR", "keyD", "keyF", "keyC", "keyV", "keyU", "keyI", "keyJ", "keyK", "keyM", "key,"]
	return strings[value]

var viewportSize
var centerViewport


func _ready() -> void:
	viewportSize = get_viewport_rect().size
	centerViewport = viewportSize / 2
