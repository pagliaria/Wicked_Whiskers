extends RigidBody2D

var order_number = -1
var can_pickup = false
var customer: CharacterBody2D = null
var grow_patch:Sprite2D = null
@onready var pumpkin_bad: AnimatedSprite2D = $pumpkin_bad
@onready var pumpkin_good: Sprite2D = $pumpkin_good

func _ready():
	add_to_group("items")

func set_can_pick_up():
	can_pickup = true
	
func can_pick_up() -> bool:
	return can_pickup

func attach_patch(patch:Sprite2D):
	#print("attached")
	grow_patch = patch

func picked_up():
	#print("picked up")
	grow_patch.on_picked()

func getType() -> Enums.OrderType:
	return Enums.OrderType.INVALID

func death():
	pumpkin_bad.visible = true
	pumpkin_good.visible = false
	pumpkin_bad.play("rotting")
	
func _on_pumpkin_bad_animation_finished() -> void:
	print("pumpkin death")
	if is_multiplayer_authority():
		queue_free()

func set_customer(c: CharacterBody2D):
	customer = c

func set_order_number(number:int):
	order_number = number
	
func get_order_number() -> int:
	return order_number
