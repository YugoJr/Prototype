extends Node2D

func convertToKeyStr(value):
	var strings = ["keyE", "keyR", "keyD", "keyF", "keyC", "keyV", "keyU", "keyI", "keyJ", "keyK", "keyM", "key,"]
	return strings[value]
	
func convertToNameStr(value):
	var strings = ["E", "R", "D", "F", "C", "V", "U", "I", "J", "K", "M", ","]
	return strings[value]
	
func convertToInput(value):
	var strings = ["noteE", "noteR", "noteD", "noteF", "noteC", "noteV", "noteU", "noteI", "noteJ", "noteK", "noteM", "note,"]
	return strings[value]

var viewportSize
var centerViewport
var levelProgress = 0
var levelLength = 137
var playerHP = 15.0
var score = 0
var noteSpeed = 1.0
var accuracy = 0

var currentKeys = [0, 1, 6, 7]


func _ready() -> void:
	viewportSize = get_viewport_rect().size
	centerViewport = viewportSize / 2
	if get_tree().current_scene.name == "main_scene":
		get_tree().current_scene.find_child("mainUI").setKeys()

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

func resetData():
	levelProgress = 0
	playerHP = 15.0
	currentKeys = [0, 1, 6, 7]
	get_tree().current_scene.find_child("mainUI").setKeys()
