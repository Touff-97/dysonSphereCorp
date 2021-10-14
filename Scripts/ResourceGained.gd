extends TextureRect

onready var animPlayer : AnimationPlayer = $AnimationPlayer

enum resourceGained {
	MONEY,
	POWER,
	GRAIN,
	FRUIT,
	BEANS,
}

var resource_gained = resourceGained.MONEY setget set_resource


func _ready() -> void:
	animPlayer.play("up_fade")


func set_resource(new_value) -> void:
	resource_gained = new_value
	
	match resource_gained:
		resourceGained.MONEY:
			texture = load("res://Assets/Sprites/organic_shop/money_gained.png")
		resourceGained.POWER:
			texture = load("res://Assets/Sprites/solar_panel_farm/power_gained.png")
		resourceGained.GRAIN:
			texture = load("res://Assets/Sprites/produce_farm/grain_gained.png")
		resourceGained.FRUIT:
			texture = load("res://Assets/Sprites/produce_farm/fruit_gained.png")
		resourceGained.BEANS:
			texture = load("res://Assets/Sprites/produce_farm/beans_gained.png")


func delete() -> void:
	get_parent().queue_free()
