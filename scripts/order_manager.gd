extends Node

var orders = {}
var order_display = {}
var paused_time = 0

@onready var orders_display: HBoxContainer = null
const ORDER_SCENE = preload("res://scenes/order.tscn")

func add_order(order: Order) -> int:
	for i in range(1, 9):
		if orders.has(i):
			continue
		else:
			orders[i] = order
			var order_instance = ORDER_SCENE.instantiate()
			order_instance.set_order_time(order.get_order_time())
			orders_display.add_child(order_instance)
			order_instance.set_order_number(i)
			order_instance.setType(order.get_order_type())
			order_instance.set_hat(order.get_order_hat())
			order_display[i] = order_instance
			# If this is the only order, auto-highlight it
			if orders.size() == 1:
				highlight_order(i)
			return i
	return 0

@rpc("any_peer", "call_local")
func remove_order(number: int):
	orders.erase(number)
	if order_display.has(number):
		order_display[number].queue_free()
		order_display.erase(number)

func set_order_display(display: HBoxContainer):
	orders_display = display

func get_order(order: int) -> Order:
	if orders.has(order):
		return orders[order]
	else:
		return null

func add_paused_time(time: float):
	paused_time = time
	var children = orders_display.get_children()
	for child in children:
		child.add_pause_time(time)

	for i in orders:
		var customer = orders[i].get_customer()
		if customer != null:
			customer.add_pause_time(time)
		
func get_display(order: int):
	if order_display.has(order):
		return order_display[order]
	return null

# Returns the order number with the least time remaining.
# Ties broken by lowest order number (leftmost in the display).
func get_most_urgent_order_number() -> int:
	return get_most_urgent_order_number_excluding(-1)

# Same as above but skips `exclude` — use when an order has been thrown
# but not yet removed from the dict (pumpkin still in flight).
func get_most_urgent_order_number_excluding(exclude: int) -> int:
	var best_num = -1
	var best_remaining = INF
	for num in orders:
		if num == exclude:
			continue
		var remaining = (Enums.ORDER_TIMEOUT_SEC + paused_time) - (Time.get_unix_time_from_system() - orders[num].get_order_time())
		if remaining < best_remaining:
			best_remaining = remaining
			best_num = num
	return best_num

func highlight_order(selected: int) -> void:
	for num in order_display:
		order_display[num].set_selected(num == selected)

func clear_all_orders():
	orders.clear()
	var children = orders_display.get_children()
	for child in children:
		child.queue_free()
	order_display.clear()
