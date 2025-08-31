extends Control

@export var bus_name: String = "Master"
@onready var vol_slider: HSlider = $Panel/HSlider

func _ready() -> void:
	# Initialize slider value with current bus volume
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var current_volume_db = AudioServer.get_bus_volume_db(bus_index)
		print("volume: ",  db_to_linear(current_volume_db))
		vol_slider.value = db_to_linear(current_volume_db)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	self.queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1: # Check if bus exists
		var volume_db = linear_to_db(value) # Convert linear to decibels
		print("set vol: ", linear_to_db(value))
		AudioServer.set_bus_volume_db(bus_index, volume_db)
