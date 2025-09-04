extends Node2D

var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")

func _input(event: InputEvent) -> void:
	#print("INPUT: ", event.as_text())
	if event.is_pressed() && event.as_text() == "R":
		if is_multiplayer_authority():
			get_parent().clean_up()
			reset.rpc()
		#if is_inside_tree():
			#get_tree().paused = false
			#print("restart!")
			#get_tree().reload_current_scene()
			#OrderManager.clear_all_orders()
			
	if Enums.get_passed() && event.is_pressed() && event.as_text() == "N":
		if Enums.get_night() < 3:
			if is_multiplayer_authority():
				get_parent().clean_up()
				next_day.rpc()

	if event.is_pressed() && event.as_text() == "Escape":
		if is_inside_tree():
			#get_tree().paused = true
			get_tree().root.add_child(pause_menu.instantiate())

@rpc("any_peer","call_local")
func reset():
	if is_inside_tree():
		get_tree().paused = false
		print("restart!")
		get_tree().reload_current_scene()
		OrderManager.clear_all_orders()

@rpc("any_peer","call_local")
func next_day():
	if is_inside_tree():
		get_tree().paused = false
		Enums.set_night(Enums.get_night() + 1)
		Enums.set_passed(false)
		get_tree().reload_current_scene()
		OrderManager.clear_all_orders()
