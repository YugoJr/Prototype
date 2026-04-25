extends Control

var resolutions = [
	Vector2i(640, 360),
	Vector2i(854, 480),
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

var limitFPS = [-1, 5, 10, 20, 30, 60, 90, 120, 180, 240, 360]

@onready var windows_button = get_node("bg/optionScroll/Vbox/video/option1/OptionButton")
@onready var resolution_button = get_node("bg/optionScroll/Vbox/video/option2/OptionButton")
@onready var limit_button = get_node("bg/optionScroll/Vbox/video/option3/OptionButton")
@onready var vsync_button = get_node("bg/optionScroll/Vbox/video/option4/OptionButton")

func _ready():
	# Setup all menus
	setup_windows_menu()
	setup_resolution_menu()
	setup_fps_menu()
	setup_vsync_menu()
	
	# Connect all signals
	windows_button.item_selected.connect(_on_window_mode_selected)
	resolution_button.item_selected.connect(_on_resolution_selected)
	limit_button.item_selected.connect(_on_fps_limit_selected)
	vsync_button.item_selected.connect(_on_vsync_selected)

# --- SETUP FUNCTIONS ---

func setup_fps_menu():
	limit_button.clear()
	for i in range(limitFPS.size()):
		var val = limitFPS[i]
		var label = "Unlimited" if val == -1 else str(val) + " FPS"
		limit_button.add_item(label)
		limit_button.set_item_metadata(i, val)

func setup_vsync_menu():
	vsync_button.clear()
	vsync_button.add_item("Disabled")
	vsync_button.add_item("Enabled")

# --- SIGNAL FUNCTIONS ---

func _on_fps_limit_selected(index: int):
	var val = limit_button.get_item_metadata(index)
	if val == -1:
		Engine.max_fps = 0 # Godot uses 0 for unlimited
	else:
		Engine.max_fps = val

func _on_vsync_selected(index: int):
	if index == 0:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

# --- YOUR EXISTING LOGIC (Modified for completeness) ---

func setup_windows_menu():
	windows_button.clear()
	windows_button.add_item("Windowed", 0)
	windows_button.add_item("Borderless", 1)
	windows_button.add_item("Fullscreen", 2)

func setup_resolution_menu():
	resolution_button.clear()
	var screen_id = get_window().current_screen
	var screen_size = DisplayServer.screen_get_size(screen_id)
	
	var item_index = 0
	for res in resolutions:
		if res.x <= screen_size.x and res.y <= screen_size.y:
			var label = str(res.x) + " x " + str(res.y)
			if res == screen_size: label += " (Native)"
			resolution_button.add_item(label)
			resolution_button.set_item_metadata(item_index, res)
			item_index += 1

func _on_window_mode_selected(index: int):
	var window = get_window()
	match index:
		0: # Windowed
			window.mode = Window.MODE_WINDOWED
			window.borderless = false
			resolution_button.disabled = false
			_on_resolution_selected(resolution_button.selected)
		1: # Borderless
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
			window.borderless = true
			resolution_button.disabled = true
			force_native_resolution()
		2: # Fullscreen
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
			window.borderless = false
			resolution_button.disabled = true
			force_native_resolution()

func force_native_resolution():
	var screen_id = get_window().current_screen
	var screen_size = DisplayServer.screen_get_size(screen_id)
	get_window().size = screen_size
	for i in range(resolution_button.item_count):
		if resolution_button.get_item_metadata(i) == screen_size:
			resolution_button.selected = i
			break

func _on_resolution_selected(index: int):
	if resolution_button.disabled: return
	var size = resolution_button.get_item_metadata(index)
	if size is Vector2i:
		var window = get_window()
		window.mode = Window.MODE_WINDOWED
		window.size = size
		var screen_id = window.current_screen
		var screen_rect = DisplayServer.screen_get_usable_rect(screen_id)
		window.position = screen_rect.position + (screen_rect.size / 2) - (size / 2)


func _on_button_pressed() -> void:
	$".".visible = false
