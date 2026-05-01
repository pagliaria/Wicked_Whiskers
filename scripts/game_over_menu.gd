extends Control

@export var bus_name: String = "Master"

@onready var restart_btn: Button = $Panel/ButtonRow/RestartCenter/restart
@onready var quit_btn: Button = $Panel/ButtonRow/QuitCenter/quit

var canvas_layer: CanvasLayer = null

func _ready() -> void:
	get_tree().paused = true
	restart_btn.grab_focus()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	OrderManager.clear_all_orders()
	Enums.coins = 0

	if canvas_layer != null:
		canvas_layer.queue_free()
	else:
		queue_free()

	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	if canvas_layer != null:
		canvas_layer.queue_free()
	else:
		queue_free()
	get_tree().quit()
