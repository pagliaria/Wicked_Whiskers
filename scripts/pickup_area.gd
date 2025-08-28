extends Area2D

func _ready():
	add_to_group("items")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Entered " + body.name)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("Exited " + body.name)
