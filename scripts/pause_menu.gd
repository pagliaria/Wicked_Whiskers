extends Control

@export var bus_name: String = "Master"
@onready var vol_slider: HSlider = $Panel/VolumeRow/HSlider
@onready var resume_btn: Button = $Panel/ButtonRow/ResumeCenter/resume
var canvas_layer: CanvasLayer = null

func _ready() -> void:
	get_tree().paused = true
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	ControlsGrid.build($Panel/ControlsGrid, 11)
	resume_btn.grab_focus()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	if canvas_layer:
		canvas_layer.queue_free()
	else:
		queue_free()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

func _on_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
