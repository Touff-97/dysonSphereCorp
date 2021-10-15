extends Control

signal level_changed

onready var title : Label = $Color/Margin/VBox/Title

var level_name = "EndScreen"
var winner : bool = false setget set_winner


func _ready() -> void:
	if winner:
		title.set_text("You've won!")
	else:
		title.set_text("Too much debt")


func set_winner(new_value):
	winner = new_value


func _on_BackToMenu_pressed() -> void:
	emit_signal("level_changed", level_name)


func _on_Replay_pressed() -> void:
	emit_signal("level_changed", level_name, 1)


func _on_Settings_pressed() -> void:
	emit_signal("level_changed", level_name, 2)
