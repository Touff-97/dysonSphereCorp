extends VBoxContainer

signal patch_added

onready var game = get_parent().get_parent().get_parent().get_parent()

onready var add_patch : TextureButton = $AddPatch
onready var add_patch_label : Label = $AddPatch/Label

onready var patch : TextureButton = $DirtPatch
onready var upgrade : CenterContainer = $DirtPatch/HBox

onready var seed_bag : TextureButton = $DirtPatch/HBox/Seed
onready var seed_selection : HBoxContainer = $DirtPatch/HBox/SeedSelection
onready var grain : TextureButton = $DirtPatch/HBox/SeedSelection/Grain
onready var fruit : TextureButton = $DirtPatch/HBox/SeedSelection/Fruit
onready var beans : TextureButton = $DirtPatch/HBox/SeedSelection/Beans
onready var grain_label : Label = $DirtPatch/HBox/SeedSelection/Grain/Label
onready var fruit_label : Label = $DirtPatch/HBox/SeedSelection/Fruit/Label
onready var beans_label : Label = $DirtPatch/HBox/SeedSelection/Beans/Label

onready var water : TextureButton = $DirtPatch/HBox/Water
onready var water_countdown : Label = $DirtPatch/HBox/Water/Countdown
onready var water_timer : Timer = $DirtPatch/HBox/Water/WaterTimer

onready var harvest : TextureButton = $DirtPatch/HBox/Harvest

enum growStages {
	SEED,
	ONE,
	TWO,
	THREE,
}

enum seedTypes {
	GRAIN,
	FRUIT,
	BEAN,
}

export(growStages) var grow_stages = growStages.SEED
export(seedTypes) var seed_types = seedTypes.GRAIN

var cost : int = 20

var grow_time : int = 40
var grow_boost : int = 20
var watering_bonus : int = 0
var produce_yield : int = 4

var reset : bool = false


func _ready() -> void:
	add_patch_label.set_text(str(cost))


# SIGNALS FUNCTIONS
func _on_AddPatch_pressed() -> void:
	if game.money >= cost:
		add_patch.hide()
		patch.show()
		game.set_money(game.get_money() - cost)
		emit_signal("patch_added")
	else:
		add_patch.pressed = false
		game.not_enough_resources("Money")


func _on_DirtPatch_pressed() -> void:
	upgrade.visible = !upgrade.visible
	
	if upgrade.visible:
		seed_selection.visible = false
		seed_bag.visible = true


func _on_Seed_pressed() -> void:
	# UI
	seed_bag.visible = false
	seed_selection.visible = true
	# Seeds
	grain_label.set_text(str(game.grain_amount))
	fruit_label.set_text(str(game.fruit_amount))
	beans_label.set_text(str(game.beans_amount))
	# Grain
	if game.grain_amount <= 0:
		grain_label.visible = false
		grain.disabled = true
	else:
		grain_label.visible = true
		grain.disabled = false
	# Fruit
	if game.fruit_amount <= 0:
		fruit_label.visible = false
		fruit.disabled = true
	else:
		fruit_label.visible = true
		fruit.disabled = false
	# Beans
	if game.beans_amount <= 0:
		beans_label.visible = false
		beans.disabled = true
	else:
		beans_label.visible = true
		beans.disabled = false


func _on_Grain_pressed() -> void:
	# Data
	seed_types = seedTypes.GRAIN
	# UI
	seed_selection.visible = false
	water.visible = true
	# Dirt
	patch.texture_normal = load("res://Assets/Sprites/produce_farm/seeded_patch.png")
	patch.texture_hover = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	patch.texture_pressed = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	# Plant
	game.grain_amount -= 1
	game.set_produce(game.get_produce() - 1)
	grow_plant()


func _on_Fruit_pressed() -> void:
	# Data
	seed_types = seedTypes.FRUIT
	# UI
	seed_selection.visible = false
	water.visible = true
	# Dirt
	patch.texture_normal = load("res://Assets/Sprites/produce_farm/seeded_patch.png")
	patch.texture_hover = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	patch.texture_pressed = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	# Plant
	game.fruit_amount -= 1
	game.set_produce(game.get_produce() - 1)
	grow_plant()


func _on_Beans_pressed() -> void:
	# Data
	seed_types = seedTypes.BEAN
	# UI
	seed_selection.visible = false
	water.visible = true
	# Dirt
	patch.texture_normal = load("res://Assets/Sprites/produce_farm/seeded_patch.png")
	patch.texture_hover = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	patch.texture_pressed = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	# Plant
	game.beans_amount -= 1
	game.set_produce(game.get_produce() - 1)
	grow_plant()


func _on_Water_pressed() -> void:
	water.disabled = true
	water_countdown.visible = true
	
	water_timer.start()
	water_timer.autostart = true
	
	grow_time -= grow_boost
	watering_bonus += randi() % 4


func _on_WaterTimer_timeout() -> void:
	water_countdown.set_text(str(int(water_countdown.get_text()) - game.get_time_speed()))

	if int(water_countdown.text) <= 0:
		water.disabled = false
		water_countdown.visible = false
		water_countdown.set_text("50")
		
		water_timer.stop()


func _on_Harvest_pressed() -> void:
	harvest.visible = false
	
	grow_stages = growStages.SEED
	grow_time = grow_boost * 2
	
	patch.texture_normal = load("res://Assets/Sprites/produce_farm/seeded_patch.png")
	patch.texture_hover = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	patch.texture_pressed = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
	
	game.set_produce((game.get_produce() + produce_yield) + watering_bonus)
	
	match seed_types:
		seedTypes.GRAIN:
			game.grain_amount += ((produce_yield + watering_bonus) - 1)
			game.instance_resource_gained(2, self)
		seedTypes.FRUIT:
			game.fruit_amount += ((produce_yield + watering_bonus) - 1)
			game.instance_resource_gained(3, self)
		seedTypes.BEAN:
			game.beans_amount += ((produce_yield + watering_bonus) - 1)
			game.instance_resource_gained(4, self)
	
	watering_bonus = 0
	
	water.visible = true


# CUSTOM FUNCTIONS
func grow_plant() -> void:
	while grow_time > 0:
		if reset:
			reset = false
			return
		yield(get_tree().create_timer(1.0), "timeout")
		grow_time -= game.get_time_speed()
		print(grow_time)
		
		if grow_time <= 0 and grow_stages < 3:
			grow_stages += 1
			grow_time = (grow_boost * 2)
			
			var _seed_type : String
			
			match seed_types:
				seedTypes.GRAIN:
					_seed_type = "a"
				seedTypes.FRUIT:
					_seed_type = "b"
				seedTypes.BEAN:
					_seed_type = "c"
			
			match grow_stages:
				growStages.SEED:
					patch.texture_normal = load("res://Assets/Sprites/produce_farm/seeded_patch.png")
					patch.texture_hover = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
					patch.texture_pressed = load("res://Assets/Sprites/produce_farm/seeded_patch_selected.png")
				growStages.ONE:
					patch.texture_normal = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_one.png")
					patch.texture_hover = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_one_selected.png")
					patch.texture_pressed = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_one_selected.png")
				growStages.TWO:
					patch.texture_normal = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_two.png")
					patch.texture_hover = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_two_selected.png")
					patch.texture_pressed = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_two_selected.png")
				growStages.THREE:
					patch.texture_normal = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_three.png")
					patch.texture_hover = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_three_selected.png")
					patch.texture_pressed = load("res://Assets/Sprites/produce_farm/" + _seed_type + "_stage_three_selected.png")
					
					water.visible = false
					water.disabled = false
					water_countdown.visible = false
					water_countdown.set_text("50")
					water_timer.stop()
					
					harvest.visible = true


func _on_Refresh_pressed() -> void:
	# Dirt reset
	patch.texture_normal = load("res://Assets/Sprites/produce_farm/dirt_patch.png")
	patch.texture_hover = load("res://Assets/Sprites/produce_farm/dirt_patch_selected.png")
	patch.texture_pressed = load("res://Assets/Sprites/produce_farm/dirt_patch_selected.png")
	
	_on_DirtPatch_pressed()
	grow_time = 40
	
	# Water reset
	water.visible = false
	water.disabled = false
	water_countdown.visible = false
	water_countdown.set_text("50")
	water_timer.stop()
	watering_bonus = 0
	
	match seed_types:
		seedTypes.GRAIN:
			game.grain_amount += 1
			game.set_produce(game.get_produce() + 1)
		seedTypes.FRUIT:
			game.fruit_amount += 1
			game.set_produce(game.get_produce() + 1)
		seedTypes.BEAN:
			game.beans_amount += 1
			game.set_produce(game.get_produce() + 1)
	
	grow_stages = growStages.SEED
	
	reset = true
