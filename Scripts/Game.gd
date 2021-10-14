extends Control

const PANEL_SLOT : PackedScene = preload("res://Scenes/SolarPanelSlot.tscn")
const PATCH_SLOT : PackedScene = preload("res://Scenes/DirtPatch.tscn")
const SHOP_SLOT : PackedScene = preload("res://Scenes/HoloSeller.tscn")
const RESOURCE_GAINED : PackedScene = preload("res://Scenes/ResourceGained.tscn")

signal level_changed

# UI
onready var previous : TextureButton = $HUD/TopUI/HBox3/Previous
onready var next : TextureButton = $HUD/TopUI/HBox4/Next

onready var solar_view : MarginContainer = $SolarPanelView
onready var farm_view : MarginContainer = $FarmView
onready var shop_view : MarginContainer = $ShopView

onready var view_label : Label = $HUD/MarginContainer/VBoxContainer/View

onready var end_of_day : Control = $EndOfDaySummary

# Solar Panels
onready var panel_grid : GridContainer = $SolarPanelView/VBox/SolarPanelsGrid

onready var add_panel_capacity : TextureButton = $SolarPanelView/AddPanelCapacity
onready var add_panel_capacity_label : Label = $SolarPanelView/AddPanelCapacity/Label
onready var add_panel_capacity_timer : Label = $SolarPanelView/AddPanelCapacity/Timer
onready var add_panel_capacityTimer : Timer = $SolarPanelView/AddPanelCapacity/CapacityTimer

onready var money_label : Label = $HUD/TopUI/HBox2/Money
onready var power_h : HBoxContainer = $HUD/TopUI/VBox/HBox
onready var power_label : Label = $HUD/TopUI/VBox/HBox/Power
onready var produce_h : HBoxContainer = $HUD/TopUI/VBox/HBox5
onready var produce_label : Label = $HUD/TopUI/VBox/HBox5/Produce

# Dirt Patches
onready var patch_grid : GridContainer = $FarmView/VBox/ProduceFarmGrid

onready var add_patch_capacity : TextureButton = $FarmView/AddPatchCapacity
onready var add_patch_capacity_label : Label = $FarmView/AddPatchCapacity/Label
onready var add_patch_capacity_timer : Label = $FarmView/AddPatchCapacity/Timer
onready var add_patch_capacityTimer : Timer = $FarmView/AddPatchCapacity/PatchCapacityTimer

# Shop Sellers
onready var shop_grid : GridContainer = $ShopView/VBox/OrganicShopGrid

onready var add_shop_capacity : TextureButton = $ShopView/AddSellerCapacity
onready var add_shop_capacity_label : Label = $ShopView/AddSellerCapacity/Label
onready var add_shop_capacity_timer : Label = $ShopView/AddSellerCapacity/Timer
onready var add_shop_capacityTimer : Timer = $ShopView/AddSellerCapacity/SellerCapacityTimer

# UI
var level_name = "Game"

enum View {
	SOLAR,
	FARM,
	SHOP,
}

var debt : int = 1000000 setget set_debt, get_debt

var view = View.SOLAR setget set_view, get_view
var time_speed : int = 1 setget set_time_speed, get_time_speed
var money : int = 0 setget set_money, get_money

# Solar Panels
var panel_count : int = 0
var panel_limit : int = 1
var panel_capacity_cooldown : int = 0

var power_output : int = 0 setget set_power, get_power

var _return_queue := []
var return_time : int = 30

# Dirt Patches
var patch_count : int = 0
var patch_limit : int = 1
var patch_capacity_cooldown : int = 0

var produce : int = 1 setget set_produce, get_produce

var grain_amount : int = 1
var fruit_amount : int = 0
var beans_amount : int = 0

# Holo Sellers
var seller_count : int = 0
var seller_limit : int = 1
var seller_capacity_cooldown : int = 0


func _ready() -> void:
	set_money(100)
	set_produce(1)
	set_view(View.SOLAR)
	instance_panel_slot()
	instance_patch_slot()
	instance_shop_slot()


### SETGET FUNCTIONS ###
func set_debt(new_value: int) -> void:
	debt = new_value


func get_debt() -> int:
	return debt


func set_view(new_value) -> void:
	view = new_value
	
	match view:
		View.SOLAR:
			# Nav
			previous.disabled = true
			# UI
			produce_h.visible = false
			power_h.visible = true
			# Content
			view_label.set_text("Solar Farm")
			solar_view.show()
			farm_view.hide()
		View.FARM:
			# Nav
			previous.disabled = false
			next.disabled = false
			# UI
			produce_h.visible = true
			power_h.visible = false
			# Content
			view_label.set_text("Produce Farm")
			solar_view.hide()
			farm_view.show()
			shop_view.hide()
		View.SHOP:
			# Nav
			next.disabled = true
			# UI
			produce_h.visible = true
			power_h.visible = true
			# Content
			view_label.set_text("Organic Shop")
			farm_view.hide()
			shop_view.show()


func get_view() -> int:
	return view


func set_time_speed(new_value: int) -> void:
	time_speed = new_value


func get_time_speed() -> int:
	return time_speed


# Solar Panels
func set_money(new_value: int) -> void:
	money = new_value
	money_label.set_text(str(new_value))


func get_money() -> int:
	return money


func set_power(new_value: int) -> void:
	power_output = new_value
	power_label.set_text(str(new_value))


func get_power() -> int:
	return power_output


func set_power_queue(new_value: int) -> void:
	_return_queue.append(new_value)
	call_deferred("give_back_power", _return_queue.pop_front(), return_time)


# Produce farm
func set_produce(new_value: int) -> void:
	produce = new_value
	produce_label.set_text(str(new_value))


func get_produce() -> int:
	return produce


### SIGNALS FUNCTIONS ###
func _on_Back_pressed() -> void:
	emit_signal("level_changed", level_name)


func _on_Time_day_passed() -> void:
	set_time_speed(0)
	end_of_day.show()


func _on_Previous_pressed() -> void:
	if get_view() > 0:
		set_view(get_view() - 1)


func _on_Next_pressed() -> void:
	if get_view() < 2:
		set_view(get_view() + 1)


func _on_Play_pressed() -> void:
	set_time_speed(1)


func _on_Pause_pressed() -> void:
	set_time_speed(0)


func _on_Forward_pressed() -> void:
	set_time_speed(2)


func _on_ForwardTimes2_pressed() -> void:
	set_time_speed(3)



# Solar Panels
func _on_Panel_added(cost: int) -> void:
	if money >= cost:
		if panel_count < panel_limit:
			instance_panel_slot()


func _on_Power_changed(added_cost: int, added_power: int):
	set_money(get_money() - added_cost)
	set_power(get_power() + added_power)


func _on_AddCapacity_pressed() -> void:
	if panel_count == panel_limit:
		if money >= 50:
			instance_panel_slot()
			panel_limit += 2
			
			add_panel_capacity_label.visible = false
			
			panel_capacity_cooldown = 75
			
			add_panel_capacity.disabled = true
			add_panel_capacity_timer.set_text(str(panel_capacity_cooldown))
			add_panel_capacity_timer.visible = true
			
			add_panel_capacityTimer.start()
			add_panel_capacityTimer.autostart = true
			
			set_money(get_money() - 50)
		else:
			not_enough_resources("Money")


func _on_CapacityTimer_timeout() -> void:
	if panel_capacity_cooldown > 0:
		panel_capacity_cooldown -= get_time_speed()
		add_panel_capacity_timer.set_text(str(panel_capacity_cooldown))
		print(panel_capacity_cooldown)
	else:
		add_panel_capacityTimer.stop()
		add_panel_capacity_timer.visible = false
		add_panel_capacity.disabled = false
		add_panel_capacity_label.visible = true


# Dirt Patches
func _on_Patch_added() -> void:
	if patch_count < patch_limit:
		instance_patch_slot()


func _on_AddPatchCapacity_pressed() -> void:
	if patch_count <= patch_limit:
		if money >= 50:
			instance_patch_slot()
			patch_limit += 2
			
			add_patch_capacity_label.visible = false
			
			patch_capacity_cooldown = 75
			
			add_patch_capacity.disabled = true
			add_patch_capacity_timer.set_text(str(patch_capacity_cooldown))
			add_patch_capacity_timer.visible = true
			
			add_patch_capacityTimer.start()
			add_patch_capacityTimer.autostart = true
			
			set_money(get_money() - 50)
		else:
			not_enough_resources("Money")


func _on_PatchCapacityTimer_timeout() -> void:
	if patch_capacity_cooldown <= 0:
		add_patch_capacityTimer.stop()
		add_patch_capacity_timer.visible = false
		add_patch_capacity.disabled = false
		add_patch_capacity_label.visible = true
	else:
		patch_capacity_cooldown -= get_time_speed()
		add_patch_capacity_timer.set_text(str(patch_capacity_cooldown))
		print(patch_capacity_cooldown)


# Holo Sellers
func _on_Shop_added() -> void:
	if seller_count < seller_limit:
		instance_shop_slot()


func _on_AddSellerCapacity_pressed() -> void:
	if seller_count <= seller_limit:
		if money >= 50:
			instance_shop_slot()
			seller_limit += 2
			
			add_shop_capacity_label.visible = false
			
			seller_capacity_cooldown = 75
			
			add_shop_capacity.disabled = true
			add_shop_capacity_timer.set_text(str(seller_capacity_cooldown))
			add_shop_capacity_timer.visible = true
			
			add_shop_capacityTimer.start()
			add_shop_capacityTimer.autostart = true
			
			set_money(get_money() - 50)
		else:
			not_enough_resources("Money")


func _on_SellerCapacityTimer_timeout() -> void:
	if seller_capacity_cooldown <= 0:
		add_shop_capacityTimer.stop()
		add_shop_capacity_timer.visible = false
		add_shop_capacity.disabled = false
		add_shop_capacity_label.visible = true
	else:
		seller_capacity_cooldown -= get_time_speed()
		add_shop_capacity_timer.set_text(str(seller_capacity_cooldown))
		print(seller_capacity_cooldown)


### CUSTOM FUNCTIONS ###
func instance_resource_gained(resource: int, requester: Node) -> void:
	var resource_gained = RESOURCE_GAINED.instance()
	var center_container = CenterContainer.new()
	
	center_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	resource_gained.set_resource(resource)
	center_container.add_child(resource_gained)
	requester.get_child(1).add_child(center_container)


# Solar Panels
func instance_panel_slot() -> void:
	if panel_count < 9:
		var new_slot = PANEL_SLOT.instance()
		new_slot.cost = 20 + (20 * panel_count)
		panel_grid.add_child(new_slot, true)
		new_slot.connect("panel_added", self, "_on_Panel_added")
		new_slot.connect("power_changed", self, "_on_Power_changed")
		panel_count += 1


# Farm
func instance_patch_slot() -> void:
	if patch_count < 9:
		var new_slot = PATCH_SLOT.instance()
		new_slot.cost = 20 + (20 * patch_count)
		patch_grid.add_child(new_slot, true)
		new_slot.connect("patch_added", self, "_on_Patch_added")
		patch_count += 1


# Shop
func instance_shop_slot() -> void:
	if seller_count < 9:
		var new_slot = SHOP_SLOT.instance()
		new_slot.cost = 20 + (20 * seller_count)
		shop_grid.add_child(new_slot, true)
		new_slot.connect("shop_added", self, "_on_Shop_added")
		seller_count += 1


func give_back_power(power_amount: int, start_time: int) -> void:
	var timer = start_time
	while timer > 0:
		yield(get_tree().create_timer(1.0), "timeout")
		timer -= get_time_speed()
		print("Return Time: ", timer)
	if timer <= 0:
		set_power(get_power() + power_amount)
		print("Returned: ", power_amount)


func not_enough_resources(resource: String) -> void:
	match resource:
		"Money":
			money_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			money_label.set("custom_colors/font_color", Color(0, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			money_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			money_label.set("custom_colors/font_color", Color(0, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			money_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			money_label.set("custom_colors/font_color", Color(0, 0, 0))
		"Power":
			power_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			power_label.set("custom_colors/font_color", Color(0, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			power_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			power_label.set("custom_colors/font_color", Color(0, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			power_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			power_label.set("custom_colors/font_color", Color(0, 0, 0))
		"Produce":
			produce_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			produce_label.set("custom_colors/font_color", Color(0, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			produce_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			produce_label.set("custom_colors/font_color", Color(0, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			produce_label.set("custom_colors/font_color", Color(255, 0, 0))
			yield(get_tree().create_timer(0.1), "timeout")
			produce_label.set("custom_colors/font_color", Color(0, 0, 0))
