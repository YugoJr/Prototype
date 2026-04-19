extends Control
var visual_accuracy: float = 100.0

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	$score/progress.value = clamp((global.levelProgress / global.levelLength) * 100, 0, 100)
	$hpBar.value = global.playerHP
	var currentScore = int(round(lerp(int($score.text), global.score, 0.75)))
	$score.text = "%010d" % currentScore
	global.accuracy = (global.accuracyScore / global.resolvedNotes) * 100.0
	visual_accuracy = lerp(visual_accuracy, global.accuracy, 0.75)
	$accuracy.text = "%.2f%%" % visual_accuracy
	
func setKeys():
	var children = $playerLines.get_children()
	for i in children.size():
		var ui = children[i]
		var keyValue = global.currentKeys[i]
		ui.get_node("circle/button").text = global.convertToNameStr(keyValue)
		
func register(line):
	var children = $playerLines.get_children()
	for i in children.size():
		var ui = children[i]
		if line == i + 1:
			flash(ui)
			
# Keep track of tweens so we can stop them if the player spams the key
var tweens = {} 

func flash(ui):
	var bar = ui.get_node("bar")
	if tweens.has(bar) and tweens[bar].is_valid():
		tweens[bar].kill()
	var tween = create_tween()
	tweens[bar] = tween
	bar.modulate = Color(5.0, 5.0, 5.0, 1.0)
	tween.tween_property(bar, "modulate", Color(1, 1, 1, 1), 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func getSub(accu):
	var sub = 4
	if accu > 10.0:
		sub = 5
	if accu > 100.0:
		sub = 6
		
	return str(accu).substr(0, sub)
