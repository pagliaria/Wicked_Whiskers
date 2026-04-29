extends StaticBody2D

var cost = 25
var hell_dog: CharacterBody2D
@onready var cost_label: Label = $cost

func get_cost():
	return cost

func set_dog(dog):
	hell_dog = dog
	
func get_dog():
	return hell_dog

func activate_dog():
	print("activate house")
	hell_dog.activate.rpc()

func _on_ready() -> void:
	cost_label.text = str(cost)
