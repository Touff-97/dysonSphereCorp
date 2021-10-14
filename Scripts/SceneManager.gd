extends Control

onready var animPlayer : AnimationPlayer = $AnimationPlayer
onready var current_level = $Scene/MainMenu

var scene : String


func _ready() -> void:
	current_level.connect("level_changed", self, "_on_Level_changed")


func _on_Level_changed(current_level_name: String, button_id: int = 0) -> void:
	var next_level
	var next_level_name : String
	
	animPlayer.play("fade")
	yield(get_tree().create_timer(1), "timeout")
	
	match current_level_name:
		"Main Menu":
			if button_id == 0:
				next_level_name = "Game"
			elif button_id == 1:
				next_level_name = "Settings"
		
		"Settings":
			next_level_name = "MainMenu"
		
		"Game":
			next_level_name = "MainMenu"

		_:
			return
	
	next_level = load("res://Scenes/" + next_level_name + ".tscn").instance()
	next_level.show_behind_parent = true
	$Scene.add_child(next_level)
	next_level.connect("level_changed", self, "_on_Level_changed")
	current_level.queue_free()
	current_level = next_level
