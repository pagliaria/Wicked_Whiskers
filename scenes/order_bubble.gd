extends Sprite2D

@onready var happy: TextureRect = $happy
@onready var angry: TextureRect = $angry
@onready var surprised: TextureRect = $surprised


func set_type(t: Enums.OrderType):
	match t:
		Enums.OrderType.HAPPY:
			happy.visible = true
		Enums.OrderType.ANGRY:
			angry.visible = true
		Enums.OrderType.SURPRISED:
			surprised.visible = true
