extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_pressed() && event.as_text() == "R":
		if is_inside_tree():
			get_tree().paused = false
			print("restart!")
			get_tree().reload_current_scene()
			OrderManager.clear_all_orders()
	if Enums.get_passed() && event.is_pressed() && event.as_text() == "N":
		if is_inside_tree():
			get_tree().paused = false
			Enums.set_night(Enums.get_night() + 1)
			Enums.set_passed(false)
			get_tree().reload_current_scene()
			OrderManager.clear_all_orders()
