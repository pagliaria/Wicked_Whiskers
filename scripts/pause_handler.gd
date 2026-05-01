extends Node2D

var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")

func _input(event: InputEvent) -> void:
	#print("INPUT: ", event.as_text())
	if event.is_action_pressed("pause"):
		if is_inside_tree():
			var pm = pause_menu.instantiate()
			var canvas = CanvasLayer.new()
			canvas.layer = 10
			get_tree().current_scene.add_child(canvas)
			canvas.add_child(pm)
			pm.canvas_layer = canvas
