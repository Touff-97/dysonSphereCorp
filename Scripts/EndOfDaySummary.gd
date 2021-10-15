extends Control

onready var game : Control = get_parent()

onready var debt_label : Label = $Margin/Background/VBox/Treasury/Debt
onready var pay_amount_label : Label = $Margin/Background/VBox/Treasury/Center/HBox/Pay
onready var total_label : Label = $Margin/Background/VBox/Treasury/Total

onready var grain_amount_label : Label = $Margin/Background/VBox/BuyProduce/Grain/HBox/Icon/Label
onready var fruit_amount_label : Label = $Margin/Background/VBox/BuyProduce/Fruit/HBox/Icon/Label
onready var beans_amount_label : Label = $Margin/Background/VBox/BuyProduce/Beans/HBox/Icon/Label

var pay_amount : int = 100 setget set_pay_amount, get_pay_amount

var grain_amount : int = 0 setget set_grain_amount, get_grain_amount
var fruit_amount : int = 0 setget set_fruit_amount, get_fruit_amount
var beans_amount : int = 0 setget set_beans_amount, get_beans_amount

var seed_price : int = 10


# SETGET FUNCTIONS
func set_pay_amount(new_value: int) -> void:
	pay_amount = new_value
	pay_amount_label.set_text("+ " + str(pay_amount))
	
	total_label.set_text(str(int(debt_label.get_text()) + int(pay_amount_label.get_text())))


func get_pay_amount() -> int:
	return pay_amount


func set_grain_amount(new_value: int) -> void:
	grain_amount = new_value
	grain_amount_label.set_text(str(grain_amount))


func get_grain_amount() -> int:
	return grain_amount


func set_fruit_amount(new_value: int) -> void:
	fruit_amount = new_value
	fruit_amount_label.set_text(str(fruit_amount))


func get_fruit_amount() -> int:
	return fruit_amount


func set_beans_amount(new_value: int) -> void:
	beans_amount = new_value
	beans_amount_label.set_text(str(beans_amount))


func get_beans_amount() -> int:
	return beans_amount


# SIGNALS FUNCTIONS
func _on_EndOfDaySummary_visibility_changed() -> void:
	if visible:
		debt_label.set_text(str(game.get_debt()))
		set_pay_amount(0)
		game.set_money(game.get_money() - get_pay_amount())


func _on_Decrease_pressed() -> void:
	if pay_amount > 100:
		set_pay_amount(get_pay_amount() - 100)
		game.set_money(game.get_money() + 100)


func _on_Increase_pressed() -> void:
	if pay_amount < (game.get_money() - 100):
		set_pay_amount(get_pay_amount() + 100)
		game.set_money(game.get_money() - 100)


func _on_GrainDecrease_pressed() -> void:
	if grain_amount > 0:
		set_grain_amount(get_grain_amount() - 1)
		game.set_money(game.get_money() + seed_price)
		
		game.set_produce(game.get_produce() - 1)
		game.grain_amount -= 1


func _on_GrainIncrease_pressed() -> void:
	if (grain_amount * 10) <= game.get_money():
		set_grain_amount(get_grain_amount() + 1)
		game.set_money(game.get_money() - seed_price)
		
		game.set_produce(game.get_produce() + 1)
		game.grain_amount += 1


func _on_FruitDecrease_pressed() -> void:
	if fruit_amount > 0:
		set_fruit_amount(get_fruit_amount() - 1)
		game.set_money(game.get_money() + seed_price)
		
		game.set_produce(game.get_produce() - 1)
		game.fruit_amount -= 1


func _on_FruitIncrease_pressed() -> void:
	if (fruit_amount * 10) <= game.get_money():
		set_fruit_amount(get_fruit_amount() + 1)
		game.set_money(game.get_money() - seed_price)
		
		game.set_produce(game.get_produce() + 1)
		game.fruit_amount += 1


func _on_BeansDecrease_pressed() -> void:
	if beans_amount > 0:
		set_beans_amount(get_beans_amount() - 1)
		game.set_money(game.get_money() + seed_price)
		
		game.set_produce(game.get_produce() - 1)
		game.beans_amount -= 1


func _on_BeansIncrease_pressed() -> void:
	if (beans_amount * 10) <= game.get_money():
		set_beans_amount(get_beans_amount() + 1)
		game.set_money(game.get_money() - seed_price)
		
		game.set_produce(game.get_produce() + 1)
		game.beans_amount += 1


func _on_Done_pressed() -> void:
	if game.get_debt() <= 0:
		game.end_game(true)
	else:
		debt_label.set_text(total_label.get_text())
		game.set_debt(int(total_label.get_text()))
		
		set_grain_amount(0)
		set_fruit_amount(0)
		set_beans_amount(0)
		
		hide()
		
		game.set_time_speed(1)
