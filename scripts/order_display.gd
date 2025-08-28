extends Control

var order_time
@onready var progress_bar: ProgressBar = $Panel/ProgressBar
@onready var item_number: Label = $Panel/item_number
@onready var happy: TextureRect = $Panel/happy
@onready var angry: TextureRect = $Panel/angry
@onready var surprised: TextureRect = $Panel/surprised

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
