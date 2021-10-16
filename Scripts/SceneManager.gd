extends Control

onready var animPlayer : AnimationPlayer = $AnimationPlayer
onready var current_level = $Scene/MainMenu
onready var button_pressed : AudioStreamPlayer = $ButtonPressed 

var scene : String


func _ready() -> void:
	current_level.connect("level_changed", self, "_on_Level_changed")


func _process(delta: float) -> void:
	var buttons = get_tree().get_nodes_in_group("Button")
	for b in buttons:
		if b.is_pressed():
			b.pressed = false
			button_pressed.play()
			yield(get_tree().create_timer(0.25), "timeout")
			continue


func _on_Level_changed(current_level_name: String, button_id: int = 0, win: bool = false) -> void:
	var next_level
	var next_level_name : String
	
	animPlayer.play("fade")
	yield(get_tree().create_timer(1), "timeout")
	
	match current_level_name:
		"MainMenu":
			if button_id == 0:
				next_level_name = "Game"
			elif button_id == 1:
				next_level_name = "Settings"
		
		"Settings":
			next_level_name = "MainMenu"
		
		"Game":
			if button_id == 0:
				next_level_name = "MainMenu"
			elif button_id == 1:
				next_level_name = "EndScreen"
		
		"EndScreen":
			if button_id == 0:
				next_level_name = "MainMenu"
			elif button_id == 1:
				next_level_name = "Game"
			elif button_id == 2:
				next_level_name = "Settings"

		_:
			return
	
	next_level = load("res://Scenes/" + next_level_name + ".tscn").instance()
	next_level.show_behind_parent = true
	if next_level.has_method("set_winner"):
		next_level.set_winner(win)
	$Scene.add_child(next_level)
	next_level.connect("level_changed", self, "_on_Level_changed")
	current_level.queue_free()
	current_level = next_level
