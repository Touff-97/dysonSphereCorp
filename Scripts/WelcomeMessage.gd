extends Control

onready var game : Control = get_parent()


func _ready() -> void:
	game.set_time_speed(0)


func _on_Done_pressed() -> void:
	visible = false
	game.set_time_speed(1)
