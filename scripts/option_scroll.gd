extends ScrollContainer

@export var power = 1500.0   # How much speed each "click" of the wheel adds
@export var friction = 0.9    # Higher = slides longer (0.95 is very slippery, 0.8 is heavy)
@export var stop_threshold = 0.1

var velocity = 0.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				velocity -= power
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				velocity += power

func _process(delta: float) -> void:
	if abs(velocity) > stop_threshold:
		# 1. Apply the velocity to the scroll position
		# We multiply by delta so it's smooth regardless of FPS
		scroll_vertical += int(velocity * delta)
		
		# 2. Apply friction (slowly reduce velocity)
		velocity *= friction
		
		# 3. Bounce/Clamp at the edges
		var max_scroll = get_v_scroll_bar().max_value - size.y
		if scroll_vertical <= 0 or scroll_vertical >= max_scroll:
			velocity = 0 # Hard stop at the top/bottom
	else:
		velocity = 0
