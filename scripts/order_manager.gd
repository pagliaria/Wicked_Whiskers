extends Node

var orders = {}
var order_display = {}

@onready var orders_display: HBoxContainer = null
const ORDER_SCENE = preload("res://scenes/order.tscn")

func add_order(order: Order) -> int:
	for i in range(1, 5):
		if orders.has(i):
			continue
		else:
			orders[i] = order
			var order_instance = ORDER_SCENE.instantiate()
			order_instance.set_order_time(order.get_order_time())
			orders_display.add_child(order_instance)
			order_instance.set_order_number(i)
			order_instance.setType(order.get_order_type())
			order_display[i] = order_instance
			return i
			
	return 0
		
func remove_order(number: int) -> CharacterBody2D:
	var retVal = orders[number].get_customer()
	orders[number].get_customer().on_order_complete()
	orders.erase(number)
	order_display[number].queue_free()
	order_display.erase(number)
	return retVal

func set_order_display(display: HBoxContainer):
	orders_display = display

func get_order(order:int) -> Order:
	if orders.has(order):
		return orders[order]
	else:
		return null
		
func clear_all_orders():
	orders.clear()
	var children = orders_display.get_children()
	for child in children:
		child.queue_free()
