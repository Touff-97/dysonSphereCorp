extends Control

signal day_passed

onready var game = get_parent().get_parent().get_parent().get_parent()

onready var notch = $Sun/Notch
onready var day_counter : Label = $Day

var day : int = 1 setget set_day, get_day


func set_day(new_value: int) -> void:
	day = new_value
	day_counter.set_text("Day #" + str(new_value))


func get_day() -> int:
	return day


func _ready() -> void:
	notch.rect_rotation = 15


func _on_Timer_timeout() -> void:
	if notch.rect_rotation < 360:
		notch.rect_rotation += game.get_time_speed()
	else:
		notch.rect_rotation = 0
		set_day(get_day() + 1)
		emit_signal("day_passed")
