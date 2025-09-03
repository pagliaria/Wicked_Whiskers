extends RigidBody2D

var order_number = -1
var type = Enums.OrderType.INVALID
@onready var happy: Sprite2D = $happy
@onready var angry: Sprite2D = $angry
@onready var surprised: Sprite2D = $surprised

var hat = Enums.HatType.NONE
@onready var hat_image: TextureRect = $hat_image
const CAP = preload("res://assets/sprites/hats/cap.png")
const COWBOY = preload("res://assets/sprites/hats/cowboy.png")
const SOMBRARO = preload("res://assets/sprites/hats/sombraro.png")
const WITCH_HAT = preload("res://assets/sprites/hats/witch_hat.png")

var player: CharacterBody2D = null

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

func get_order_number() -> int:
	return order_number

func death():
	queue_free()

@rpc("any_peer","call_local")
func add_hat(h:Enums.HatType):
	hat = h
	hat_image.visible = true
	match h:
		Enums.HatType.WITCH:
			hat_image.visible = true
			hat_image.texture = WITCH_HAT
		Enums.HatType.CAP:
			hat_image.visible = true
			hat_image.texture = CAP
		Enums.HatType.COWBOY:
			hat_image.visible = true
			hat_image.texture = COWBOY
		Enums.HatType.SOMBRARO:
			hat_image.visible = true
			hat_image.texture = SOMBRARO
			

func get_hat() -> Enums.HatType:
	return hat

func get_player() -> CharacterBody2D:
	return player

func set_player(p: CharacterBody2D):
	player = p
