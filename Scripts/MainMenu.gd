extends Control

signal level_changed

var level_name = "MainMenu"


func _on_Start_pressed() -> void:
	emit_signal("level_changed", level_name)


func _on_Settings_pressed() -> void:
	emit_signal("level_changed", level_name, 1)


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_Link_pressed() -> void:
	OS.shell_open("https://touff97.itch.io/dyson-sphere-corp")
