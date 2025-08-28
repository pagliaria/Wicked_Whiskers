extends RigidBody2D

var order_number = -1
var type = Enums.OrderType.INVALID
@onready var happy: Sprite2D = $happy
@onready var angry: Sprite2D = $angry
@onready var surprised: Sprite2D = $surprised

var customer: CharacterBody2D = null

func _ready():
	add_to_group("items")

func getType() -> Enums.OrderType:
	return type

func setType(t: Enums.OrderType):
	type = t
	match type:
		Enums.OrderType.HAPPY:
			happy.visible = true
		Enums.OrderType.ANGRY:
			angry.visible = true
		Enums.OrderType.SURPRISED:
			surprised.visible = true

func can_pick_up() -> bool:
	return true
	
func picked_up():
	pass
	
func set_order_number(number:int):
	order_number = number
	
func set_customer(c: CharacterBody2D):
	customer = c

func get_order_number() -> int:
	return order_number

func death():
	queue_free()
