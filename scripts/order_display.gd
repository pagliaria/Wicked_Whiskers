extends Control

var order_time
@onready var progress_bar: ProgressBar = $Panel/ProgressBar
@onready var item_number: Label = $Panel/item_number
@onready var happy: TextureRect = $Panel/happy
@onready var angry: TextureRect = $Panel/angry
@onready var surprised: TextureRect = $Panel/surprised
@onready var hat_image: TextureRect = $Panel/hat_image
const CAP = preload("res://assets/sprites/hats/cap.png")
const COWBOY = preload("res://assets/sprites/hats/cowboy.png")
const SOMBRARO = preload("res://assets/sprites/hats/sombraro.png")
const WITCH_HAT = preload("res://assets/sprites/hats/witch_hat.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	progress_bar.value = ((Time.get_unix_time_from_system() - order_time) / Enums.ORDER_TIMEOUT_SEC) * 100

func set_order_time(time: float):
	order_time = time

func set_order_number(i:int):
	item_number.text = str(i)

func setType(t: Enums.OrderType):
	match t:
		Enums.OrderType.HAPPY:
			happy.visible = true
		Enums.OrderType.ANGRY:
			angry.visible = true
		Enums.OrderType.SURPRISED:
			surprised.visible = true

func set_hat(h: Enums.HatType):
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
