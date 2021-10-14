extends HBoxContainer

export(String) var bus_name = "Sounds"
export(NodePath) var feedback_sound_path = null

onready var slider : HSlider = $SoundSlider

var _feedback_sound: AudioStreamPlayer = null

var _bus_index = 0

func _ready() -> void:
	if feedback_sound_path != null:
		_feedback_sound = get_node(feedback_sound_path)
	_bus_index = AudioServer.get_bus_index(bus_name)
	_set_volume(slider.value)


func _set_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus_index, linear2db(slider.value))


func _on_SoundSlider_value_changed(value: float) -> void:
	_set_volume(slider.value)
	if _feedback_sound != null:
		if not _feedback_sound.is_playing():
			_feedback_sound.play()
