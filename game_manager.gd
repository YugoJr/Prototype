extends Node

enum key {E, R, U, I}

@onready var noteClone = preload("res://note.tscn")
var levelData = {
	key.E: 3.0,
}

func _ready() -> void:
	for keyNote in levelData:
		await get_tree().create_timer(levelData[keyNote]).timeout
		var cloned = noteClone.instantiate()
		add_child(cloned)
