class_name Order extends Node

var order_item
var order_hat
var order_customer_node
var order_time

func _init(hat: Enums.HatType, item: Enums.OrderType, customer: CharacterBody2D, time: float):
	order_hat = hat
	order_item = item
	order_customer_node = customer
	order_time = time
	
func get_customer() -> CharacterBody2D:
	if is_instance_valid(order_customer_node):
		return order_customer_node
	return null

func get_order_time() -> float:
	return order_time

func get_order_type() -> Enums.OrderType:
	return order_item

func get_order_hat() -> Enums.HatType:
	return order_hat

func set_hat_type(h: Enums.HatType):
	order_hat = h
