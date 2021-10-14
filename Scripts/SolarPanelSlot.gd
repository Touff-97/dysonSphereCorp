extends VBoxContainer

signal panel_added
signal power_changed

onready var game = get_parent().get_parent().get_parent().get_parent()

onready var add_panel : TextureButton = $Add
onready var add_panel_cost : Label = $Add/Cost

onready var panel : TextureButton = $Panel
onready var panel_cost : Label = $Panel/Cost
onready var upgrades : HBoxContainer = $Panel/Upgrades
onready var up_1 : TextureButton = $Panel/Upgrades/Upgrade
onready var up_2 : TextureButton = $Panel/Upgrades/Upgrade2
onready var up_3 : TextureButton = $Panel/Upgrades/Upgrade3

var cost : int = 20
var power_output : int = 10

var upgrade_one : bool = false
var upgrade_two : bool = false
var upgrade_three : bool = false


func _ready() -> void:
	add_panel_cost.set_text(str(cost))


func _on_Add_pressed() -> void:
	if game.money >= cost:
		add_panel.visible = false
		panel_cost.set_text(str(cost))
		panel.visible = true
		panel.pressed = true
		_on_Panel_pressed()
		emit_signal("panel_added", cost)
		emit_signal("power_changed", cost, power_output)
		game.instance_resource_gained(1, self)
	else:
		add_panel.pressed = false


func _on_Panel_pressed() -> void:
	upgrades.visible = !upgrades.visible


func _on_Upgrade_pressed() -> void:
	if game.money >= 20 and not upgrade_one:
		upgrade_one = true
		power_output *= 2
		
		panel_cost.set_text(str(160))
		
		emit_signal("power_changed", 20, power_output - 10)
		game.instance_resource_gained(1, self)
		
		up_1.pressed = true
		yield(get_tree().create_timer(1.5), "timeout")
		up_2.visible = true
		up_1.disabled = true
	else:
		up_1.pressed = false


func _on_Upgrade2_pressed() -> void:
	if game.money >= 160 and not upgrade_two:
		upgrade_two = true
		power_output *= 5
		
		panel_cost.set_text(str(800))
		
		emit_signal("power_changed", 160, power_output - 20)
		game.instance_resource_gained(1, self)
		
		up_2.pressed = true
		yield(get_tree().create_timer(1.5), "timeout")
		up_3.visible = true
		up_2.disabled = true
	else:
		up_2.pressed = false


func _on_Upgrade3_pressed() -> void:
	if game.money >= 800 and not upgrade_three:
		upgrade_three = true
		power_output *= 10
		
		panel_cost.visible = false
		
		emit_signal("power_changed", 800, power_output - 100)
		game.instance_resource_gained(1, self)
		
		up_3.pressed = true
		yield(get_tree().create_timer(1.5), "timeout")
		up_3.disabled = true
		panel.texture_normal = load("res://Assets/Sprites/solar_panel_farm/panel_mk_1_selected.png")
	else:
		up_3.pressed = false
