extends Control

signal level_changed

var level_name = "Settings"


func _on_Back_pressed() -> void:
	emit_signal("level_changed", level_name)


func _on_Check_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen
