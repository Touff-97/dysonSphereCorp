extends HBoxContainer


func _on_Play_pressed() -> void:
	unpress_buttons("Play")


func _on_Pause_pressed() -> void:
	unpress_buttons("Pause")


func _on_Forward_pressed() -> void:
	unpress_buttons("Forward")


func _on_ForwardTimes2_pressed() -> void:
	unpress_buttons("ForwardTimes2")


func unpress_buttons(pressed_button: String) -> void:
	var time_buttons = get_tree().get_nodes_in_group("TimeControl")
	for b in time_buttons:
		if not b == get_node(pressed_button):
			b.pressed = false
