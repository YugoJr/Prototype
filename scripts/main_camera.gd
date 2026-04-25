extends Camera2D

## Configuration
@export var bop_intensity: float = 1.005  # 1.0 is normal, 1.2 is 20% zoom out
@export var bop_duration: float = 0.03   # How fast the initial "pop" is
@export var return_duration: float = 0.07 # How fast it returns to normal
@export var base_zoom: Vector2 = Vector2.ONE

var tween: Tween

func _ready() -> void:
	position = global.centerViewport

## This is the function you call from your Music/Input manager
func play_note_bop():
	# Kill previous tween to reset the animation if notes are hit fast
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	# 1. Rapid Zoom Out (The "Bop")
	# We use TRANS_SINE for a smooth but quick hit
	tween.tween_property(self, "zoom", base_zoom * bop_intensity, bop_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	# 2. Return to Normal
	# We use TRANS_BACK to give it a tiny bit of "bounce" at the end
	tween.tween_property(self, "zoom", base_zoom, return_duration) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)

## EXAMPLE USAGE (For testing purposes)
func _input(event):
	if event.is_action_pressed("ui_accept"): # Press Space/Enter to test
		play_note_bop()
