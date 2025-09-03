extends RigidBody2D

var order_number = -1
var can_pickup = false
var player: CharacterBody2D = null
var grow_patch:Sprite2D = null
var hat = Enums.HatType.NONE
@onready var pumpkin_bad: AnimatedSprite2D = $pumpkin_bad
@onready var pumpkin_good: Sprite2D = $pumpkin_good
@onready var hat_image: TextureRect = $hat_image
const CAP = preload("res://assets/sprites/hats/cap.png")
const COWBOY = preload("res://assets/sprites/hats/cowboy.png")
const SOMBRARO = preload("res://assets/sprites/hats/sombraro.png")
const WITCH_HAT = preload("res://assets/sprites/hats/witch_hat.png")

func _ready():
	add_to_group("items")

func set_can_pick_up():
	can_pickup = true
	
func can_pick_up() -> bool:
	return can_pickup

@rpc("any_peer", "call_local")
func attach_patch(path):
	#print("attached")
	grow_patch = get_node(path)

func picked_up():
	#print("picked up")
	grow_patch.on_picked.rpc()

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

func set_order_number(number:int):
	order_number = number
	
func get_order_number() -> int:
	return order_number

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
