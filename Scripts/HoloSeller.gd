extends VBoxContainer


### TODO
# -Connecting buttons and make them function- [check]
# -Swap items to sell- [check]
# -Get costumers to buy x amount of times a day- [check]
# -Review and rating system- [check]
# -System to set price of items- [check]
# Offer/Demand system with deminishing returns
# Floating numbers that show what you've gained and a little basket showing a purchase

signal shop_added

onready var game = get_parent().get_parent().get_parent().get_parent()

onready var add_shop : TextureButton = $AddShop
onready var add_shop_label : Label = $AddShop/Label

onready var shop : TextureButton = $HoloSeller
onready var options : CenterContainer = $HoloSeller/Center
onready var refresh : TextureButton = $HoloSeller/Refresh

onready var sell_power : TextureButton = $HoloSeller/Center/HBox/Power
onready var power_price_tag : Label = $HoloSeller/Center/HBox/Power/PriceTag
onready var sell_produce : TextureButton  = $HoloSeller/Center/HBox/Produce

onready var produce : HBoxContainer = $HoloSeller/Center/HBox2
onready var sell_grain : TextureButton = $HoloSeller/Center/HBox2/Grain
onready var grain_price_tag : Label = $HoloSeller/Center/HBox2/Grain/PriceTag
onready var sell_fruit : TextureButton = $HoloSeller/Center/HBox2/Fruit
onready var fruit_price_tag : Label = $HoloSeller/Center/HBox2/Fruit/PriceTag
onready var sell_beans : TextureButton = $HoloSeller/Center/HBox2/Beans
onready var beans_price_tag : Label = $HoloSeller/Center/HBox2/Beans/PriceTag

onready var price_tag : HBoxContainer = $HoloSeller/Price
onready var price_input : LineEdit = $HoloSeller/Price/Input

onready var customer : Timer = $HoloSeller/Customer
onready var customer_path : PathFollow2D = $HoloSeller/CustomerBar/Path/PathFollow
onready var customer_notch : TextureRect = $HoloSeller/CustomerBar/Path/PathFollow/Customer

onready var one_star : TextureRect = $HoloSeller/Rating/OneStar/Star
onready var two_star : TextureRect = $HoloSeller/Rating/TwoStar/Star
onready var three_star : TextureRect = $HoloSeller/Rating/ThreeStar/Star
onready var four_star : TextureRect = $HoloSeller/Rating/FourStar/Star
onready var five_star : TextureRect = $HoloSeller/Rating/FiveStar/Star

enum itemSelling {
	NULL,
	POWER,
	GRAIN,
	FRUIT,
	BEANS,
}

var cost : int = 30

var item_selling = itemSelling.NULL setget set_item_selling, get_item_selling
var item_price : int = 0 setget set_item_price, get_item_price

var new_rating : int = 0 setget set_rating
var ratings : Array = []
var rating : int = 0

var incoming_total : float = 0.0
var incoming_customer : float = 0.0


func _ready() -> void:
	randomize()
	add_shop_label.set_text(str(cost))


# SETGET FUNCTIONS
func set_item_selling(new_value: int) -> void:
	item_selling = new_value
	
	if not item_selling == itemSelling.NULL:
		refresh.show()
	else:
		refresh.hide()


func get_item_selling() -> int:
	return item_selling


func set_item_price(new_value: int) -> void:
	item_price = new_value
	
	print("Item: ", item_selling)
	print("Price: ", new_value)
	
	match item_selling:
		itemSelling.POWER:
			power_price_tag.set_text(str(new_value))
			print(power_price_tag.get_text())
		itemSelling.GRAIN:
			grain_price_tag.set_text(str(new_value))
		itemSelling.FRUIT:
			fruit_price_tag.set_text(str(new_value))
		itemSelling.BEANS:
			beans_price_tag.set_text(str(new_value))


func get_item_price() -> int:
	return item_price


func set_rating(new_value: int) -> void:
	new_rating = new_value
	
	print("New rating: ", new_value)
	
	ratings.append(new_value)
	var total_ratings : int = 0
	var rating_count : int = 0
	
	for r in ratings:
		total_ratings += r
		rating_count += 1
	
	rating = total_ratings / rating_count
	print("Total rating: ", total_ratings)
	print("Ratings amount: ", rating_count)
	print("Average rating: ", rating)
	
	match rating:
		0:
			one_star.hide()
			two_star.hide()
			three_star.hide()
			four_star.hide()
			five_star.hide()

		1:
			one_star.show()
			two_star.hide()
			three_star.hide()
			four_star.hide()
			five_star.hide()

		2:
			two_star.show()
			three_star.hide()
			four_star.hide()
			five_star.hide()

		3:
			one_star.show()
			two_star.show()
			three_star.show()
			four_star.hide()
			five_star.hide()

		4:
			one_star.show()
			two_star.show()
			three_star.show()
			four_star.show()
			five_star.hide()

		5:
			one_star.show()
			two_star.show()
			three_star.show()
			four_star.show()
			five_star.show()
		
		_:
			return


# SIGNALS FUNCTIONS
func _on_AddShop_pressed() -> void:
	if game.money >= cost:
		add_shop.hide()
		shop.show()
		game.set_money(game.get_money() - cost)
		emit_signal("shop_added")
	else:
		add_shop.pressed = false


func _on_HoloSeller_pressed() -> void:
	options.visible = !options.visible


func _on_Power_pressed() -> void:
	if game.get_power() > 5:
		sell_produce.hide()
		set_item_selling(itemSelling.POWER)
		price_tag.show()
		price_input.grab_focus()


func _on_Produce_pressed() -> void:
	if game.get_produce() > 5:
		sell_power.hide()
		sell_produce.hide()
		produce.visible = true


func _on_Grain_pressed() -> void:
	if game.grain_amount > 5:
		sell_fruit.hide()
		sell_beans.hide()
		set_item_selling(itemSelling.GRAIN)
		price_tag.show()
		price_input.grab_focus()


func _on_Fruit_pressed() -> void:
	if game.fruit_amount > 5:
		sell_grain.hide()
		sell_beans.hide()
		set_item_selling(itemSelling.FRUIT)
		price_tag.show()
		price_input.grab_focus()


func _on_Beans_pressed() -> void:
	if game.beans_amount > 5:
		sell_grain.hide()
		sell_fruit.hide()
		set_item_selling(itemSelling.BEANS)
		price_tag.show()
		price_input.grab_focus()


func _on_Refresh_pressed() -> void:
	set_item_selling(itemSelling.NULL)
	
	options.hide()
	
	sell_power.show()
	power_price_tag.set_text("")
	sell_produce.show()
	
	produce.hide()
	sell_grain.show()
	grain_price_tag.set_text("")
	sell_fruit.show()
	fruit_price_tag.set_text("")
	sell_beans.show()
	beans_price_tag.set_text("")
	
	price_tag.hide()
	
	customer.stop()
	customer_path.unit_offset = 0.0


func _on_Check_pressed() -> void:
	set_item_price(int(price_input.get_text()))
	price_tag.hide()
	price_input.set_text("")
	
	incoming_total = randi() % 40 + 30
	incoming_customer = incoming_total
	customer.start()


func _on_Customer_timeout() -> void:
	if incoming_customer > 0.0:
		incoming_customer -= game.get_time_speed()
		calculate_unit_offset()
	else:
		customer.stop()
		customer_interaction()


func calculate_unit_offset() -> void:
	var unit_offset = 1 - (incoming_customer / incoming_total)
	customer_path.unit_offset = unit_offset
	
	if unit_offset < 0.95:
		customer_notch.texture = load("res://Assets/Sprites/organic_shop/customer.png")
	else:
		customer_notch.texture = load("res://Assets/Sprites/organic_shop/customer_arrived.png")


func customer_interaction() -> void:
	if not item_selling == itemSelling.NULL:
		var buying_amount : int
		
		match item_selling:
			itemSelling.POWER:
				if game.get_power() > 0:
					buying_amount = randi() % (game.get_power() / 3) + ((game.get_power() / 3) / 2)
					game.set_power(game.get_power() - buying_amount)
					game.set_power_queue(buying_amount)
					
					# TODO: Measure customer satisfaction with how pricy it is 
					get_review("satisfied", randi() % 3 + 3)
				else:
					get_review("disatisfied", randi() % 3)
			
			itemSelling.GRAIN:
				if game.get_produce() > 0 and game.grain_amount > 0:
					buying_amount = randi() % (game.grain_amount / 3) + ((game.grain_amount / 3) / 3)
					game.set_produce(game.get_produce() - buying_amount)
					game.grain_amount -= buying_amount
					
					# TODO: Measure customer satisfaction with how pricy it is 
					get_review("satisfied", randi() % 3 + 3)
				else:
					get_review("disatisfied", randi() % 3)
			
			itemSelling.FRUIT:
				if game.get_produce() > 0 and game.fruit_amount > 0:
					buying_amount = randi() % (game.fruit_amount / 3) + ((game.fruit_amount / 3) / 3)
					game.set_produce(game.get_produce() - buying_amount)
					game.fruit_amount -= buying_amount
					
					# TODO: Measure customer satisfaction with how pricy it is 
					get_review("satisfied", randi() % 3 + 3)
				else:
					get_review("disatisfied", randi() % 3)
			
			itemSelling.BEANS:
				if game.get_produce() > 0 and game.beans_amount > 0:
					buying_amount = randi() % (game.beans_amount / 3) + ((game.beans_amount / 3) / 3)
					game.set_produce(game.get_produce() - buying_amount)
					game.beans_amount -= buying_amount
					
					# TODO: Measure customer satisfaction with how pricy it is 
					get_review("satisfied", randi() % 3 + 3)
				else:
					get_review("disatisfied", randi() % 3)
			
			_:
				return
		
		get_paid(buying_amount)
		
		game.instance_resource_gained(0, self)
		
		print("Customer bought " + str(buying_amount) + " items")
		# Restart
		incoming_customer = randi() % 40 + 30
		customer.start()
	
	return


func get_paid(amount: int) -> void:
	game.set_money(game.get_money() + (amount * item_price))


func get_review(satisfaction: String, _rating: int):
	set_rating(_rating)
	print("Customer " + satisfaction + "!")
	print("Customer left a " + str(_rating) + " star review")

