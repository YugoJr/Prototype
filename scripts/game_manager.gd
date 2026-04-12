extends Node


@onready var noteClone = preload("res://scenes/nodes/note.tscn")
var levelData = {
	
}

func _ready() -> void:
	for keyNote in levelData:
		await get_tree().create_timer(levelData[keyNote]).timeout
		var cloned = noteClone.instantiate()
		add_child(cloned)
