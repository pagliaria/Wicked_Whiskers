class_name Order extends Node

var order_item
var order_customer_node
var order_time

func _init(item: Enums.OrderType, customer: CharacterBody2D, time: float):
	order_item = item
	order_customer_node = customer
	order_time = time
	
func get_customer() -> CharacterBody2D:
	return order_customer_node

func get_order_time() -> float:
	return order_time

func get_order_type() -> Enums.OrderType:
	return order_item
