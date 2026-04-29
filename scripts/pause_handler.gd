extends Node2D

var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")

func _input(event: InputEvent) -> void:
	#print("INPUT: ", event.as_text())
	if event.is_pressed() && event.as_text() == "R":
		if is_multiplayer_authority():
			get_parent().clean_up()
			reset.rpc()

	if event.is_action_pressed("pause"):
		if is_inside_tree():
			var pm = pause_menu.instantiate()
			var canvas = CanvasLayer.new()
			canvas.layer = 10
			get_tree().current_scene.add_child(canvas)
			canvas.add_child(pm)
			pm.canvas_layer = canvas

@rpc("any_peer","call_local")
func reset():
	if is_inside_tree():
		get_tree().paused = false
		print("restart!")
		get_tree().reload_current_scene()
		OrderManager.clear_all_orders()
		Enums.coins = 0
